+++
title = "DreamMesh抛砖引玉(7)-绕不开的Spring"

date = 2018-02-23
lastmod = 2018-02-23
draft = false

tags = ["DreamMesh"]
summary = "对于Java企业应用，Spring是无论如何绕不开的。但是如何以正确的姿势在Service Mesh时代使用Spring，需要自己探索。Spring Boot + Service Mesh是我所推崇的一对清爽搭配。"
abstract = "对于Java企业应用，Spring是无论如何绕不开的。但是如何以正确的姿势在Service Mesh时代使用Spring，需要自己探索。Spring Boot + Service Mesh是我所推崇的一对清爽搭配。"

[header]
image = "headers/post/201802-dreammesh-brainstorm-spring.jpg"
caption = ""

+++

对于Java企业应用，spring是无论如何绕不开的。然而目前我们没有看到Spring社区对Service Mesh的任何回应。因此，如何以正确的姿势在service mesh时代使用Spring，需要自己探索。

## 定位

Service Mesh的定位在于微服务，在于"**服务间通讯**"，在于管理和监控微服务，也就是一般说的"服务治理"。

而Spring是一个巨大的生态体系，模块众多，这些模块除了Spring Cloud作为微服务框架和Service Mesh关系特殊（这个我们将会在下一章中单独谈），其他模块和Service Mesh都不冲突，定位都是完全可以互补的：

- Spring Context作为Spring生态最早的模块和系统核心，定位于**依赖注入和Bean管理**，这是目前Java社区的事实标准。
- Spring Boot作为产品级别的"**微框架**"（注意不是微服务框架），过去几年间也可谓大获成功。
- Spring MVC是目前主流的web和Rest开发框架
- Spring Data定于为数据访问
- 其他模块都不一一列举

我们可以看到，除Spring Cloud之外的Spring生态体系和Service Mesh在定位上都不冲突。

从打造一个完整应用的角度看，我们使用Service Mesh只是解决了微服务之间彼此通讯的问题，对于服务本身，并不涉及：Service Mesh和业务实现无关，和数据库无关，和微服务拆分无关，和cache/session无关。

这也就意味着，不管有没有Service Mesh，应用本身该如何开发和实现，理论上不受影响。

## 现状

让我们回到Spring，在过往的十几年间，对于Java社区，Spring是一道美丽的风景。可以说，Java在企业开发市场的成功，Spring的功不可没。

而令人惊喜的是，Spring至今依然保持良好的发展态势，继续在引领Java社区的技术进步。2018年对Spring的使用者和爱好者来说，会是一个很有惊喜和挑战的年份：

* 基于Java8的Spring5于2017年9月发布
* 同样基于Java8和Spring5的Spring Boot2即将在2月底发布1.0 RELEASE版本
* 不出意外基于Spring5/Spring Boot2的Spring Cloud2也会在今年发布

![](images/spring5.png)

Spring 5/Spring Boot 2终于开始支持Java8特性，带来响应式编程，函数式web框架，Kotlin支持，JUnit 5支持等。其中，响应式编程的全面引入意义深远。

![](images/springboot2.jpg)

从目前发布情况看， Spring 5/Spring Boot 2继续保持了Spring一贯的品质和作风，值得拥有，不容错过。

## 清爽搭配

最近这几年，微服务和容器这两个新兴技术，堪称绝配。而在微服务领域，我个人非常看好这样一个的搭配：**Spring Boot + Service Mesh**。之前我甚至连口号都准备了一个："Spring On Service Mesh"，简称"Spring Mesh"。

在Service Mesh搞定服务间通讯的诸多复杂度之后，带来的好处就是让应用可以回归业务：开发人员的关注点可以更多的聚焦于业务逻辑实现和应用自身的管理。而如何实现单机模式的业务应用，这正是Spring Boot最擅长的领域。

Spring Boot + Service Mesh这对组合的清爽之处在于：

1. Spring Boot大幅简化了应用本身开发的工作，发力于应用之"内"
2. Service Mesh大幅简化了服务间通讯开发的工作，发力于应用之"外"

两者结合，就是"内外兼修"，可以相互支撑而又能互不越界。同时，两者的处世哲学都是尽可能的在底层默默的把事情做好，留给上层一个简单清晰的使用方式，而各种强大功能悄无声息的就绪，堪称"低调的奢华"。

这正是我喜欢的风格。

## 实践

目前"Spring Boot + Service Mesh"对我而言还停留在一个纸上谈兵的阶段，我暂时还未能在实际的工程项目中真实的落地这样一个搭档。因此，如果有朋友有类似的想法，愿意尝试，可以联系我一起做深入研究。

目前构思中的Dream Mesh开源项目，有一块重要内容就是如何让Spring体系和Service Mesh技术更加融洽的结合。我的初步想法就是：如果Spring和Service Mesh做的足够好，那么我们就只是提炼出来最佳实践，给出一个成熟方案供大家参考或者直接拿来用，类似于SpringSide项目于Spring；如果有某些地方有所欠缺或者不足，我们就在Dream Mesh中做好补充和完善，类似于OpenShift项目于K8s。

实践出真知，只有在实践中检验过的东西才能经得起考验。非常期待有机会实践的朋友给予来自一线的知识分享，请微信联系我，不吝赐教。

## 讨论和反馈

TBD: 待讨论后更新。

## 后记

有兴趣的朋友，请联系我的微信，加入DreamMesh内部讨论群。
