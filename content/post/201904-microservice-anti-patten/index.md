+++
title = "译：微服务反模式"

date = 2019-04-10
lastmod = 2019-04-10
draft = false

tags = ["AppMesh"]
summary = "微服务领域的著名专家 Chris Richardson 在其博客上发表了微服务反模式序列文章，描述他在与全球众多客户合作时，观察到多种微服务采用的反模式。"
abstract = "微服务反模式序列文章翻译"

[header]
image = "headers/post/201904-microservice-anti-patten.jpg"
caption = ""

+++

微服务领域的著名专家 Chris Richardson 在其 [博客](http://chrisrichardson.net/blog.html) 上发表了微服务反模式序列文章，描述他在与全球众多客户合作时，观察到多种微服务采用的反模式，目前有四篇：

- [Microservices are a magic pixie dust anti-pattern](http://chrisrichardson.net/post/antipatterns/2019/01/07/microservices-are-a-magic-pixie-dust.html)
- [Anti-pattern: microservices as the goal](http://chrisrichardson.net/post/antipatterns/2019/01/14/antipattern-microservices-are-the-goal.html)
- [Microservices adoption anti-pattern - scattershot adoption](http://chrisrichardson.net/post/antipatterns/2019/02/25/antipattern-scattershot-adoption.html)
- [Microservices adoption anti-pattern - Trying to fly before you can walk](http://chrisrichardson.net/post/antipatterns/2019/04/09/antipattern-flying-before-walking.html)

![](images/cover.jpg)

许多企业应用程序都是庞大而复杂的巨型单体，由大型团队开发，努力满足业务需求。因此，采用微服务架构是很吸引人的选择。正如您所料，迁移到微服务需要企业应对众多技术挑战。但企业也遇到了与技术无关的障碍，这些障碍与战略，流程和组织更相关。

我在与全球众多客户合作时，观察到多种微服务采用反模式，这篇文章是这个系列的第一篇。与常规模式不同（常规模式是一个问题与一个解决方案配对），反模式则由三个元素组成：

- Problem/问题 - 试图解决的问题，在采用微服务的情况下，通常是如何提高软件交付的速度，频率和可靠性
- Anti-pattern solution/反模式解决方案 - 效果不佳的解决方案
- Refactored solution/重构后的解决方案 - 解决问题的更好方法

让我们来看看第一个反模式。

## 反模式：微服务是一种神奇的精灵粉尘

![](images/magic-pixie-dust.jpg)

> 译者注：a magic pixie dust/神奇的精灵粉尘，参见迪斯尼动画片"Tinker Bell" 序列，这是一种精灵们使用的具有各种魔力的粉尘。

我观察到的一种反模式是：**相信微服务可以解决所有的开发问题**。遗憾的是，事实并非如此。微服务架构只是一种具有良好可部署性和可测试性的架构风格。它是一种松耦合的体系结构，支持高效自治的团队，支持DevOps风格的开发。

![](images/successtriangle.png)

例如，微服务架构无法解决实施不充分的开发和部署过程。例如，许多企业依靠单独的QA团队进行人工测试。同样，他们经常使用手动部署流程。并且，有时代码混乱，过于复杂且难以理解。甚至可能存在重复和不同的代码库。微服务架构不能解决这些问题，采用微服务架构很可能相当于火上浇油。

为了避免这种反模式，理解三件事很重要。

- 首先，您需要了解软件交付问题的根本原因。是因为开发和部署流程吗？是因为组织吗？或许你的单体已经过大而不适合它的架构。
- 其次，您需要了解微服务架构适合解决的问题。希望这两组问题能够交叉。
- 最后，您需要了解为了成功应用微服务而需要具备的先决条件，例如自动化测试。

## 反模式：以微服务为目标


![](images/microservices-as-the-goal.jpg)

在上一篇文章中，我描述了反模式：微服务是一种神奇的精灵粉尘。我观察到的另一种反模式是：组织以微服务为目标。例如，一位高管可能宣布一项微服务转型计划，并希望每个开发团队都“做微服务”。然后开发团队争相“做微服务”。也许，团队的年度或季度奖金会受到他们“做微服务”的影响。在极端情况下，它可能取决于他们部署了多少微服务。

### 后果

一方面，采用微服务是一项重大任务，高层的支持至关重要。但另一方面，将微服务作为目标的问题在于它忽略了其他障碍，这些障碍会阻碍快速，频繁和可靠的交付软件，包括：

- 低效的流程和实践 - 瀑布流程，手动测试，手动部署
- Silo'd组织 - 例如开发把代码交给QA进行测试。
- 软件质量差 - 应用程序是一个很大的漏洞，代码不干净，等等。

遭受这些问题的组织可能无法从采用微服务中受益。它甚至可能使事情变得更糟。此外，要求团队采用微服务，有可能在对应用没有意义的情况下，给开发团队强加架构。

### 更好的方法

更好的目标是提高软件交付的速度，频率和可靠性。具体而言，有四个关键指标可供跟踪和改进：

- 交付时间 - 从提交到部署的时间
- 部署频率 - 每个开发人员每天部署的数量
- 失败率 - 部署失败的频率
- 恢复时间 - 从中断中恢复的时间

然后，每个应用开发团队都负责改进其应用的这些指标。有时微服务架构在改进这些指标方面起着关键作用。但是，也还可以采取其他措施来改进这些指标。例如，

- 改进交货时间 - 消除浪费的工作，自动化等
- 增加部署频率 - 自动化测试和部署等
- 降低故障率 - 自动化测试，自动部署，GitOps等
- 缩短恢复时间 - 改进监控，自动恢复等

## 反模式：散射采用

![](images/scattershot-adoption.jpg)

我遇到的另一种反模式是*散射采用*，当多个应用开发团队试图采用微服务架构而没有任何协调时，就会出现这种情况。例如，几个团队可能会同时开发开发基础设施，例如自动部署管道，并搭建运行时基础设施，例如Kubernetes。这种反模式的常见原因是该组织的领导者让采用微服务成为每个人的目标。

### 后果

一方面，组织内部越来越多的基层在努力地采用微服务架构，这很好。但另一方面，让多个团队同时调研微服务而没有任何协调是很低效的。可能存在重复工作，例如，多个团队构想如何开发微服务，为部署管道构建基础设施以及搭建运行时环境。此外，开发团队可能没有技能或时间来构建和管理开发和运行时基础设施。

## 更好的方法

更好的方法是为组织定义和执行微服务的迁移路线图。该路线图包含许多活动，包括：

1. 领导层应该定义并传达战略
2. 基线关键交付指标（交付时间和部署频率等）
3. 建立基础设施团队，负责创建开发和运行时基础设施
4. 选择候选单体应用
5. 迭代地从单体中提取服务（[绞杀单体](https://microservices.io/patterns/refactoring/strangler-application.html))：
	1. 建立团队负责开发，测试和部署服务
	2. 从单体中提取服务
	3. 举办回顾会，总结经验教训，包括方法论和基础设施
	4. 记录并分享经验教训
6. 扩展到其他应用

## 反模式：未走先飞

我观察到的另一种反模式是**未走先飞**（fly before you can walk）。当组织试图采用微服务架构（一种先进技术）而没有（或不承诺有）实践基本软件开发技术（例如干净的代码，良好的设计和自动化测试）时，就会发生这种情况。

通常，管理层持续关注计划和功能，因此忽略了关键的软件质量因素，例如可维护性，可测试性和代码覆盖率。

### 后果

试图采用微服务而不实践软件开发的基础可能会导致失望。微服务架构需要良好的设计技巧和测试自动化。设计糟糕并缺乏自动化测试的微服务架构可能比单体架构更差。此外，凌乱的代码会降低快速，频繁地交付软件的能力。

### 更好的方法

采用微服务时，组织需要接受基础知识，例如：

- 清洁代码 - 作为部署管道的一部分，实施自动代码质量强化
- 自动化测试 - 必须要求开发人员编写自动化测试，以作为开发的一部分。虽然[测试覆盖率不是最佳度量标准](https://martinfowler.com/bliki/TestCoverage.html)，但它也应该由部署管道强制执行。此外，虽然测试驱动开发（TDD）不是强制性的，但组织可能还是需要它才能在最初时灌输测试习惯。
- 设计技能 - 例如面向对象设计（OOD）或领域驱动设计（DDD）。服务必须具有稳定，设计良好的API。此外，为了避免创建分布式单体，分布式单体需要在锁定步骤中更改大量服务，开发人员需要具备设计技能，以仔细定义服务边界和职责。

## 更多资料

在 [Microservices anti-patterns in Melbourne](http://chrisrichardson.net/post/antipatterns/2019/01/28/melbourne-microservices.html) 这篇博客中介绍了这个序列博客是从作者的一个 微服务采用反模式的演讲而来。

这个演讲的PPT可以从这里浏览：

[**Melbourne Jan 2019 - Microservices adoption anti-patterns: Obstacles to decomposing for testability and deployability**](https://www.slideshare.net/chris.e.richardson/melbourne-jan-2019-microservices-adoption-antipatterns-obstacles-to-decomposing-for-testability-and-deployability)

