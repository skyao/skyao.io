+++
title = "DreamMesh抛砖引玉(2)-CloudNative"

date = 2018-02-10
lastmod = 2018-02-10
draft = false

tags = ["DreamMesh"]
summary = "理想很丰满，现实很骨感。Cloud Native虽然令人向往，然而现实中，有多少企业是真的做好了Cloud Native的准备？"
abstract = "理想很丰满，现实很骨感。Cloud Native虽然令人向往，然而现实中，有多少企业是真的做好了Cloud Native的准备？"

[header]
image = "headers/post/201802-dreammesh-brainstorm-cloudnative.jpg"
caption = ""

+++

我对Service Mesh的第一个担忧，来自 **Cloud Native**。

## Are You Ready？

作为Cloud Native的忠实拥护者，我从不怀疑Cloud Native的价值和前景。可以说，微服务/容器这些技术天然就适合走Cloud Native的道路。

但是，我担心的是：准备上Service Mesh的各位，是否都已经做到了Ready for Cloud Native？

![](images/are-you-ready.jpg)

这真是一个尴尬的问题。

现实摆在眼前，根据我最近几个月跑过的企业客户（大大小小接近二十家）的实际情况看，可以说：情况非常不乐观。

> 备注： 这里只讨论普通企业用户，对于技术和管理都比较先进的互联网大公司来说，Cloud Native的普及情况要好很多。

这就引出了下面这个问题：

**如果没有Cloud Native基础，那还能不能用Service Mesh？**

## 发展路径

这里有三条发展路径可选：

1. 先Cloud Native，再Service Mesh

	理论上说，这是最合理的：先把底层基础设施铺好，再在其上构建上层业务应用。

	具体说，就是先上云/容器/k8s，应用暂时维持原状。不管是单体应用，还是基于Dubbo/Spring Cloud等侵入式开发框架的微服务应用，先上云再说。更直白一点，上k8s。

	等待Istio/Conduit成熟之后，再迁移到Service Mesh方案。

2. 先Service Mesh，再Cloud Native

	这个方案理论上也是可行的：先用Service Mesh方案完成微服务体系建设，之后再迁移到k8s平台。

	之所以说**理论上**没有问题，是指Service Mesh从设计理念上，对底层是不是容器并没有特别要求。无论是容器/虚拟机/物理机，Service Mesh都是可行的。

3. 同时上Service Mesh加Cloud Native

	通常来说我们不赞成同时进行这两个技术变革，因为涉及到的内容实在太多，集中在一起，指望一口气吃成大胖子，容易被噎住。

	但是不管怎么样这条路终究还是存在的，而且如果决心够大+愿意投入+高人护航，也不失是一个一次性彻底解决问题的方案，先列在这里。

## 何去何从

路径1和路径2，在讨论该如何选择之前，还有一个问题：就是路径2是不是真的可行？

### 青黄不接的尴尬

我们前面说道路径2理论上是可行的，但是目前的实际情况是真要选择就会发现：难。这要从目前市面上的Service Mesh产品谈起，按照我的划分方式，我将目前主流的四个Service Mesh产品划分为两代：

* 第一代Service Mesh，包括Linkerd和Envoy。

	这两个产品目前都是production ready，而且都和平台无关，对物理机/虚拟机/容器都可以支持。

* 第二代Service Mesh，包括Istio和Conduit

	这两个产品目前都还在发展中，暂时都未能达到production ready。

如果要在当前时刻进行Service Mesh的技术选型，我们就会发现这样一个尴尬的局面：

* Istio和Conduit还没有production ready，上线不适合，只能继续等待。

* Linkerd和Envoy倒是可用，但是，在了解Istio和Conduit之后，又有多少人愿意在现在选择上Linkerd和Envoy？49年入国军？

所谓**青黄不接**，便是如此。

在接下来的讨论中，我们假定大家都是在等待Istio和Conduit。

我们回到前面的话题，限定Istio和Conduit，如果选择路径2(先Service Mesh，再Cloud Native)，会如何？

### 对平台的要求

#### Conduit

首先Conduit非常坚定执着的"Say No"了，官网非常清晰的表述：

**Conduit is a next-generation ultralight service mesh for Kubernetes.**

私底下和William就此简单聊过，他给出来的回答很委婉也很实在：conduit总要从某个地方起步，k8s是目前最好选择。以后可以支持，但是肯定先k8s再说。考虑到Conduit和Buoyant公司的处境，尤其全公司才二十，我们不能要求太多。

可以明确的说，短期之内，起码2018年，Conduit官方不会有对k8s之外的支持。

#### Istio

Isito最早版本是只支持k8s的，后来陆续提供了对其他非k8s环境的支持，比如Docker+Consul/Eureka的方案，还有计划中但是还没有完成的Cloud Fountry和Mesos集成。

对于VM，istio有提供一个VM解决方案，具体看见官方文档：

