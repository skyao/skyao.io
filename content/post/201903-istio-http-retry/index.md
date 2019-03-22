+++
title = "Istio1.1新特性之控制HTTP Retry"

date = 2019-03-22
lastmod = 2019-03-22
draft = false

tags = ["Istio"]
summary = "Istio1.1版本加强了对HTTP Retry条件的控制，同时修改了原有的HTTP retry的默认行为，去除了5xx的重试条件，但是没有文档上体现，所以使用时请留意：如果遇到重试不生效，请检查retryOn配置。"
abstract = "Istio1.1版本加强了对HTTP Retry条件的控制，同时修改了原有的HTTP retry的默认行为，去除了5xx的重试条件，但是没有文档上体现，所以使用时请留意：如果遇到重试不生效，请检查retryOn配置。"

[header]
image = "headers/post/201903-istio-service-visibility.jpg"
caption = ""

+++

## 背景介绍

看到崔秀龙同学发了一篇文章，["《深入浅出 Istio》在 Istio 1.1 中的一些已知情况"](https://blog.fleeto.us/post/istio-book-update-for-1-1/?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)，其中提到：

> 重试无法工作	，HTTPRetry 结构发生变更。加入 retryOn: 5xx 即可。

想知道具体什么情况，就跑去翻了翻 Istio 的文档和代码。

https://istio.io/docs/reference/config/networking/v1alpha3/virtual-service/#HTTPRetry

HTTPRetry 结构中增加了一个名为 retryOn 的字段，"Specifies the conditions under which retry takes place. One or more policies can be specified using a ‘,’ delimited list. "。这个字段用来指定重试的发生条件，可以有多个，用","分割。

参考资料有：

- [Envoy x-envoy-retry-on 说明](https://www.envoyproxy.io/docs/envoy/latest/configuration/http_filters/router_filter#x-envoy-retry-on)
- [Envoy x-envoy-retry-grpc-on说明](https://www.envoyproxy.io/docs/envoy/latest/configuration/http_filters/router_filter#x-envoy-retry-grpc-on)

底层envoy早就提供了 retryOn 字段来指定重试的条件。找到相关的 issue，[Add more configuration options to the retry policy](https://github.com/istio/istio/issues/8081) ，有非常明确的说明了Istio1.1之前的做法：

> Currently Istio (v1.0) hard codes the retry policy to 5xx,connect-failure,refused-stream.
See
> 当前Istio (v1.0)  hard code retry policy 为 5xx,connect-failure,refused-stream

Istio1.1版本将 Envoy 的 retryOn 字段暴露出来，以便提供更灵活的设置，按说是个很常规的操作。但是为什么会导致重试无法工作呢？

## 问题所在

这是Istio1.1之前的代码，`pilot/pkg/networking/core/v1alpha3/route/route.go`, 其中 RetryOn 默认写死为 "5xx,connect-failure,refused-stream"：

```go
			RetryOn:       "5xx,connect-failure,refused-stream",
```

而最新的 Istio1.1版本的代码，`pilot/pkg/networking/core/v1alpha3/route/retry/retry.go`, 提供了 retryOn 字段来指定重试的条件，如果没有明确设置（如Istio1.1之前就没有这个字段自然也就没有设置），则默认值如下：

```go
		RetryOn:              "connect-failure,refused-stream,unavailable,cancelled,resource-exhausted",
```

注意前后两次的默认值差别：

- 新的Istio1.1版本增加了 unavailable,cancelled,resource-exhausted 三种情况下的重试条件，非常合理
- 新的Istio1.1版本去除了5xx

问题就在于默认值不再包含5xx，因此如果直接使用之前版本的测试方式，HTTPRetry中没有指定 retryOn 字段，而测试场景使用的错误码刚好是5xx，就会因为这个默认值变化的原因导致重试无法生效。

但是在Istio的文档中，关于 retryOn 字段的说明中，没有提到底层默认值有改变，尤其是，“最常用的5xx错误会默认不重试”这么一个非常重要的信息，没有给出提示，所以容易造成困扰：为什么之前能工作，升级到Istio1.1就不行了？

因此，如果大家测试时遇到重试功能为能生效，请检查你设置的错误条件。

## 默认值的讨论

RetryOn 的默认值应该如何设置才合理？才是必要而安全的重试？

Istio1.1之前的默认值是 "5xx,connect-failure,refused-stream"，这里面 connect-failure 和 refused-stream 两个错误是连接级别的错误，也就是请求都未能发送过去，因此有必要重试，而且重试也是非常安全的。

Istio1.1的新默认值设置为 “connect-failure,refused-stream,unavailable,cancelled,resource-exhausted”，其中 unavailable,cancelled,resource-exhausted 是给gRPC协议用的，重试也是安全的。

真正的改变在于默认值中不再有 5xx ，具体的讨论可以参考Issue https://github.com/istio/istio/pull/9840。 摘录部分重要内容：

- RetryOn: what should we retry on by default? The question here revolves around idempotence. I suspect that connect-failure and refused-stream should be safe, regardless. But what about gateway-error (i.e. 502, 503, 504) for non-idempotent requests?
- For non-idempotent requests, gateway-error (i.e. 502, 503, 504) may make things even worse. But 503s is just during periods of pod churn. So we should not simply set gateway-error by default.
- BTW our current retry setup retries on gateway-error, connect-failure, and refused-stream and we do it with envoy headers due to the fact isito currently hardcoded retires any 5xx error (this pr addressing that), which in our opinion is bad.

最终讨论的结果是从默认值中去除了 5xx。这个决定是有道理，默认5xx就重试的确存在风险。

## 总结分析

这是一个非常小的细节，改动的地方很小，理解起来也很容易，但还是能说明一些问题：

- Istio/Envoy 体系的确在功能上做的非常的齐全，细微之处的考虑非常多，而且一直在完善中
- Istio的工程管理有点拖沓，从issue记录看，这个小改动最早在2018年8月就提出来了，最后发布却到了2019年3月，时间未免长了点
- 重点批评一下：Istio1.1版本修改了原有的HTTP retry的默认行为，从分析上看这次修改还属于改善性质，但我觉得也还是应该在文档上有所体现，避免使用者犯错——这应该是一个基本原则，反例可以参考波音737 MAX。





