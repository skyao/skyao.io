+++
title = "Service Mesh Interface详细介绍"

date = 2019-05-22
lastmod = 2019-05-22
draft = true

tags = ["SMI", "Service Mesh"]
summary = "Service Mesh Interface详细介绍"
abstract = "Service Mesh Interface详细介绍"

[header]
image = ""
caption = ""

+++

## SMI介绍

服务网格接口（Service Mesh Interface/SMI）是在Kubernetes上运行的服务网格的规范。 它定义了可由各种供应商实现的通用标准。 这使得最终用户的标准化和服务网格供应商的创新可以两全其美。SMI 实现了灵活性和互操作性。

### 目标

SMI API的目标是提供一组通用的，可移植的Service Mesh API，Kubernetes用户可以以供应商无关的方式使用这些API。通过这种方式，可以定义使用Service Mesh技术的应用程序，而无需紧密绑定到任何特定实现。

### 非目标

SMI项目本身不实现服务网格。SMI只是试图定义通用规范。同样，SMI不定义服务网格的具体范围，而是一个通用子集。 欢迎SMI供应商添加超出SMI规范的供应商特定扩展和API。 我们希望随着时间的推移，随着更多功能被普遍接受为服务网格的一部分，这些定义将迁移到SMI规范中。



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



- [smi-spec项目@github ](https://github.com/deislabs/smi-spec)

