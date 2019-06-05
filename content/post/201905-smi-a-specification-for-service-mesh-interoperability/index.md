+++
title = "[译] Hello Service Mesh Interface(SMI):服务网格互通性规范"

date = 2019-05-22
lastmod = 2019-05-22
draft = false

tags = ["SMI", "Service Mesh"]
summary = "我们很高兴的推出 Service Mesh Interface。SMI定义了一组通用可移植的API，为开发人员提供跨不同服务网格技术的互通性，包括Istio，Linkerd和Consul Connect。"
abstract = "我们很高兴的推出 Service Mesh Interface。SMI定义了一组通用可移植的API，为开发人员提供跨不同服务网格技术的互通性，包括Istio，Linkerd和Consul Connect。"

[header]
image = ""
caption = ""

+++

英文原文来自 [Hello Service Mesh Interface (SMI): A specification for service mesh interoperability](https://msft.today/hello-service-mesh-interface-smi-a-specification-for-service-mesh-interoperability/)

------

今天，我们很高兴的推出 Service Mesh Interface（SMI）。SMI定义了一组通用可移植的API，为开发人员提供跨不同服务网格技术的互通性，包括Istio，Linkerd和Consul Connect。SMI是一个开放项目，由微软，Linkerd，HashiCorp，Solo，Kinvolk和Weaveworks联合启动; 并得到了Aspen Mesh，Canonical，Docker，Pivotal，Rancher，Red Hat和VMware的支持。

多年来，网络架构的口头禅是让网络管道尽可能愚蠢，并在应用中构建智能。网络的工作是转发数据包，而加密，压缩或身份的任何逻辑都存在于网络端点内。互联网是以这个口头禅为前提的，运作得相当好。

但是，随着微服务，容器和像Kubernetes这样的编排系统的爆炸式增长，工程团队面临的问题是越来越多的网络端点需要进行安全，管理和监控。服务网格技术通过使网络更智能来提供解决此问题的方案。服务网格技术不再要求所有服务进行加密会话，授权客户端，发出合理的遥测，并在应用程序版本之间无缝转换流量，而是将此逻辑推入网络，由一组单独的管理API控制。

这是云原生生态系统中的流行模式。我们看到服务网格技术激增，许多供应商为应用程序开发人员提供了新的令人兴奋的选择。问题是转向网格技术的开发人员必须选择供应商并直接使用这些API编码。他们被锁定在服务网格实现中。如果没有通用接口，开发人员就会失去可移植性，灵活性，而且能力限制导致无法从广泛的生态系统中获益。

Service Mesh Interface提供：

- Kubernetes上网格的标准接口
- 基本功能集，用于最常见的网格用例
- 灵活性，随着时间的推移，支持新的网格功能
- 生态系统使用网格技术进行创新的空间

## SMI涵盖的内容

我们与HashiCorp，Buoyant，Solo和其他公司合作，为我们从企业客户那里获得的三大服务网格功能构建初始规范：

1. Traffic policy/流量策略 - 跨服务应用身份和传输加密等策略
2. Traffic telemetry/流量遥测 - 捕获服务之间的关键指标，如错误率和延迟
3. Traffic management/流量管理 - 在不同服务之间转移和加权流量

这只是我们希望通过SMI得到的起点。考虑到开发中有许多令人兴奋的网格功能，我们非常希望随着时间的推移不断发展SMI API，并期待通过新功能扩展当前规范。

## SMI如何运作

Service Mesh Interface背后的想法并不新鲜。它追随 Ingress，Network Policy 和 CNI 等现有Kubernetes资源的脚步。与Ingress或 Network Policy 一样，SMI不提供实现。相反，SMI规范定义了一组通用API，允许网格供应商提供自己的最佳实现。可以通过两种方式实现与SMI的集成。工具和网格供应商可以直接使用SMI API，也可以构建 Operator 以将SMI转换为原生API。

> “SMI是Linkerd实现服务网络民主化目标的一大进步，我们很高兴能够为更多Kubernetes用户提供Linkerd的简单性和性能。”——William Morgan，Linkerd维护者
>
> “接口的标准化对于确保跨技术和生态系统协作的最佳用户体验至关重要。凭借这种精神，我们很高兴能与微软和其他公司合作开发SMI规范，并已经通过Service Mesh Hub和SuperGloo项目提供了第一个参考实现。“——Solo.io创始人兼首席执行官Idit Levine说道。

## 生态系统友好

对于服务网格这样的早期技术，我们必须为生态系统创造空间，以进行创新并探索解决客户问题的不同方法。随着服务网格技术的不断发展，SMI提供的互通性将有助于与现有网格供应商集成的新兴工具和实用程序的生态系统。而不是单独与每个网格集成，像flagger和SuperGloo这样的工具可以与SMI集成，从而获得跨网格功能。

> VMware NSX Service Mesh 首席架构师 Sushil Singh表示：“服务网络的兴趣和动力已达到一个关键点——行业需要在一系列的标准上进行协作，以确保成功。” “服务网络为应用程序的未来提供了丰富的基础功能。现在是制定标准API的最佳时机，这些API可简化服务网格技术的使用和功能，从而实现健康的生态系统。VMware很高兴可以参与这项非常重要的工作”
>
> “客户和社区成员都在寻求一种方法来更好地标准化服务网格的配置和运维。随着Service Mesh Interface（SMI）的出现，我们认为这是一种很好的方法，可以帮助我们最大化Red Hat OpenShift客户选择的灵活度。这种灵活度让用户可以优先考虑功能而不纠结实现细节” —— Red Hat服务网络首席产品经理 Brian Redbeard Harrington说道。

## 加入对话

我们迫不及待地想看看Service Mesh Interface如何发展，欢迎大家加入对话。请访问[SMI网站](https://smi-spec.io/)。

