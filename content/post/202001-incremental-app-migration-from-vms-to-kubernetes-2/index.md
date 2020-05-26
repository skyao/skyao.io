+++
title = "[译] 从VM到Kubernetes的渐进式应用迁移(2) - 陷阱，流水线和避免复杂性"

date = 2020-01-27
lastmod = 2020-01-27
draft = false

tags = ["Integration"]
summary = "实施持续交付并避免常见陷阱和反模式的迁移准则。"
abstract = "实施持续交付并避免常见陷阱和反模式的迁移准则。"

[header]
image = ""
caption = ""

+++

英文原文来自 [Part 2: Incremental App Migration from VMs to Kubernetes — Pitfalls, Pipelines, and Avoiding Complexity](https://blog.getambassador.io/incremental-app-migration-from-vms-to-kubernetes-planning-and-tactics-5ffc18c151e)，作者 [Daniel Bryant](https://blog.getambassador.io/@danielbryantuk)。

> 备注：快速翻译（机翻+人工校对，没有精修），质量不高，一般阅读可以，不适合传播，谢绝转载。

------

现代软件系统的核心目标之一是使应用与运行它们的基础设施解耦。这可以带来许多好处，包括：工作负载可移植性，与云AI/ML服务的集成，降低成本，以及改进/委派安全性的特定方面。容器和编排框架（如Kubernetes）的使用可以使应用的部署和执行与底层硬件解耦。

在本系列的[前一篇文章中](https://blog.getambassador.io/routing-in-a-multi-platform-data-center-from-vms-to-kubernetes-via-ambassador-47bbe658683c)，我探讨了如何使用应用现代化程序来开始技术之旅：通过在系统边缘部署 Ambassador API Gateway 并在现有的基于VM的服务和新部署的基于Kubernetes的服务之间路由用户流量。

第二篇文章以此为基础，概述了如何计划迁移，还提供了有关容器化工作负载和一些网络注意事项的指南。本系列的下一篇文章将探讨如何使用服务网格（例如HashiCorp的 [Consul](https://www.consul.io/) ）在所有平台类型之间无缝路由服务到服务的通信，而不管您的应用是否已容器化。

## 计划迁移：常见的陷阱

我将假设您已经因为 [现代化应用程序堆栈](https://www.infoq.com/articles/api-gateway-service-mesh-app-modernisation/) 的好处而被吸引，但是有一些警告需要提前说明：

- **您不能指望在一夜之间将您的堆栈迁移。**在典型的现有（旧版/传统）堆栈中，存在太多的活动组件和太多的复杂性。任何迁移都需要以零散的方式进行计划和实施，并且计划和基础设施必须足够灵活以适应变化，例如，如果一个团队决定明年将继续在VM上运行其应用程序，但也想利用新的SSO身份验证或速率限制保护。您的迁移必须具有弹性，并能够适应您不可避免的会遇到的问题。
- **您不应该计划大爆炸式的云迁移。**即使对于IT资产相对较小的团队，以大爆炸的方式更新几乎所有内容所涉及的风险也过高，更不用说更改整个基础基础架构了。您的迁移必须支持渐进式部署。
- **您将必须确保所有团队（开发人员和运营人员）都了解新技术，并相应地更新他们共享的思维模型。**传统上，运维可能会将基础设施平台视为由他们完全控制的计算节点和3/4层网络组成。通常，系统内组件标识的概念被认为是IP地址和端口。同时，开发人员通常认为底层平台基础设施的配置和通信属性（例如服务发现，安全性和速率限制）是“其他人的问题”。向云技术的迁移必须确保每个人都接受共享的自助服务平台的概念，系统身份基于服务身份，并且开发人员和运维人员共同工作以配置应用的运行时通信属性。

## 迁移策略

鉴于上述要求，现在让我们看一下如何实现这一点的几种策略。

### 容器打包

我去年在DockerCon EU上的“ [使用Docker容器和Java进行持续交付：好的，坏的和丑陋的](https://www.youtube.com/watch?v=hJkhPP2OLA8&list=PLkA60AVN3hh_DVyQ13qGheO_Jg7jcAPcv&index=37) ”中谈到了将现有的“继承”应用封装在容器中的挑战。演讲的重点是Java平台，但是对于其他语言堆栈应该也有用。

如果您已订阅Docker Enterprise，那么Docker团队将提供几种工具来[自动将现有.NET应用程序打包](https://blog.docker.com/2019/05/5-reasons-to-containerize-production-windows-apps-on-docker-enterprise/)到Docker容器中。也有其他组织（例如Google）推出了[Jib容器构建工具的计划](https://cloud.google.com/blog/products/gcp/introducing-jib-build-java-docker-images-better)。CloudBees和Red Hat团队分别通过其[Jenkins X](https://jenkins.io/projects/jenkins-x/)和[OpenShift](https://www.openshift.com/)工具提供了buildpack样式集成，可帮助自动为现有应用生成Dockerfile。在先前的DockerCons上已经进行了演示，其中将 [Cloud Native Application Bundle（CNAB）之](https://cnab.io/) 类的技术与CLI工具相结合，也可以自动打包应用程序。

### 调整您的交付渠道

容器化现有应用可能需要一些Shell脚本魔术，但是从根本上讲，完成此任务的方法是公式化的-了解您的应用现在如何运行，并将其复制到容器中。最大的挑战通常是验证应用在各种使用情况下是否可以正常运行。要执行此质量保证，通常需要增强交付流水线，或者如果您尚未建立，则需要创建交付流水线。像前面提到的Jenkins X这样的交付流水线工具将在这里提供帮助，并且还有各种各样的开源和商业产品，例如[CircleCI](https://circleci.com/blog/using-circleci-workflows-to-replicate-docker-hub-automated-builds/)，[GoCD](https://docs.gocd.org/current/gocd_on_kubernetes/designing_a_cd_pipeline/creating_a_test_pipeline.html)和[GitLab](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)。

我在DockerCon EU演讲中谈到了调整连续交付流水线以构建容器的过程，随附的[示例项目](https://github.com/danielbryantuk/oreilly-docker-java-shopping)提供了一些实际的演示。关键要点是确保针对容器运行的应用程序或服务执行所有组件级和服务集成测试。

![](images/pipeline.jpeg)

我已经看到一些组织像往常一样继续对应用二进制文件执行测试，然后将应用打包到容器中，作为流水线的最后一步。这种方法经常会导致问题，因为容器技术可以巧妙地更改基础设施的运行时特性，例如限制CPU时间或内存，与底层块存储区不同的I/O性能，或者没有通过 `/dev/random` 提供足够的熵来运行加密操作，例如令牌生成。

### 注意网络的复杂性

在本系列的下一篇文章中，我将演示如何使用Consul服务网格扩展本系列第一部分中包含的示例应用，该应用已部署在Google Cloud Platform VM和Kubernetes上。但是，值得一提的是，您将遇到的主要问题之一是需要[完全连接的网络](https://en.wikipedia.org/wiki/Network_topology#Fully_connected_network)，这通常意味着使用[平面网络](https://en.wikipedia.org/wiki/Flat_network)或使用一系列路由器或网关来桥接不同的网络。

有个别 Ambassador 的用户使用它来分割网络或加入现有的网段，并且 HashiCorp 和 Rancher 等其他组织正在致力于实现可以桥接多个集群的 [网关](https://www.hashicorp.com/blog/roadmap-preview-what-s-next-for-consul-service-mesh#gateways-to-bridge-multiple-clusters)，分别与 [Consul Gateways](https://www.hashicorp.com/blog/roadmap-preview-what-s-next-for-consul-service-mesh#gateways-to-bridge-multiple-clusters) 和 [Submariner结合](https://rancher.com/blog/2019/announcing-submariner-multi-cluster-kubernetes-networking/) 。

## 敬请关注

在有关应用迁移系列的第二篇文章中，我指出了当客户对应用进行现代化改造时，Datawire团队和我所看到的一些挑战。在下一篇文章中，我将介绍 Consul 服务网格的用法，并演示它如何与 Ambassador 集成，以简化基于VM的应用程序和基于容器的服务之间的过渡。

如有任何疑问，请通过网站或Twitter 上的 [@getambassadorio ](https://www.twitter.com/getambassadorio) [与我们联系](https://www.getambassador.io/contact)。

