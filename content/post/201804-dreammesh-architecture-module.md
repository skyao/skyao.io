+++
title = "DreamMesh架构设计(3)-主要模块"

date = 2018-04-15
lastmod = 2018-04-15
draft = false

tags = ["DreamMesh"]
summary = "列出规划中的Dream Mesh主要功能模块，定好优先级和开发顺序。"
abstract = "列出规划中的Dream Mesh主要功能模块，定好优先级和开发顺序。"

[header]
image = "headers/post/201804-dreammesh-architecture-module.jpg"
caption = ""

+++

本文将列出规划中的Dream Mesh主要功能模块，给出蓝图，并定好优先级和开发顺序。


## 核心模块

在前文 [DreamMesh架构设计(1)-系统核心](../201804-dreammesh-architecture-core/) 中，列出了最核心的三个模块。

### 配置中心

配置中心包含三大块的内容：

1. 服务配置（优先级：高）
2. 业务配置（优先级：中）
3. 资源配置（优先级：低）

![](../201804-dreammesh-architecture-core/images/config-center.jpg)

服务配置和业务配置的具体实现包含三个层次的内容：

1. 一致性存储

  - 定义通用的配置数据访问接口（优先级：高）
  - 基于ETCD V3的第一个实现版本（优先级：高）
  - 桥接到其他的配置中心实现（优先级：低）

2. 配置中心服务

   - 实现配置中心的业务逻辑（优先级：高）
   - 对外暴露服务的协议实现
     - gRPC协议（优先级：高）
     - REST协议（优先级：低）
   - 提供的服务接口
     - 标准的CRUD接口（优先级：高）
     - 给应用特别定制的专用接口（优先级：高）
   - 通过配置数据通用接口访问底层数据（优先级：高）

3. 控制台/Console

   - 基本的配置管理
     - 服务配置管理（优先级：高）
     - 业务配置管理（优先级：中）
     - 资源配置管理（优先级：低）

### 注册中心

注册中心包含两大块：服务注册和服务配置。其中服务配置的实现包含在配置中心的开发中，这里只需要重用代码即可。

![](../201804-dreammesh-architecture-core/images/registry-center.jpg)

注册中心的具体实现同样包含三个层次的内容：

1. 一致性存储

  - 定义通用的服务注册数据访问接口（优先级：高）
  - 基于ETCD V3的实现版本（优先级：高）
  - 基于k8s 服务注册的实现版本（优先级：中）
  - 桥接到其他的服务注册的实现
  	- spring cloud的discoveryClient（优先级：中）
  	- consul（优先级：低）

2. 注册中心服务

   - 实现注册中心的业务逻辑（优先级：高）
   - 对外暴露服务的协议实现
     - gRPC协议（优先级：高）
     - REST协议（优先级：低）
   - 提供的服务接口
     - 标准的注册/注销/发现接口（优先级：高）
     - 给应用特别定制的专用接口（优先级：高）
   - 通过服务注册数据通用接口访问底层数据（优先级：高）
   - 支持连接其他注册中心交换数据（优先级：中）

### 服务治理中心

- 基本的服务注册管理（优先级：高）
- 基本的服务配置管理（优先级：高）
- 基于label的简单服务路由（优先级：中）
- 访问注册中心服务和服务配置服务的接口（优先级：高）

### 最基本的SDK

核心模块中的SDK暂时只实现一个最基本的基于gRPC的简单实现，功能只是简单的：

- 实现服务注册/配置读取
- 实现基本的负载均衡
- 实现语义化版本/服务路由
- 实现简单的重试

主要目标是提供给上面的配置中心/注册中心/服务治理中心使用，完成这些模块之间通讯，还有应用和这些模块的通讯。当然也可以用于服务间简单通讯。

### 目标

上述的四个模块实现之后，就可以得到一个最小范围的微服务体系，功能不多，但是端到端的流程已经可以跑起来。此时的应用，在配置中心/注册中心/SDK的配合下，已经具体基本的服务间通讯功能，同时通过服务治理中心能实现一些简单的服务治理功能：

![](../201804-dreammesh-architecture-core/images/application.jpg)

当然，这只是基石，在此之上，我们将进一步完善体系。

> 注： 后面的模块就不详细展开了。

## 引入Service Mesh

首先申明：Dream Mesh暂时不会选择自己重新实现一套Service Mesh，除非未来Istio和Conduit两个产品都出现令人无法满意的极端情况。

Dream Mesh选择在Istio和Conduit的基础上做进一步的完善和扩展。

### 打通Service Mesh和非Service Mesh

第一件事情，就是完成前文   [DreamMesh抛砖引玉(3)-艰难的过渡](../201802-dreammesh-brainstorm-transition/) 讨论的过渡方案，打通Service Mesh和非Service Mesh。

此时需要的完成的事情：

1. 可以兼容Istio和Conduit的服务注册实现
2. 可以连接Service Mesh和非Service Mesh下的服务注册
3. 可以将请求在Service Mesh和非Service Mesh之间转发

## 引入spring cloud

### spring cloud集成

将前面实现的配置中心和服务注册集成到spring cloud，这样普通spring cloud程序也可以使用Dream Mesh体系的配置中心/注册中心，然后可以通过服务治理中心进行基本的服务治理。

### spring cloud on service mesh

帮助将已有的spring cloud应用迁移到service mesh上，尽量减少代码的修改量，做到可以比较平滑的迁移。

### spring boot on service mesh

个人推崇的比较干净的应用开发模式，spring boot + service mesh，彻底抛弃spring cloud。

## 基于Service Mesh的扩展

### 基于Service Mesh的API Gateway

实现前文 [DreamMesh抛砖引玉(9)-API Gateway](../201803-dreammesh-brainstorm-gateway/) 设想的基于Service Mesh的API Gateway。

### 削峰填谷

为应用提供"削峰填谷"的功能，结合Service Mesh，可以做到对应用透明。

## 讨论和反馈

TBD：等收集后整理更新

## 后记

有兴趣的朋友，请联系我的微信，加入Dream Mesh内部讨论群。