+++
title = "[译] Google Cloud的Traffic Director - 介绍以及与Istio服务网格的关系"

date = 2019-05-05
lastmod = 2019-05-05
draft = false

tags = ["服务网格","Istio", "Mixer"]
summary = "多集群还是不多集群：使用Service Mesh进行集群间通信"
abstract = "多集群还是不多集群：使用Service Mesh进行集群间通信"

[header]
image = "headers/post/201904-microservice-anti-patten.jpg"
caption = ""

+++

> 备注：英文原文来自Medium网站博客文章 [Google Cloud’s Traffic Director — What is it and how is it related to the Istio service-mesh?](https://medium.com/cloudzone/google-clouds-traffic-director-what-is-it-and-how-is-it-related-to-the-istio-service-mesh-c199acc64a6d)，原作者为 [Iftach Schonbaum](https://medium.com/@iftachsc)，发布时间 2019-04-16

!![](images/traffic.jpeg)

对于最近跟进 Google Cloud 路线图的人来说，可能听说过Traffic Director。对于那些了解 Istio 的人来说，可能听起来有些重叠和混乱（特别是如果使用了最新的 GKE Istio 插件）。

在这篇文章中，我将介绍Traffic Director是什么，它与Istio服务网格有什么关系，以及对于那些已经在GKE上运行生产Istio网格的人来说意味着什么。

在这篇文章中，我不会讲述 Istio 或服务网格是什么。

------

Traffic Director是：

> “Enterprise-ready traffic management for open service mesh”…
>
> “用于开放式服务网络的企业级流量管理”......

它是用于服务网格的完全托管的控制平面，可以通过智能流量控制策略，在Kubernetes集群（托管或非托管）和虚拟机之间全局地控制流量。与任何其他服务网格控制平面一样，它控制网格内服务代理的配置。

Traffic Director拥有99.99％的SLA（需要在达到GA时，目前处于beta测试阶段），这意味着您可以管理网格配置，而无需担心控制平面的健康和维护。Traffic Director也在后台伸缩以适应网格的大小，因此您不必担心这一点。

概括的说，可以使用Traffic Director执行以下操作：

1. **复杂的流量管理**

    - 流量操纵，如拆分，镜像和故障注入
    - 智能部署策略，如易于使用的A/B和金丝雀
    - 请求操纵，如URL重写
    - 基于内容的路由，通过header，cookie等

2. **构建弹性服务**  - 使用单个IP和服务代理实现全局跨区域感知负载均衡，实现低延迟、最近端点访问，并在出现问题时故障转移到另一个端点。最近端点可以是同一zone的其他集群，不同zone或不同region。此外，在服务之间配置弹性功能，例如熔断器检测，解放开发人员。

3. **大规模的健康检查**  - 使用GCP管理的健康检查，取代网格内代理的健康检查，以减少网格大小相关的健康检查。

4. **现代化非云原生服务**  - 由于它也适用于VM，因此它允许您为遗留应用程序引入高级功能。

![img](images/global-lb.png)

全局负载均衡部署中的Traffic Director（cloud.google.com）

------

我们之间的 Istio 管理员可能跳起来说“这是一个托管的Istio控制平面”。那是因为Istio支持上面的许多功能。（更确切地说，是Istio使用的Envoy代理）。当然，使用Istio可以实现上述许多功能 - 但它将包括大量的管理工作（特别是在扩展到多个Kubernetes集群和VM时）。此外，控制平面和整个网格的维护也可能造成麻烦。

那么它确实是某种托管的Istio控制平面吗？嗯，不完全......可以说是以某种方式重叠。

让我简化一下......

------

Istio和 Google Cloud 的 Traffic Director 有几个地方不同。

### SLA和管理

Istio是一个开源项目，当包含在 Openshift 或 IBM Cloud Private 等产品中时，它们具有一些生产级支持，目前没有公共云完全托管的Istio服务。Istio的大多数公共云部署都是纯开源，非托管，非SLA部署 - 通常用官方的Istio helm chart 安装。

相反，Traffic Director拥有99.99％的SLA，是一项完全托管的服务。

### 控制平面

Istio有三个核心组件：**用于流量管理的Pilot**，**用于可观察性的Mixer**和**用于服务到服务安全的Citadel**。

Traffic Director 提供 GCP 托管的 Pilot 以及所提及的其他功能，如全局负载均衡和集中式健康检查。

### 缩放控制平面

在Istio中，控制平面组件（如Citadel，Mixer和Pilot）通过默认设置来用HPA（HorizontalPodAutoscalers）交付 - HAP是一个负责部署的自动伸缩的Kubernetes资源。您需要调整这些设置以适合Mesh，以备在需要时使用。您还需要指定 PodAntiAffinity 规则以确保控制平面跨越多个Kubernetes 节点。

使用Traffic Director，控制平面可以与网格一起缩放，无需担心。

### API

作为Beta版本，无法使用 Istio API 来配置 Traffic Director。可以使用GCP API进行配置。Traffic Director和Pilot都使用开放标准API（xDS v2）与服务代理进行通信。使用Istio API配置Traffic Director在Traffic Director的路线图中。

### 数据平面代理

Traffic Director使用开放式xDSv2 API与数据平面中的服务代理进行通信，从而确保您不会被锁定到专有接口。这意味着Traffic Advisor可以使用像Envoy这样的xDSv2兼容的开放服务代理。**值得注意**的是，Traffic Director仅使用Envoy代理进行了测试，并且在当前的beta版本中仅支持Envoy版本1.9.1或更高版本。

另一方面，Istio目前仅与Envoy一起[发售](https://github.com/nginxinc/nginmesh)，虽然有像[nginMesh](https://github.com/nginxinc/nginmesh)这样的项目，它们使用nginx作为边车代理运送Istio控制平面，但这是一个单独的项目。

值得一提的是，Envoy拥有领先的网状代理，专为服务网格而设计，具有高性能和低内存占用。

#### Sidecar注入和部署

在Istio和Traffic Director中，代理可以在Kubernetes部署（最终POD）和VM上。在VM上部署的两种情况下，都会为您提供多个脚本和文件来安装代理并使用控件对其进行配置。

对于Kubernetes工作负载，Istio开箱即用，具有自动注入机制（与MutatingAdmissionController 配合使用），当在标记为 自动注入的命名空间或使用专用POD注释创建时，它会自动将边车代理注入POD。

使用Traffic Director，您当前需要手动注入边车。并且还使用注释从服务创建NEG（[请参阅GCP网络端点组](https://cloud.google.com/load-balancing/docs/negs/)），以便可以将其作为服务添加到Traffic Director中。

由于创建[MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)和注入服务相对容易，我确信自动注入迟早会到达Traffic Director ...

#### **多簇网格**

在Istio中，为了跨越多个Kubernetes簇的网格，Istio提供了一个专用图表，名为istio-remote，用于扩展网格。我不会在这里看到。

由于Traffic Director是一个控制平面，它位于Kubernetes集群之外，并且无论从哪个集群添加Kubernetes工作负载，都没有特定的演练来跨越多个集群的网格。

#### 网格可观察性

今天，Istio推出了Kiali - 一个很好的网格可观察性，帮助我们的客户在微服务应用程序中调试应用问题。Kiali一直在不断发展，迅速发布新版本。

Traffic Director的特点是可以使用多个工具进行观察，包括[Apache Skywalking](http://skywalking.apache.org/)。

#### $ Pricing $

Istio是一个开源和免费的。目前，Traffic Director目前免费提供Beta版本。

------

#### “如果我已经在GKE上使用Istio操作生产网格怎么办？”

如上所述，Traffic Advisor是一个托管的Pilot（具有额外功能），它将支持Istio API进行管理。因此，如果您想要使用具有高SLA的完全托管的试用版替换您的集群内非托管试用版，它应该能够轻松选择更换。据我所知，将有适当的选择指示。

------

Traffic [Cloud](https://medium.com/@googlecloud)是[Google Cloud](https://medium.com/@googlecloud)最近发布的一项声明。由于它基于Istio的核心模式，谷歌是其主要贡献者之一，我预测它的美好未来。正是在所有公共云提供商宣布他们自己的Mesh解决方案的时候。

------

交通主管的路线图目前包括：

- 支持Istio的安全功能，如mTLS，RBAC（Istio RBAC）
- 可观察性整合
- 混合和多云支持
- 使用Istio API进行管理
- Anthos整合（见我在Anthos上的帖子）
- 与其他服务网格控制平面的联合

我希望这篇文章解决任何困惑或问题，如果没有联系我！