+++
title = "[译] Traffic Director介绍：Google的服务网格控制平面"

date = 2019-04-28
lastmod = 2019-04-28
draft = false

tags = ["服务网格","Traffic Director"]
summary = "Traffic Director是Google Cloud Platform（GCP）完全托管的服务网格控制平面，可提供弹性，负载平衡和流量控制功能，支持跨区域的服务访问，还支持自动伸缩。"
abstract = "Traffic Director是Google Cloud Platform（GCP）完全托管的服务网格控制平面，可提供弹性，负载平衡和流量控制功能，支持跨区域的服务访问，还支持自动伸缩。"

[header]
image = ""
caption = ""

+++

> 备注：英文原文来自 InfoQ网站文章 [Introducing Traffic Director: Google's Service Mesh Control Plane](https://www.infoq.com/news/2019/04/google-traffic-director)

在 Google Cloud Next 19上，服务网格的控制平面 [Traffic Director](https://cloud.google.com/traffic-director/) 宣布发布 beta 测试版。Traffic Director是Google Cloud Platform（GCP）完全托管的服务网格控制平面，可提供弹性，负载平衡和流量控制功能，如金丝雀部署和A/B测试。

Traffic Director 为 [服务网格数据平面](https://www.infoq.com/articles/vp-microservices-communication-governance-using-service-mesh) 中的代理提供流量配置和控制选项。"数据平面"由客户端代理组成，客户端代理通常作为进程外"Sidecar"与现有服务一起部署，并负责执行网络级别操作并观察所有的入站和出站流量。使用开源 [Envoy xDS v2 API](http://github.com/envoyproxy/envoy/blob/32e4d286668731594eb5c81ed664bd144d8d2d88/api/XDS_PROTOCOL.md))（Google称为“xDSv2”）可使 Traffic Director 与任何兼容代理（如Envoy）一起运行。

Traffic Director 支持基于VM和容器化的服务，并为跨多个区域中的VM和群集提供全局负载均衡。通过向服务代理提供健康检查、路由和后端信息，Traffic Director可 [优化全局流量分配](https://cloud.google.com/blog/products/networking/traffic-director-global-traffic-management-for-open-service-mesh)，并将流量发送到最近可以的服务。使用Traffic Director，用户可以在多个区域中部署集群，如果离原始请求最近的集群发生健康状态下降，则流量将定向到最近的可用集群。

![](images/td-global-lb.svg)

*Traffic Director全局负载均衡*

作为负载均衡解决方案的一部分，Traffic Director下放对每个服务的健康检查需求给单个代理，通过这种方式来集中进行服务健康（因为需要的请求数量将相对于服务数量呈平方关系）。聚合的服务健康信息通过  [Envoy Endpoint Discovery Service (EDS) API](http://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/eds.proto#envoy-api-file-envoy-api-v2-eds-proto) 从集中式存储分发到每个代理。

> 译者注：如果由服务的调用方在客户端进行服务健康检查，则n个服务都需要对剩下的 n-1 个服务进行连接和检查，数量级为 ` n * n` 。 使用 Sidecar 只需要对服务进行1:1的检查，然后汇总到控制平面，再分发到其他服务。

Traffic Director还监视代理报告的负载，以确定何时需要进行自动扩展。当负载增加时，Traffic Director 会 [通知 Autoscaler](https://cloud.google.com/blog/products/networking/traffic-director-global-traffic-management-for-open-service-mesh) 并等待它扩展到所需的大小，通过减少伸缩过程中的步骤数来最小化流量峰值响应时间。这种按需驱动的自动扩展减少了预热或联系云提供商的需求。

Traffic Director是一个完全托管的GCP服务，在GA为企业准备就绪时，将具有 [99.99％ 的SLA保证](https://cloud.google.com/compute/sla)。Traffic Director配置允许用户通过将操作（例如重写，重定向和header转换）应用于HTTP匹配规则来设置自定义流量控制策略。[据谷歌称](https://cloud.google.com/traffic-director/docs/traffic-director-concepts)，Traffic Director的优势包括简化的服务流量管理，服务弹性以及跟随用户应用程序增长的无缝扩展。

Traffic Director目前处于测试阶段，不受SLA或弃用策略的约束，可能会有向后不兼容的更改。测试版目前[限定](https://cloud.google.com/traffic-director/docs/traffic-director-concepts)于支持HTTP流量和Google API，并且不支持Istio API。流量控制功能（如路由规则和流量策略）  [仅在Alpha中可用](https://services.google.com/fb/forms/trafficdirectoralphas/)。要开始使用测试版，请访问[Traffic Director设置指南](https://cloud.google.com/traffic-director/docs/setting-up-traffic-director)。