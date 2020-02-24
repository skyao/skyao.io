+++
title = "[译]使用Admiral的多集群Istio配置和服务发现"

date = 2020-01-07
lastmod = 2020-01-07
draft = true

tags = ["Istio"]
summary = "Istio多集群部署的配置自动化"
abstract = "Istio多集群部署的配置自动化"

[header]
image = ""
caption = ""

+++

在Intuit，我们阅读了博客文章 [《用于隔离和边界保护的多网格部署》](https://istio.io/blog/2019/isolated-clusters/)，并立即关联到该文章提到的一些问题。我们意识到，即使我们想要配置的只是单个的多集群网格，而不是博客文章中描述的多个网格的联邦，我们的环境也会遇到同样的非均匀命名问题。这篇博客文章介绍了我们如何使用 Admiral 来解决这些问题，Admiral 是 istio-ecosystem 下的一个开源项目，托管在 GitHub。

### 背景

使用Istio时，我们意识到多群集的配置很复杂，并且随着时间的推移会很难维护。因此，出于可伸缩性和其他运维原因，我们选择了 [使用复制控制平面的多群集Istio服务网格](https://istio.io/docs/setup/install/multicluster/gateways/#deploy-the-istio-control-plane-in-each-cluster) 中描述的模型。遵循此模型，在广泛采用Istio服务网格之前，我们必须解决以下关键需求：

- 服务DNS条目的创建与名称空间解耦，如 [多网格部署特性](https://istio.io/blog/2019/isolated-clusters/#features-of-multi-mesh-deployments) 中所述的。
- 跨多集群的服务发现。
- 支持 active-active 和 HA/DR 部署。我们还必须通过在离散集群中的全局唯一命名空间中部署服务来支持这些关键的弹性模式。

我们有超过160个Kubernetes集群，在所有集群中均具有全局唯一的命名空间名称。在此配置中，我们可以将相同的服务工作负载部署在不同区域中，在不同名称的命名空间中运行。结果，遵循 [多集群版本路由](https://istio.io/blog/2019/multicluster-version-routing) 中提到的路由策略，示例名称`foo.namespace.global`将无法在群集中使用。我们需要一个全球唯一且可发现的服务DNS，该DNS可以解析多个集群中的服务实例，每个实例都可以通过自己的唯一Kubernetes FQDN运行/寻址。例如，`foo.global`应同时解析为`foo.uswest2.svc.cluster.local`＆`foo.useast2.svc.cluster.local`if`foo`在两个名称不同的Kubernetes集群中运行。此外，我们的服务需要其他具有不同解析度和全局路由属性的DNS名称。例如，`foo.global`应该先在本地解析，然后再使用拓扑路由将其路由到远程实例，而`foo-west.global`and `foo-east.global`（用于测试的名称）应始终解析到相应的区域。

We have over 160 Kubernetes clusters with a globally unique namespace name across all clusters. In this configuration, we can have the same service workload deployed in different regions running in namespaces with different names. As a result, following the routing strategy mentioned in [Multicluster version routing](https://istio.io/blog/2019/multicluster-version-routing), the example name `foo.namespace.global` wouldn’t work across clusters. We needed a globally unique and discoverable service DNS that resolves service instances in multiple clusters, each instance running/addressable with its own unique Kubernetes FQDN. For example, `foo.global` should resolve to both `foo.uswest2.svc.cluster.local` & `foo.useast2.svc.cluster.local` if `foo` is running in two Kubernetes clusters with different names. Also, our services need additional DNS names with different resolution and global routing properties. For example, `foo.global` should resolve locally first, then route to a remote instance using topology routing, while `foo-west.global` and `foo-east.global` (names used for testing) should always resolve to the respective regions.


