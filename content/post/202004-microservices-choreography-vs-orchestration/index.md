+++
title = "[译] 微服务编舞与编排：编舞的好处"

date = 2020-04-01
lastmod = 2020-04-01
draft = false

tags = ["Istio"]
summary = "Microservices Choreography vs Orchestration: The Benefits of Choreography"
abstract = "Microservices Choreography vs Orchestration: The Benefits of Choreography"

[header]
image = "headers/post/202003-multi-runtime-microservice-architecture.jpg"
caption = ""

+++

英文原文来自 [Microservices Choreography vs Orchestration: The Benefits of Choreography](https://solace.com/blog/microservices-choreography-vs-orchestration/)，作者 [ Jonathan Schabowsky](https://solace.com/blog/author/jonathan-schabowsky/) 。 

------

微服务架构（一种软件设计范式，将应用程序和业务用例拆分为一组可组合的服务）为企业组织带来了许多技术收益。首先，它们小巧，轻量且易于实现。其次，它们实现了可重用性，从而降低开发或更改应用程序的成本，确保资源的有效利用，并易于按需扩展应用程序。从高层次上讲，有两种方法可以使微服务共同实现一个通用目标：编舞和编排。

编排（Orchestration）需要主动控制所有元素和交互，就像指挥者家指挥乐团的音乐家一样，而编舞则需要建立一种模式或惯例，微服务会跟随音乐起舞，而无需监督和指示。

![](images/Orchestration-VS-Choreography.png)

微服务的采用正在迅速增长，这是由 Dimensional Research 代表 LightStep 进行的 [一项最新研究](https://siliconangle.com/2018/05/02/new-study-shows-rapid-growth-microservices-adoption-among-enterprises/) 证明的。该研究发现，几乎所有接受调查的部署过微服务的高级研发利益相关者都希望微服务成为其默认的应用架构。

研究还指出，微服务的实现还有很多许多挑战 – 很多与微服务如何相互交互来实现业务成果有关。在微服务编舞与编排之间进行选择，将影响到服务在后台无缝运行的方式，以及您是成功构建出微服务架构，还是分布式单体。

## 编排如何杀死微服务并创建分布式单体

在乐团中，每个音乐家都在等待指挥家的指令。他们每个人都是演奏乐器的专家，无论是小提琴，低音鼓还是单簧管，他们都久经训练，并拥有活页乐谱 - 但他们还是会在没有指挥的情况下集体迷失。

![](images/Orchestration-300x300.png)

在编排中，服务控制器处理微服务之间的所有通信，并指导每个服务执行预期的功能。在我们的交响乐示例中，功能是“演奏音乐”。

### 微服务编排的缺点

[编排的一个缺点](https://www.youtube.com/watch?v=fvXkN5cFMFY&t=32s) 是控制器需要与每个服务直接通信并等待每个服务的响应。现在，这些交互是在网络上发生的，调用会花费更长的时间，并且会受到下游网络和服务可用性的影响。

在较小的环境中，这可能会工作很好，但是当有数百甚至数千个微服务时，事情就会分崩离析。您基本上已经创建了一个分布式的单体应用程序，它比过去的应用程序更慢，更脆弱！就像指挥家会失去有效管理大型乐团的能力一样，因为每个音乐家都在等待个别的关注，因此要求服务控制来管理这么多微服务是不可行的。

#### 紧耦合

编排微服务时，您会发现它们彼此高度依赖 - 当它们同步时，每个服务必须显式接收并响应请求以使整个服务正常工作，任何时候的失败都可能使流程停止。

当我们谈论企业环境中的微服务时，有时将数千个微服务应用于单个业务功能。在这种规模下，一对一交互根本无法满足业务需求。















