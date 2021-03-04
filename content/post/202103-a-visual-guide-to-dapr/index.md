+++
title = "[译] Dapr可视化指南"
date = 2021-03-04
lastmod = 2021-03-04
draft = false

tags = ["Dapr"]
summary = "文章内容比较浅显易懂，适合简单阅读以对Dapr有个初步了解。最大的亮点是 Dapr 的概述大图，很好，很萌。"
abstract = "文章内容比较浅显易懂，适合简单阅读以对Dapr有个初步了解。最大的亮点是 Dapr 的概述大图，很好，很萌。"

[header]
image = ""
caption = ""

+++

> 译者注：原文来自 Dapr 官方博客 [A visual guide to Dapr](https://blog.dapr.io/posts/2021/03/02/a-visual-guide-to-dapr/)，文章内容比较浅显易懂，适合简单阅读以对Dapr有个初步了解。最大的亮点是那张 Dapr 的概述大图，很好，很萌，作者 [Nitya Narasimhan](https://sketchthedocs.dev/visual-azure/) 是个很会画图的大眼萌妹子。

作为微软开发者关系部 Cloud Advocacy 团队的一员，我有一个独特的福利，那就是可以从那些在使用和开发方面拥有实际专业知识的人那里听到很多不同的技术和解决方案。因此，当我听到我的开源宣传团队的同事们在和 "云原生 "和 "微服务" 一起使用 Dapr 这个名字时，我很感兴趣。

然后，我很高兴地发现 Dapr 代表 "Distributed Application Runtime/分布式应用运行时"，并在本月早些时候 [刚刚达到生产就绪的 v1.0 状态](https://blog.dapr.io/posts/2021/02/17/announcing-dapr-v1.0/)。我想知道关于它的一切。值得庆幸的是，Dapr有大量的文档来帮助我们入门。所以，当我想学习新的东西时，我做了我经常做的事情——我把学到的东西浓缩成一张大图，一张草图。现在，我想和你分享我的初步学习成果!

## 大图

我之前曾说过。和 65% 的视觉学习者用户一样，我发现，在我深入了解细节之前，将关键信息记录在一张纸上可以有助于把握大局。不仅能让我更好地了解该技术的各个方面，而且还能将其与其他可能与上下文相关的想法或概念 "联系起来"。所以，让我先分享一下 sketchnote（见下图）。你可以在 [云技能:Sketchnotes网站](https://cloud-skills.dev/) 下载一个更高分辨率的版本，并查看 [Visual Azure 博客](https://sketchthedocs.dev/visual-azure/posts/visual-guide-to-sse/)，以了解其他云计算技术的可视化指南。

![](images/DAPR-1-Overview.png)

## 主要收获

上面的概述图片涵盖了很多领域，但以下是我总结的要点。

### 什么是Dapr？

Dapr 是 Distributed Application Runtime 的缩写。它是一个可移植的、事件驱动的运行时，使应用开发者可以轻松构建弹性的无状态和有状态应用，而这些应用可以运行在云和边缘环境上。更重要的是，Dapr 支持多种编程语言和开发者框架，为我们提供了一个快速体验和使用的起点。你可以在 [Dapr 概述文档](https://docs.dapr.io/concepts/overview/) 中获得更多细节。

### 为什么使用Dapr？

许多应用开发者都有传统的3层（客户端-服务器-数据库）架构的经验。然而，云原生系统依赖于松耦合的系统和微服务架构，旨在拥抱大规模、快速变更和弹性运维。现在，开发人员面临着一系列的全新挑战，如发现（和调用）微服务、管理密钥以及故障后恢复状态。

Dapr 提炼了最佳实践，将微服务构建成独立、开放的"[构建块](https://docs.dapr.io/concepts/overview/?WT.mc_id=mobile-17439-ninarasi#microservice-building-blocks-for-cloud-and-edge)"，然后暴露 API 以便于集成和清洗的分离关注点。开发者只需使用这些块中所需的子集，逐步构建，就能很快让他们的应用启动并运行。

### Dapr如何工作？

Dapr 以 [sidecar 架构](https://docs.dapr.io/concepts/overview/?WT.mc_id=mobile-17439-ninarasi#sidecar-architecture) 的形式暴露其 API 。实际上，Dapr 可以在自己的容器或进程中与主应用程序一起运行。您的应用程序不需要将 Dapr 集成到其核心中，而是可以通过 HTTP 或 gRPC 调用构建块 API。这清晰的分离了应用程序逻辑与微服务支持服务，更容易扩展您的解决方案 —— 从自托管（开发）到云托管（虚拟机或 Kubernetes）和边缘部署。

虽然您可以简单地使用手动制作的 HTTP 或 gRPC 调用来访问这些 API，但您也有一套丰富的 [特定语言 SDK](https://docs.dapr.io/developing-applications/sdks/?WT.mc_id=mobile-17439-ninarasi)，为你提供语言优化的类型化 API，更容易集成和测试。目前支持的语言 SDK 包括 C++、Go、Java、JavaScript、Python、PHP、Rust 和 .NET! 请注意，Dapr 本身是语言无关的，它提供了一个默认的 RESTful HTTP API，如果你喜欢的语言 SDK 还不支持，你可以直接调用。

### 还应该知道什么？

只有三件事：

- **Dapr v1.0 已经做好了生产准备**!  Dapr有几个早期采用者，v1.0版本更加注重性能、安全、高可用性和一致性等方面。请 [在此阅读该版本的亮点](https://blog.dapr.io/posts/2021/02/17/announcing-dapr-v1.0/#release-highlights?WT.mc_id=mobile-17439-ninarasi)。
- **Dapr 是开源的**，您可以在 [Github](https://github.com/dapr)上找到核心运行时代码、文档、快速开始等，并 [欢迎社区贡献](https://docs.dapr.io/contributing/?WT.mc_id=mobile-17439-ninarasi)。Dapr [Discord 服务器](https://aka.ms/dapr-discord) 和定期的 [社区会议](https://github.com/dapr/community#community-meetings) 是与社区互动的好方法!
- **Dapr 生态系统正在成长**! 有70多个 [组件](https://docs.dapr.io/concepts/components-concept/) 是由社区贡献的，所以 Dapr 可以帮助您的应用程序与广泛的技术集成，也使它在多云和混合云场景下有非常好的可移植性。

入门最简单的方法是通过这个 [入门教程](https://docs.dapr.io/getting-started/?WT.mc_id=mobile-17439-ninarasi) 设置您的本地开发环境（自托管模式），并探索提供的quickstart，用代码学习核心概念！不要忘了关注@daprdev的Twitter，以获得更新的消息。不要忘记在 Twitter 上关注[@daprdev](https://twitter.com/daprdev)，以获得更新和新闻的通知。






