+++
title = "DreamMesh抛砖引玉(9)-API Gateway"

date = 2018-03-22
lastmod = 2018-03-22
draft = false

tags = ["DreamMesh"]
summary = "service mesh解决的是东西向服务间通讯的问题，我们来审视一下API gateway到微服务之间的南北向通讯： 服务发现，负载均衡，路由，灰度，安全，认证，加密，限流，熔断……几乎所有主要功能，在这两个方向上都高度重叠。因此，是否该考虑提供一个统一的解决方案来处理？"
abstract = "service mesh解决的是东西向服务间通讯的问题，我们来审视一下API gateway到微服务之间的南北向通讯： 服务发现，负载均衡，路由，灰度，安全，认证，加密，限流，熔断……几乎所有主要功能，在这两个方向上都高度重叠。因此，是否该考虑提供一个统一的解决方案来处理？"

[header]
image = "headers/post/201803-dreammesh-brainstorm-gateway.jpg"
caption = ""

+++

service mesh解决的是东西向服务间通讯的问题，我们来审视一下API gateway到微服务之间的南北向通讯： 服务发现，负载均衡，路由，灰度，安全，认证，加密，限流，熔断……几乎大部分的主要功能，在这两个方向上都高度重叠。

因此，是否该考虑提供一个统一的解决方案来处理？

## 在Service Mesh之前

在Service Mesh出来之前，这个问题就已经存在，而且也已经有了解决方案。

对于API Gateway的产品，有两种不同的实现方式：

1. 基于微服务体系

	典型如Zuul/Spring Cloud Gateway，这类API Gateway的产品和微服务体系一脉相承，在实现将请求转发到内部服务时，API Gateway等同于一个普通的微服务客户端。

	因此，可以复用微服务体系客户端的几乎所有功能，比如Zuul/Spring Cloud Gateway都是和Spring Cloud的普通客户端一样，用Feign做client，Ribbon做负载均衡，用Eureka或者其他ServiceDiscovery实现做服务发现，Hystrix做熔断......

	![](images/gateway-1.png)

2. 独立于微服务体系

	对于独立的API Gateway产品，典型如kong，因为和微服务体系不是一体，因此无法直接复用微服务体系的客户端，需要自行通过其他方式解决。

	最基本的，是需要解决服务发现的问题。

	请教了一下熟悉kong的朋友，kong是通过DNS的方式来进行服务发现的。也就是说，需要实现DNS和服务注册机制的协同，典型的做法是使用consul这种支持DNS的服务注册机制。也可以通过插件的方式实现服务发现的客户端。

	![](images/gateway-2.png)

两种实现方式的根本差别：在于能否**复用**微服务体系的客户端机制。

## 在Service Mesh之后

当我们将侵入式的微服务框架替换为Service Mesh，这个问题会发生一些微妙的变化，因为：

**Service Mesh是基于Sidecar的**。

而Sidecar的特点是：独立进程，运行于客户端进程之外；通过远程访问来接收和转发请求。

按照上面的思路，我们需要考虑如何在API Gateway中复用Service Mesh体系的客户端机制，也就是复用sidecar。有个简单而直白的方案，就是将sidecar"竖"起来，添加到南北向的流量中，如图所示：

![](images/gateway-3.png)

## 优势分析

上述方案如果成功实现，则带来以下好处：

- 统一了微服务和API Gateway两套体系，大量节约学习/开发/维护的成本
- API Gateway体系可以从Service Mesh方案中得到同样的各种好处，可以使用各种高级特性
- 通过Service Mesh的控制平面，可以控制的范围从微服务体系扩展到了API Gateway体系

非常美好的想法，那关键来了：该如何实现？

## 实现方式

宏观上看，实现应该不难，起码思路很清晰：

**将API Gateway纳入Service Mesh体系**

理由：要让API Gateway可以使用sidecar，要让这个和API Gateway一起部署的siecar可以工作于Service Mesh体系，那么最简单的办法，就是将API Gateway连同它的sidecar，一起融入Service Mesh体系：

![](images/gateway-4.png)

此时，API Gateway扮演一个普通服务的角色，运行于Service Mesh体系内，自然可以复用Service Mesh的所有功能。

### k8s带来的影响

考虑到如果Service Mesh是运行在k8s上时，典型如Istio/Conduit，那么事情会稍微复杂一点：因为k8s下会有个外部流量如何进入k8s的问题。我们需要为此引入类似Ingress的组件：

![](images/gateway-5.png)

### k8s下的另类方式

仔细想了一下，理论上还存在另外一种的方式，貌似有些另类：

- API Gateway体系继续独立于Service Mesh体系之外
- 在Service Mesh体系内为API Gateway部署特殊的sidecar，专门用于转发南北向流量

如下图所示：

![](images/gateway-6.png)

此时的sidecar，不再和使用者在一起，也就是不是"local"。部署模型上和正规的sidecar差别很大。

### 追求极致性能的方式

如果特别介意Sidecar引入之后造成的性能下降，也可以考虑下面的方式：

![](images/gateway-7.png)


- 直接在Sidecar的基础上做开发和扩展
- 目标是将Gateway的功能和Sidecar的功能合二为一
- 这样可以减少一次gateway和sidecar之间的远程调用

这个方式个人不建议，因为基本又退回侵入式框架的模式，除非对性能有非常高甚至堪称极致的需求（比如单机超过10万/20万QPS），否则感觉没有必要。

## 总结

权衡各个方案，个人意见，下面这个方案比较均衡：

![](images/gateway-5.png)

主要考虑如下：

1. 可以直接重用sidecar

	* 开发工作量少很多
	* Gateway职责清晰

1. 编程语言的考虑

	* 目前Istio中的sidecar是Envoy，基于c++，Conduit中的是Rust语言
	* 这两个语言开发难度，尤其是客户二次开发或者扩展的难度都非常大
	* gateway最好还是用Golang或者Java开发会比较合适
	* 尤其是Java，普通用户的接受度应该会更高

这个gateway可以全新编写，或者找个现成的gateway产品修改。考虑到gateway的工作模式主要是请求转发，最适合响应式编程，这里有很多发挥的空间。

## 讨论和反馈

TBD：等收集后整理更新

## 后记

有兴趣的朋友，请联系我的微信，加入DreamMesh内部讨论群。
