+++
title = "Istio1.1新特性之TCP Weighted Cluster"

date = 2019-03-19
lastmod = 2019-03-19
draft = false

tags = ["Istio"]
summary = "Istio支持在多个cluster之间设置权重，通过设置不同的subset和weight，可以实现很多丰富的功能。但是之前只能为HTTP提供，TLS和TCP只能设置一个Destination，直到Istio1.1版本。"
abstract = "Istio支持在多个cluster之间设置权重，通过设置不同的subset和weight，可以实现很多丰富的功能。但是之前只能为HTTP提供，TLS和TCP只能设置一个Destination，直到Istio1.1版本。"

[header]
image = "headers/post/201903-istio-service-visibility.jpg"
caption = ""

+++

### Weighted Cluster

Istio支持在多个cluster之间设置权重，通过设置不同的subset和weight，可以实现很多丰富的功能，如大家熟悉的各种灰度发布（金丝雀发布/蓝绿部署/ABTest）等都是由此变化而来。

下面的例子熟悉Istio的同学应该都不陌生：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-route
spec:
  hosts:
  - reviews.prod.svc.cluster.local
  http:
  - route:
    - destination:
        host: reviews.prod.svc.cluster.local
        subset: v2
      weight: 25
    - destination:
        host: reviews.prod.svc.cluster.local
        subset: v1
      weight: 75
```

这个例子来自官方实例 bookinfo ：

https://istio.io/docs/reference/config/istio.networking.v1alpha3/#DestinationWeight

在这里设置了v1和v2的流量分别为75%和25%。

### 只支持HTTP

但是，1.1版本之前的Istio，对于 Weighted Cluster 只支持HTTP协议（包括HTTP1.1/HTTP2/gRPC）。对于 TCP 和 TLS，虽然 VirtualService 的设置上和HTTP一直，但是实际上在执行时会做验证。

在 `pilot/pkg/model/validation.go` 中，validateTLSRoute()会对 TLS 做限制：

```go
if len(tls.Route) != 1 {
    errs = appendErrors(errs, errors.New("TLS route must have exactly one destination"))
}
```

validateTCPRoute()会对 TCP 做限制：

```go
if len(tcp.Route) != 1 {
    errs = appendErrors(errs, errors.New("TCP route must have exactly one destination"))
}
```

导致 TCP 和 TLS 都只能设置一个destination，也就无法实现分流。

### 增加对TCP和TLS的支持

在 Envoy 1.8 版本之后，增加对TCP和TLS的 Weighted Cluster 支持。而在即将发布的Istio 1.1 版本中也加入同样提供支持。

具体的 github PR 如下：

- [pilot: add support for weighted TCP/TLS clusters](https://github.com/istio/istio/pull/9112): This PR adds support for weighted clusters in TCP and TLS implementations as supported in Envoy.
- [tcp_proxy: add support for weighted clusters](https://github.com/envoyproxy/envoy/pull/4430):This PR adds support for optional weighted clusters in TCP Proxy.

这两个PR的作者 Venil Noronha 写了一篇博客文章详细说明了 TCP和TLS的 Weighted Cluster 的用法，具体请见下文：

[Raw TCP Traffic Shaping with Istio 1.1.0](https://venilnoronha.io/raw-tcp-traffic-shaping-with-istio-1.1.0)

简单摘录一下关键点：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: route
spec:
  hosts:
  - "*"
  gateways:
  - gateway
  tcp: # <-- 这里！
  - match:
    - port: 31400
    route:
    - destination:
        host: tcp-echo-server
        port:
          number: 9000
        subset: v1
      weight: 80
    - destination:
        host: tcp-echo-server
        port:
          number: 9000
        subset: v2
      weight: 20
```

### 总结

这个特性很小，基本上一看就明白，如果有需要的时候直接用就好。

唯一需要感叹的是：Envoy 和 Istio 的社区基础真好，总有人把各种之前没有完成的细节做好。
