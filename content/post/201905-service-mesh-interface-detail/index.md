+++
title = "Service Mesh Interface详细介绍"

date = 2019-05-31
lastmod = 2019-05-31
draft = true

tags = ["SMI", "Service Mesh"]
summary = "Service Mesh Interface详细介绍"
abstract = "Service Mesh Interface详细介绍"

[header]
image = ""
caption = ""

+++

## SMI介绍

![](images/smi-logo_0.png)

### SMI是什么？

5月21号，在 kubeconf上，微软联合一众小伙伴，宣布了 Service Mesh Interface，简称SMI。SMI是一个服务网格规范，定义了通用标准，包含基本特性以满足大多数场景下的通用需求。

援引来自SMI官方网站  [smi-spec.io](https://smi-spec.io/) 的介绍资料，对 Service Mesh Interface 的定位是 ：

> A standard interface for service meshes on Kubernetes.
> 
> Kubernetes上的 service mesh 的标准接口

微软的 [官方博客文章](https://msft.today/hello-service-mesh-interface-smi-a-specification-for-service-mesh-interoperability/) 这样介绍SMI：

> SMI定义了一组通用可移植的API，为开发人员提供跨不同服务网格技术的互操作性，包括Istio，Linkerd和Consul Connect。

### SMI推出的背景

 [Idit Levine](https://medium.com/@idit.levine_92620)，初创公司 solo.io 的创始人兼CEO，作为SMI推出的重要力量之一，撰文描述了 SMI 推出的背景：

> 服务网格生态系统正在兴起，众多的网格供应商和不同的用例需要不同的技术。所以问题来了：我们如何实现在不破坏最终用户体验的前提下促进行业创新？通过以一组标准API达成一致，我们可以提供互操作性，并在不同网格以及为这些网格构建的工具之上维持最终用户体验。
>
> 今天发布的 Service Mesh Interface（SMI）是使这一构想走向行业现实的重要一步。

下面这幅图片可以非常清晰的表述SMI的定位，也可以帮助我们一起来解读SMI推出的背景：

![](images/SMI-Graphic.jpg)

1. Service Mesh的价值正在被普遍认可：从最早的Linkerd，Envoy，到两年前Google力推Istio，以及 Linkerd2 的推出，最近 AWS 推出了 App Mesh，Google 则将 Istio 搬上了Google Cloud 推出了 Istio 的公有云托管版本 Google Cloud Service Mesh，还推出了单独的控制平面产品 Google Traffic Director。微软也在去年推出了Azure完全托管版本的Service Fabric Mesh （预览版）。云市场三巨头都已经先后出手。
2. 市场上出现了众多的Service Mesh产品：开源的，闭源的，大公司出的，小公司出的，市场繁荣的同时也带来了市场碎片化的问题。
3. 在云原生理念下，我们推崇应用轻量化，只关注业务逻辑。Service Mesh技术很好的实现了这一战略目标：运行在 service mesh 上的应用可以和底层 service mesh 的具体实现解耦。理论上应用在不同的 service mesh 实现上迁移是可行的，从这一点说，service mesh 在云原生的道路上迈出了重要一步。
4. 但是，所有围绕业务应用的外围工作，比如通过 service mesh对流量进行控制，配置各种安全/监控/策略等行为，以及在这些需求上建立起来的工具和生态系统，却不得不牢牢的绑死在某个具体的 service mesh实现上，所谓"供应商锁定"。
5. 其根本问题在于各家实现不同，又没有统一标准。因此，要想解决上述问题，就必须釜底抽薪：**解决 Service Mesh 的标准化问题**。

微软给出的解决方案就是引入SMI，作为一个通用的行业规范/标准，如果能让各家 service mesh 提供商都遵循这个标准，则有机会在具体的 service mesh 产品之上，抽象出一个公共层（如定义一组通用可移植的API），屏蔽掉上层应用/工具/生态系统对具体  service mesh 产品的实现细节。

在SMI中，将这个目标称为 "**Interoperability**" / 互通性。我个人理解，这其实和 google 一直在倡导的 "not lock-in" 是一个概念：有通用的社区标准/行业标准，在此基础上客户可以在多个实现/多个供应商之间自由选择和迁移，没有被绑定的风险，而且提供给用户的功能以及使用方式也保持一直，也就是 Idit Levine 所强调的 "维持最终用户体验"。

从这个角度说，我很欣喜的看到 SMI 的推出，虽然这条路可能不是那么容易走，但是，的确，"Service Mesh Interface（SMI）是使这一构想走向行业现实的重要一步"。

### SMI的目标和愿景

关于 SMI 的目标和愿景，我援引  Idit Levine 的这段话（这段话也同样出现在 smi-spec 的 github 首页）：

> SMI 是在 Kubernetes 上运行服务网格的规范。它定义了由各种供应商实现的通用标准。这使得最终用户的标准化和服务网格供应商的创新可以两全其美。SMI 实现了灵活性和互通性。

更详细而明确的目标描述来自 smi-spec 的 github 首页：

> 目标
> 
> SMI API的目标是提供一组通用的，可移植的Service Mesh API，Kubernetes用户可以以供应商无关的方式使用这些API。通过这种方式，可以定义使用Service Mesh技术的应用程序，而无需紧密绑定到任何特定实现。

然后还特别强调：

> 非目标
> 
> **SMI项目本身不实现服务网格**。SMI只是试图定义通用规范。同样，SMI不定义服务网格的具体范围，而是一个通用子集。 欢迎SMI供应商添加超出SMI规范的供应商特定扩展和API。 我们希望随着时间的推移，随着更多功能被普遍接受为服务网格的一部分，这些定义将迁移到SMI规范中。

### SMI社区

有需求，有市场，有想法，有目标，那能否成事，就看人了。我们来看看 SMI 阵营现在都有什么力量。

微软在推出 SMI 时的描述到：SMI是一个开放项目，由微软，Linkerd，HashiCorp，Solo，Kinvolk和Weaveworks联合启动; 并得到了Aspen Mesh，Canonical，Docker，Pivotal，Rancher，Red Hat和VMware的支持。

![](images/partnership.png)

阵营还是挺强大的：

- 微软：SMI的带头大哥，云计算的三巨头之一
- Linkerd：Service Mesh 技术的拓荒牛 + 布道者，小而弥坚的初创公司，有一个不大但是力量很强又非常有经验还很务实的团队
- HashiCorp：大名鼎鼎的 consul 就出自这里，Consul Connect 也是目前活跃的 service mesh 实现之一，虽然Consul Connect在国内知名度和影响力都很小（也就年度总结的时候捎带着看一眼状态的那种）。
- Solo.io：深藏不露的初创型小公司，"产品面很广，除了 Service Mesh 方面大有名气的 SuperGloo 和 Service Mesh hub 之外，还有远程调试、混沌工程、unikernels 以及微服务网关等几个产品。"（这段话我从秀龙的文章里面抄过来的，总结的很好）。另外，业界网红 Christian Posta 前段时间加入这家公司。
- Mesery 和 Kinvolk：这两家公司最近在 service mesh社区有点名气，因为他们近期做了 Istio vs Linkerd 的性能测试并给出了报告，闹的满城风雨。而且他们也都喜欢用 solo 出的 SuperGloo（毕竟业界号称 service mesh 编排的也就独此一家）。
- Aspen Mesh： F5 （没错，就是那个巨有钱的F5）出的的Istio商业版本。

其他公司就不再一一列出来了，主要是不清楚他们在 SMI 这个事情上扮演什么角色。

而关键点在于，Google （还有同属Istio阵营的 IBM / Lyft）

![](images/two-api.png)

## SMI规范内容

SMI规范由多个API组成：

- Traffic Access Control/流量访问控制 - 根据客户端的身份配置对特定pod和路由的访问，以将应用程序锁定到仅允许的用户和服务。
  - Traffic Specs/流量规范 - 定义流量的表示方式，基于每个协议的基础。 这些资源与访问控制和其他类型的策略协同工作，以在协议级别管理流量。
  - Traffic Split/流量分割 - 逐步引导各种服务之间的流量百分比，以帮助构建金丝雀推出。
  - Traffic Metrics/流量指标 - 暴露通用的流量指标，供dashboard和autoscaler等工具使用。

### Traffic Access Control

这组资源允许用户为其应用程序定义访问控制策略。这属于授权（authorization）。身份验证（Authentication）应该已经由底层实现处理并通过 subject 呈现。

SMI规范中的访问控制是附加的，默认情况下**拒绝所有流量**。

**TrafficTarget 规范**

`TrafficTarget` 将一组流量定义（规则）与分配给一组pod的服务标识相关联。通过引用的TrafficSpecs和源服务标识列表来控制访问。拥有引用的服务标识的pod在调用目标时，如果目标在其中定义的某个路由上，则允许访问。尝试连接却不在定义的源列表中的任何pod将被拒绝。位于已定义列表中的pod，如果尝试连接不在TrafficSpec列表中的路由，将被拒绝。

访问是基于服务标识来控制的，目前分配服务标识的方法是使用Kubernetes service account，其他标识机制的支持将在稍后的规范中处理。

规格是 traffic specs，定义特定协议的流量如何表示。根据目标提供服务的流量，种类可能会有所不同。在以下示例中，`HTTPRouteGroup` 用于提供基于HTTP 流量的应用程序。

要了解这一切是如何组合在一起的，首先要为某些流量定义路由。

```yaml
apiVersion: v1beta1
kind: HTTPRouteGroup
metadata:
  name: the-routes
matches:
- name: metrics
  pathRegex: "/metrics"
  methods:
  - GET
- name: everything
  pathRegex: ".*"
  methods: ["*"]
```

在这个定义中，有两个Route：metrics 和 everything。常见的用例时限制 `/metrics` 只能被 Prometheus 抓取。要定义此流量的目标，需要使用 TrafficTarget。

```yaml
---
kind: TrafficTarget
apiVersion: access.smi-spec.io/v1alpha1
metadata:
 name: path-specific
 namespace: default
destination:
 kind: ServiceAccount
 name: service-a
 namespace: default
 port: 8080
specs:
- kind: HTTPRouteGroup
  name: the-routes
  matches:
    - metrics
sources:
- kind: ServiceAccount
  name: prometheus
  namespace: default
```

## SMI实现机制

### 技术概述

SMI被指定为Kubernetes自定义资源定义（CRD）和 Extension API Server 的集合。 这些API可以安装到任何Kubernetes集群上，并使用标准工具进行操作。 API要求SMI 供应商执行某些操作。

要激活这些API，SMI 供应商将在Kubernetes集群中运行。对于启用配置的资源，SMI 供应商会体现其内容并配置在群集中的供应商组件以实现其所要求的行为。对于extension API，SMI 供应商将从内部类型转换为API期望返回的类型。

这种可插拔接口的方式类似于其他核心Kubernetes API，如 NetworkPolicy，Ingress 和 CustomMetrics 。


## 参考资料


- [smi官方网站](https://smi-spec.io/)
- [smi-spec项目@github ](https://github.com/deislabs/smi-spec)
- [Interoperability with the new Service Mesh Interface](https://www.redhat.com/en/blog/interoperability-new-service-mesh-interface)
- [意外：Servicemesh Interface（SMI）](https://blog.fleeto.us/post/servicemesh-interface/)
- [Hello Service Mesh Interface (SMI): A specification for service mesh interoperability](https://msft.today/hello-service-mesh-interface-smi-a-specification-for-service-mesh-interoperability/): 来自微软的博客，比较权威，本文很多内容是援引自此文
-  [Service Mesh Interface (SMI) and our Vision for the Community and Ecosystem](https://medium.com/solo-io/service-mesh-interface-smi-and-our-vision-for-the-community-and-ecosystem-2edc7b728c43)：作者 [Idit Levine](https://medium.com/@idit.levine_92620)，是初创公司 solo.io 的创始人兼CEO，本文同样大量援引此文的内容