- [Integrating Virtual Machines](https://istio.io/docs/guides/integrating-vms.html)
- [集成虚拟机](http://istio.doczh.cn/docs/guides/integrating-vms.html): 中文翻译版本

从文档上看是可以支持部分服务在k8s之外：

![](http://istio.doczh.cn/docs/img/mesh-expansion.svg)

TBD： 需要继续调研看istio是否可以在纯粹的VM环境下运行，即完全脱离k8s和容器。

### 平台要求总结

Conduit和Istio（还有待最后确认）对容器/K8s/Cloud Native都有要求，导致目前路径2（先Service Mesh，再Cloud Native）几乎没有无法实现，至少在不改动Conduit和Istio的情况下。

这就意味着，只能走路径1（先Cloud Native，再Service Mesh），也就回到了最早的问题： 做好了Cloud Native的准备吗？

## 后记

需要做一个市场调查，要有足够多的样本：

企业客户对微服务和容器，是打算先上容器/k8s再上微服务，还是希望可以直接在虚拟机/物理机上做微服务，后面再迁移到k8s？

有兴趣的朋友，请联系我的微信，加入DreamMesh讨论群就此话题展开讨论。

## 讨论和反馈

在这篇博客文章编写前一天晚上，和来自Google Istio开发团队的Hu同学有过一次长时间的讨论。

在征得同意之后我将讨论内容整理如下。特别鸣谢Hu同学的指点：

- Hu: 你好，这么晚还在工作？

- 敖小剑：正在整理思路。

- Hu: 文章写的很好。

- 敖小剑：您客气了，还是你们产品做的好，istio我是报以厚望。

- Hu：希望不要让大家失望，能够解决一些实际问题。

- 敖小剑：一起努力吧，就算有小的不足，也还是有机会改进的，istio的大方向我是非常认可的。

- Hu：恩，现在是一个新时代的开始，cloud native是大势所趋，后面我们会看到更多有趣的技术出来。有什么想法和建议，也欢迎在istio的工作组里提。

- 敖小剑：我现在是一边等istio的production ready版本，一边着手准备，为落地可能遇到的问题或者需求预先研究一下。

	国内可能情况和美国不太一样，目前国内企业，尤其传统形的企业，他们的技术基础非常糟糕，离cloud native差距很远。

	但是他们又有强烈的意愿上微服务。

- Hu：对，但这也是机遇。国内的企业软件市场还有很大空间。美国公司喜欢新技术，跟的比较紧。

- 敖小剑：我选择istio这种service mesh方案来推微服务落地，本意是降低微服务普及的门槛。

	这样普通企业用户才有机会玩转微服务，毕竟这些公司连spring cloud都玩的很吃力。

	现在的问题是，istio比较强调cloud native，而这些企业用户基本都没有准备好cloud native。

- Hu：呵呵，我觉得你的想法很好，不过可能有点超前。据我所知，即使在很多互联网大企业, service mesh也没有完全落地。第一步可能还是docker化和普及kubernetes。

- 敖小剑：我刚才还在看如何在非k8s，非docker环境下跑istio。嗯，你的思路是先准备好路，再让istio这辆车上路？我的思路有点倾向于让service mesh这个车在没路的情况下也能跑起来。

- Hu：我的意思是要看条件，可以把非K8S方案作为一个过渡。最终还是要迁移到kube和云上。

- 敖小剑：嗯，对的，我想增加一个过渡阶段。

- Hu：都可以的，就看企业的自身条件了。Google这边是提供不同解决方案的，但最终目标还是希望客户迁移到云上。

- 敖小剑：cloud native条件不成熟的情况下，先过渡一下，把应用迁移到非docker条件下的istio，先完成微服务化。

	两条路，一条先cloud native再service mesh，一条先service mesh再cloud native。

- Hu：恩，我觉得都是可行的。如果是重IT的公司，建议直接cloudnative。

- 敖小剑：不同企业可能演进的速度和步骤不一样。微服务化更多是业务团队推动，cloud native通常是运维和基础架构团队。

- Hu：我对国内情况不了解，只是个人看法，呵呵。其实可能最重要的还是普及devops的模式，人的问题解决了，别的都好办。

- 敖小剑：嗯，我个人的感觉是技术导向的互联网公司容易做到cloud native，他们走你说的路线比较合理。但是普通企业用户可能会选择先微服务化。

	当然这个我还要继续调研和确认，比较我现在接触的样本也不够多。所以，多讨论多沟通，确认好实际需要再说。

	我这段时间会陆陆续续把想法写出来，然后提交大家讨论。希望你多给意见。

- Hu：好的。

在这篇博客文章发表收集到的讨论和评论反馈：

- 张琦：我们的经验，必定要走你说的路径2，servicemesh甚至要充当从传统应用到Cloudnative之间的桥梁。例如在逐渐微服务化的过程中 用mesh来接入原来的单体应用 然后再一点一点去拆；或者用mesh接入其他协议的遗留应用来做一下协议转换，我记得微博也有这种用法

- 崔秀龙：posta那篇微服务改造的文章还是很可以参考的

- 肖晟：没错，企业随着IT架构的演进，上面提到的遗留应用并不在少数。需要解决协议适配等问题，又不想受限于服务总线类流量中心的瓶颈，mesh是一种理想的解决之道；而想要上mesh，又可能推动其上cloudnative。所以从企业总体来说，这个演变很可能是混合的，不过从单应用来说会是分步的。

- 肖晟：另外在思考的一个问题是，在一个企业IT架构下，由于不同技术标准或安全需求等因素的影响，有没有可能同时存在两套或多套servicemesh。

	> 备注： 这个话题后面会有专门的章节

- 崔秀龙：我觉得是两个必须：必须容器云，必须打SC。

- 宋净超：理想很丰满，现实很骨感啊。

- 崔秀龙：我个人的感觉是有了SM之后，微服务的定义就很清晰了。

- 宋净超：同意。

- 孟樊亮：迁移到k8s，感觉是服务注册/发现/互通只是第一步，后续的治理和运维才是无尽大坑。

- 于文涛：我们公司应该是偏第一种方案，先走容器化，k8s后微服务化。不过微服务和也其实在同时推进。
