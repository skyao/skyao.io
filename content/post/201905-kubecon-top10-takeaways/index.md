+++
title = "[译] KubeCon EU 2019：十大要点"

date = 2019-05-31
lastmod = 2019-05-31
draft = true

tags = ["SMI", "Service Mesh"]
summary = "KubeCon EU 2019：十大要点"
abstract = "KubeCon EU 2019：十大要点"

[header]
image = ""
caption = ""

+++

英文原文来自 [KubeCon EU 2019: Top 10 Takeaways](https://blog.getambassador.io/kubecon-eu-2019-top-10-takeaways-123b5fcb30a8)，作者 [Daniel Bryant](https://blog.getambassador.io/@danielbryantuk)。

------

![](images/kubeconf.jpg)

我和Datawire团队已经回到了家乡，上周我们在巴塞罗那参加了[KubeCon和CloudNativeCon](https://events.linuxfoundation.org/events/kubecon-cloudnativecon-europe-2019/)。我们一起参加了KubeCon的六次会谈，他们在一个挤满了T恤衫的展台上工作，与几十名社区成员交谈，并参加了一些精彩的会谈。KubeCon EU提供了很多看点，我尝试在这篇博客文章中总结一些我的主要观察结果。

没有特别的顺序，这是我的十大要点：

1. 多平台和混合云（仍然）是一件事
2. 技术捆绑显著增加
3. 服务网格接口（SMI）公布：敬请期待
4. Istio的（不确定？）未来
5. Policy as Code 正在向上移动
6. Cloud Native DevEx仍然具有挑战性
7. 企业（仍）处于技术采用生命周期的早期
8. 内部部署Kubernetes是真实的（但具有挑战性）
9. 像牲口一样对待集群
10. 社区仍然是Kubernetes成功的核心

## 多平台和混合云（仍然）是一件事

有几个专题专门讨论了多云的主题（以及网络和安全的相关子主题），但我也观察到终端用户会谈中的许多介绍性幻灯片显示其基础设施/架构至少包括两个云供应商。在Datawire展位上，我们还进行了更多的对话（与之前的KubeCons相比），这些对话支持了这种转变为拥抱多云的重要转变。

毫无疑问，Kubernetes的成功让创建多云战略变得更加容易，因为Kubernetes为部署/编排提供了可靠的抽象。Kubernetes中的功能和API在过去两年中变得更加稳定，并且该平台被各个供应商广泛采用。此外，与存储管理和网络相关的功能已经变得更加成熟，并且在这些领域现在存在可行的开源和商业产品。谷歌高级软件工程师 Saad Ali 的“ [揭穿神话：Kubernetes存储很难](https://www.youtube.com/watch?v=169w6QlWhmo) ”的主题演讲引起了人们对存储的关注，以及“ [Kubernetes Networking：如何从零开始编写CNI插件](https://www.youtube.com/watch?v=zmYxdtFzK6s&list=PLj6h78yzYM2PpmMAnvpvsnR4c27wJePh3&index=303&t=0s) ”，作者是Twranlock的Eran Yanay ，这是一个很好的网络概述。

我的兴趣主要集中在Azure与现有的本地部署的结合上。我最近为InfoQ撰写了一篇文章，关于多平台部署与[应用程序现代化](https://www.infoq.com/articles/api-gateway-service-mesh-app-modernisation/) 的关联，从广义上讲，有三种方式：将云扩展到数据中心，如 [Azure Stack](https://azure.microsoft.com/en-us/overview/azure-stack/)，[AWS Outposts](https://aws.amazon.com/outposts/) 和 [GCP Anthos](https://cloud.google.com/anthos/); 使用像Kubernetes这样的平台，在多个供应商/云之间实现部署（编排）结构的同质化; 还有使用API Gateway和服务网格（类似 [Ambassador和Consul](https://www.consul.io/docs/platform/k8s/ambassador.html) ）的组合的来统一服务（网络）结构。

由于Datawire团队在API Gateway领域广泛开展工作，我们显然倾向于采用第三种方法的灵活性。这提供了从传统堆栈逐步安全地迁移到更加云原生运维方式的能力。来自HashiCorp的Nic Jackson和我在KubeCon上做了名为 “ [保护云原生通信，从终端用户到服务](https://www.youtube.com/watch?v=o1MJi54_R4o&list=PLj6h78yzYM2PpmMAnvpvsnR4c27wJePh3&index=179&t=114s) ” 的演讲。

## 技术捆绑显著增加

现在许多供应商提供成套的Kubernetes工具和附加技术。Rancher Labs团队发布[Rio “MicroPaaS”](https://rancher.com/blog/2019/introducing-rio/)引起了我的注意，Rancher最近发布了一系列有趣的东西。我在InfoQ上写了 [Submariner](https://www.infoq.com/news/2019/03/rancher-submariner-multicluster/) 多集群桥和 [k3s轻量级Kubernetes发行版](https://www.infoq.com/news/2019/03/rancher-labs-k3s-kubernetes/) 的摘要。我也热衷于探索 [Supergiant的Kubernetes Toolkit](https://supergiant.io/blog/supergiant-announces-the-release-of-new-supergiant-2-1-0-kubernetes-toolkit/) 以得到更多细节，这是一个“用于在云上自动部署和管理Kubernetes集群的实用程序集合”。

在企业领域，捆绑主要存在于存储，其中一个很好的例子是 [VMware的Velero 1.0](https://velero.io/velero-1.0-has-arrived/)（基于[从Heptio获得](https://techcrunch.com/2018/11/06/vmware-acquires-heptio-the-startup-founded-by-2-co-founders-of-kubernetes/)的“Ark”的初始工作），它允许工程师备份和迁移Kubernetes资源和持久卷。

在相关主题上，KubeCon上展示了更多的存储和数据管理的 Kubernetes Operators，例如 [CockroachDB](https://operatorhub.io/operator/cockroachdb)，[ElasticCloud](https://operatorhub.io/operator/elastic-cloud-eck) 和 [StorageOS](https://operatorhub.io/operator/storageosoperator)。Red Hat的Rob Szumski 在他的主题演讲中谈到了[运营商SDK和相关社区](https://www.youtube.com/watch?v=KPOEnFwspiY&list=PLj6h78yzYM2PpmMAnvpvsnR4c27wJePh3&index=101&t=0s)的演变，他还宣布了[运营商中心](https://operatorhub.io/)。运营商支持似乎是[Red Hat OpenShift](https://www.openshift.com/)企业捆绑的关键部分。

## 服务网状接口（SMI）公告：保持调整

在[Gabe Monroy的微软主题演讲中](https://www.youtube.com/watch?v=gDLD8gyd7J8)宣布[服务网状接口（SMI）](https://cloudblogs.microsoft.com/opensource/2019/05/21/service-mesh-interface-smi-release/)确实引起了不[小的轰动](https://twitter.com/search?q=kubecon%20smi&src=typed_query)。不可否认的是，服务网格空间最近一直很热，SMI旨在将核心功能整合到标准接口中，并提供“一组通用的可移植API，为开发人员提供跨不同服务网格技术的互操作性，包括Istio ，Linkerd和Consul Connect“。

Gabe的[舞台录制演示](https://www.youtube.com/watch?v=gDLD8gyd7J8&list=PLj6h78yzYM2PpmMAnvpvsnR4c27wJePh3&index=105&t=0s)突出了规范将关注的关键领域：流量策略 - 在服务中应用身份和传输加密等策略（通过[Consul](https://www.consul.io/)和Intentions 演示）; 交通遥测 - 捕获服务之间的错误率和延迟等顶线指标（通过[Linkerd](https://linkerd.io/)和SMI指标服务器说明）; 和交通管理-移和不同的服务之间的加权的业务（经由证明[Istio](https://istio.io/)，与Weaveworks' [举报者](https://github.com/weaveworks/flagger)）。

在这个竞争激烈的空间中定义接口的概念非常有趣，但在看了[SMI网站](https://smi-spec.io/)和相应的[规范之后](https://github.com/deislabs/smi-spec)，我想知道这种抽象是否倾向于功能的最低共同点（总是如此）我从Java社区流程的日子里知道，这些规范很难避免。这可能带来的危险是，虽然每个人都会实施规范，但供应商将通过自定义扩展提供最有趣的增值。

在与Datawire团队的其他成员进行了几次聊天之后，我想知道服务网格空间是否是“赢家最多”的市场，因此SMI最终会成为一些人的注意力，而另一种技术只会向前推进并捕获所有的价值（可以说就像Kubernetes在Mesos，Docker Swarm等方面所做的那样）。请继续关注，看看会发生什么！



