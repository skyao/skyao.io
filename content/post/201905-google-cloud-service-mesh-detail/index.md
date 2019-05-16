+++
title = "Google Cloud Service Mesh详细介绍（未完成）"

date = 2019-05-13
lastmod = 2019-05-13
draft = false

tags = ["服务网格"]
summary = "Google Cloud Service Mesh详细介绍"
abstract = "Google Cloud Service Mesh详细介绍"

[header]
image = "headers/post/201904-microservice-anti-patten.jpg"
caption = ""

+++

备注：Google Cloud Service Mesh 的资料实在太少太少，这个文章没法完成，先暂时整理到这吧

-----

Google Cloud 网站上对 Google Cloud Service Mesh 的定义

> The fully managed service mesh for your complex microservices architectures.
> 
> 适用于复杂微服务架构的全托管式服务网格。

## Google Cloud Service Mesh推出的背景

Google Cloud Service Mesh 推出的背景是微服务越来越普及，但是在微服务的过程中，我们发现：


- 微服务架构具有各种各样的优势，但同时也带来了诸多挑战。
- Istio 带来了各种能力和便利，但是Istio本身的复杂度也是一种挑战
- 借助 Google 的全托管式服务网格 Google Cloud Service Mesh (GCSM)，可以管理复杂的环境并获享其承诺的所有优势。

就这样一步一步走来，走到了Google Cloud Service Mesh：Google Cloud Service Mesh 提供全托管式平台，可简化服务的运营（从流量管理和网格遥测，到确保服务间通信的安全），从而极大地减轻运营团队和开发团队的工作负担。

### Istio on GCP

2018年底，GKE上线一键集成Istio，在 GKE 管理控制台上"Enable Istio"。提供遥测、日志、负载均衡、路由和mTLS 安全能力。

## Google Cloud Service Mesh的特性

以下信息来自 Google Cloud Service Mesh 的官网介绍：

- 零操作 Stackdriver

  通过与 Stackdriver 集成，GCSM 提供了各种各样的监控、日志记录和跟踪功能。GCSM 还允许您按服务来监控服务等级目标 (SLO)。您可以为延迟时间和可用性设置 SLO 目标，之后 Stackdriver 会自动生成相关图表，跟踪您在一段时间内的遵从情况，并显示最终表现与“错误预算”的对比情况。

- 无缝身份验证和加密

  您可以通过 mTLS 异常轻松地对传输进行身份验证。通过一键安装 mTLS 或以渐进方式逐步实现 mTLS，您可以确保服务间通信以及最终用户与服务之间通信的安全。

- 灵活授权

  借助简单易用、基于角色的访问权限控制 (RBAC) 功能，确定哪些人可以访问网格中的哪些服务。您可以为用户指定权限，然后在所选级别（从命名空间到用户）授予其访问权限。

- 精细化流量管理

  GCSM 将流量与基础架构扩缩分隔开来，并提供了许多流量管理功能，包括 A/B 测试、Canary 部署和逐步发布机制所依赖的动态请求路由，所有这些功能都独立于应用代码之外。

- 开箱即用的故障恢复功能

  GCSM 提供了多项开箱即用的关键故障恢复功能，这些功能可在运行时动态配置，其中包括超时、断路器、主动运行状况检查和重试次数限制。

- 易于配置的故障注入功能

  即使拥有可靠的故障恢复功能，仍有必要测试网格的弹性，因此我们引入了故障注入功能。您可以轻松配置延迟时间，中止要注入到请求且符合某些条件的故障，甚至限制允许发生故障的请求百分比。

- 负载平衡

  从下面这三种方案中选择：轮换（按轮换顺序选择运行状况良好的各个上游主机）；随机（由随机负载平衡器随机选择一个运行状况良好的主机）；以及加权最低请求数量负载平衡。

- 安全性数据分析

  流量加密、审核及精细的访问权限政策有助于缓解数据、端点、通信和平台所面临的内部及外部威胁。

## 分析

从描述上看，除了完全托管和与 Stackdriver 集成外，和开源版本的 Istio 功能并无大的不同。

需要更多的资料，等待后续更新。

## 参考资料

- [service mesh @ google cloud](https://cloud.google.com/service-mesh/): google cloud service mesh 官方网站
- [Google Integrates Istio Service Mesh into Kubernetes Service](https://thenewstack.io/google-integrates-istio-service-mesh-into-kubernetes-service/): 2018年底，Google将Istio Service Mesh集成到Kubernetes服务中