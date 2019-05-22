+++
title = "[译] Service Mesh Interface (SMI) 以及我们对社区和生态系统的愿景"

date = 2019-05-22
lastmod = 2019-05-22
draft = false

tags = ["SMI", "Service Mesh"]
summary = "服务网格生态系统正在兴起，众多的网格供应商和不同的用例需要不同的技术。所以问题来了：我们如何实现在不破坏最终用户体验的前提下促进行业创新？ Service Mesh Interface是使这一构想走向行业现实的重要一步"
abstract = "服务网格生态系统正在兴起，众多的网格供应商和不同的用例需要不同的技术。所以问题来了：我们如何实现在不破坏最终用户体验的前提下促进行业创新？ Service Mesh Interface是使这一构想走向行业现实的重要一步"

[header]
image = ""
caption = ""

+++

英文原文来自 [Service Mesh Interface (SMI) and our Vision for the Community and Ecosystem](https://medium.com/solo-io/service-mesh-interface-smi-and-our-vision-for-the-community-and-ecosystem-2edc7b728c43)，作者 [Idit Levine](https://medium.com/@idit.levine_92620)，是初创公司 solo.io 的创始人兼CEO。

------

服务网格生态系统正在兴起，众多的网格供应商和不同的用例需要不同的技术。所以问题来了：我们如何实现在不破坏最终用户体验的前提下促进行业创新？通过以一组标准API达成一致，我们可以提供互操作性，并在不同网格以及为这些网格构建的工具之上维持最终用户体验。

今天发布的 Service Mesh Interface（SMI）是使这一构想走向行业现实的重要一步。

SMI 是在 Kubernetes 上运行服务网格的规范。它定义了由各种供应商实现的通用标准。这使得最终用户的标准化和服务网格供应商的创新可以两全其美。SMI 实现了灵活性和互操作性。

### SMI最大限度地降低复杂度，同时最大化服务网格的优势

不同服务网格的复杂度和差异使得难以研究和运营单个解决方案，更不用说多个解决方案。为了让服务网格的采用变得简单而平滑，Solo.io 正在与 Microsoft 和其他公司合作，对接口进行标准化，以确保优异的用户体验，以及生态系统在实现创新时的一致性和互操作性。

**SMI负责与网格相关的关键功能**，包括加密，遥测和跟踪。启动这些功能就像按开关一般简单，完全不需要复杂的配置步骤。

**SMI将简化以尝试不同的网格并在它们之间进行迁移。** 标准接口和API可以快速无痛地从一个网格转换到另一个网格，以防止网格供应商锁定。随着生态系统的快速发展，众多网格供应商和最终用户希望拥有改变想法的灵活性。

**SMI对生态系统友好，允许最终用户使用相同的工具集。**一致的API让为一个网格构建的产品可以与另一个符合规范的网格互操作，最终用户可以因此维护一致的工作流程。

### SMI 在 Solo.io

在Solo.io，我们去年开始了这个多网格愿景之旅，开源了[**SuperGloo**](https://github.com/solo-io/Supergloo)项目，这是一个抽象层，统一并自动化编排任意服务网格。SuperGloo 提供了一个简单的API，可以安装并运营来自一个或多个供应商的单个或多个集群网格。

上周，我们通过 [**Service Mesh Hub**](https://servicemeshhub.io/) 的发布继续这一愿景，Service Mesh Hub 是第一个用于最终用户、社区和生态系统进行构建、共享和协作的行业中心。Service Mesh Hub是一个统一的Dashboard，用于安装、发现和运维单个或一组网格，以及在其上运行的服务和扩展。Hub的扩展目录（Extensions Catalog）是社区和生态系统用于构建和共享工具的地方，这些工具特意设计来为网格环境带来附加功能。Service Mesh Hub构建于SuperGloo项目的基础之上并进行扩展。

随着今天的发布，SuperGloo和Service Mesh Hub已经更新以支持SMI规范，并且是第一个可用的参考实现。

> 备注：这里有一个视频，由于原文所在的 medium.com 拒绝直接链接视频，所以只能请读者通过访问英文原文页面观看视频。（注意 medium.com 需要科学上网）
> 
> 或者直接访问 [youtube](https://www.youtube.com/watch?time_continue=4&v=SkPXlW1M5No)

多网格的愿景并未完成，请在Solo.io上与我们联系，了解我们接下来要做什么。

