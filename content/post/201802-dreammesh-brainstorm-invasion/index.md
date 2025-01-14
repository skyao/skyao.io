+++
title = "DreamMesh抛砖引玉(4)-零侵入的代价"

date = 2018-02-12
lastmod = 2018-02-12
draft = false

tags = ["DreamMesh"]
summary = "Service Mesh的一个突出优点就是对应用的侵入度非常低，低到可以零侵入。然而，没有任何事情是可以十全十美的，零侵入带来的弊端又在哪里？"
abstract = "Service Mesh的一个突出优点就是对应用的侵入度非常低，低到可以零侵入。然而，没有任何事情是可以十全十美的，零侵入带来的弊端又在哪里？"

[header]
image = ""
caption = ""

+++

在介绍Service Mesh优点时，通常会特别突出一点：对应用侵入度低。

侵入度低的根源于Service Mesh的架构，在将各种功能以Sidecar方式从客户端拆出来之后，客户端现在的功能可以说被缩减到就剩下最后一个功能了：将请求发送给Sidecar。

也是Service Mesh方案相对于传统基于SDK的侵入式开发框架的本质差异之一。这个侵入性最低能低到什么地步？如果我们能让客户端代码只管把请求发出去，连发到哪都不用管，就可以实现所谓”零侵入”了。

## 导流方式

因为客户端现在剩下的就一个功能：把请求发出去。请求是什么内容，以何种方式生成，这是应用需要自己完成的工作，同样如何发出去也是要自己完成，比如用HTTP client发出普通HTTP请求，或者用RestTemplate发送Rest请求，用gRPC客户端发出gRPC请求。

但是发去哪里，这里还是有一点文章可以做的。

为了让客户端发出的请求进入到Sidecar，有以下几种引导流量的方式：

- 手工设置

	直接在客户端代码中明确给出发送的目标Sidecar地址，比如"127.0.0.1:8080"。或者灵活一点，将这个sidecar地址写入到配置文件中。

	这个工作可以说毫无难度简直不费吃灰之力，但是不管怎么说也是要改动代码的，因此不能算是零侵入。

- proxy代理

	通过设置代理，可以是在代码中直接指定http proxy，也可以通过设置HTTP_PROXY这样的环境变量，或者"-Dhttp-proxy="等方式来进行。实际操作中，考虑到几乎所有的HTTP客户端都支持环境变量或者系统参数来设置代理，因此通常都不会采用代码设置proxy的方式（不然这和上面那条手工设置目标地址的咸鱼有什么差异）。

	虽然这个方式也挺简单，但是和手工设置相比，有质的飞跃：不用改动代码，实现了零侵入。对于新应用开发而言意义不大，但是对于老系统迁移来说，非常有意义：这意味着不用修改代码，不用重新打包。

	但是这个方案有个限制，就是要求客户端代码能够支持proxy，如果遇到类库不支持时就没辙了。

- iptables劫持

	如果在linux上，iptables就可以用来解决这个问题。实现方式和proxy类似，只是proxy比较温和，和iptables要暴力的多：iptables实际是劫持流量，而且是在操作系统层面劫持，和应用的类库语言无关。

	这个方案的限制在在于操作系统：iptables需要linux。

## 各家支持

在容器时代，由于容器是基于linux的，因此iptables劫持方案很自然就成为主流做法。

Service Mesh中，Istio和Conduit都是非常明确的采用iptables劫持的方式。

> TBD: istio据说是支持VM的，不确认在VM上运行的Istio是否也是采用iptables劫持。

Linkerd出现比较早，早期也没有专门针对容器环境做特别设计，因此Linkerd比较灵活，上述三种方式都支持。

## 零侵入的代价

然而，没有任何事情是可以十全十美的，零侵入虽好，也还有一些弊端的：

- iptables一刀切的方案有滥用嫌疑

	我个人始终觉得只为指定一个请求目标地址就动用iptables这种大杀器有种杀鸡用牛刀的感觉。虽然确实是方便......

- 为了不劫持某些网络访问又不得不想办法绕开

	如果客户端除了发送请求给服务之外，还有其他的网络访问，那么这个一刀切的方案就尴尬了：会劫持到不应该的请求，比如访问数据库，访问redis，访问外部系统等。

	为此，又不得不想办法避免错误劫持。

	比如Istio中，需要使用Egress规则来容许访问外部服务，对于非HTTP(s)请求，还不得不使用`--includeIPRanges`的方式来绕开Sidecar代理。

- 担心太多的iptables rules会影响性能或者造成系统不稳定

	这块暂时只是担心，并非有实际案例。

	> TBD： 请大家补充或者纠正

## 多一个选择？

目前Istio和Conduit都是直接iptables劫持，考虑到大多数场景其实没这必要，是否考虑补充一个低侵入的方案？通过配置项（如果sidecar的端口是固定的）或者环境变量向应用注入sidecar地址，应用代码当中只要简单（几行代码）使用这个地址即可。

对于新开发或者容许改动的应用，这个工作量小到可以忽略，但是就可以不用iptables劫持，也无需再担心错误的劫持到了其他流量。

当然，对于不想修改代码就直接上Service Mesh的场景，iptables劫持方案还是很合适的。

## 后记

有兴趣的朋友，请联系我的微信，加入DreamMesh内部讨论群。

## 讨论和反馈

- 敖小剑：iptables有谁熟悉啊？Istio和Conduit这样用iptables做流量劫持，我总觉得不是很正道，但又说不出大道理来

- 宋净超：k8s也是这么搞的，其实都是这么弄的。

- 崔秀龙：很主流。

- 敖小剑：你们没啥意见吗？我个人有点喜欢多个选择，提供一个超轻量级的客户端，把请求以普通方式发给mesh，而不是非的走劫持

- 张琦：你说的那个就是我们的mesher提供的方式，因为要走iptables的话很有可能跟容器网络或者虚拟机网络产生耦合和影响

- 敖小剑：晓亮说Mesher是用的http proxy的方式来引导流量，遇到不想被劫持的流量时，就设置`no_proxy`，这个方式和iptables劫持和设置egress穿透是一回事

- 敖小剑：这篇写的不是太好，原因在于我不是很有底气。我对零侵入和iptables劫持的反对和犹豫不是因为我觉得这个有多不好，而是我性格中觉得这么点事犯不着用这么决绝的手段。

- 崔秀龙： 下午讨论这玩意的时候，我也提醒了朋友一句性能问题，他比我更随意的反应了一句——我没准备把我们的垃圾应用写到交换机里面。马丁也有过一句类似的话，透明就是个巨大的好处

- 林静：应用直接发sidecar目标地址，那sidecar怎么知道实际目标服务的地址？如果这样 应用payload里还得有信息告诉sidecar去解析相关内容，并转化为tcp 目标ip和端口吧。

	> 备注：非常好的问题，稍后调研一下细节。按照我的经验，一般还是需要携带一个服务信息，一般是HTTP header比如Host。TBD：后续再更新

- 孙寅：可以默认iptables，但不应该没有其它选择。工业上使用，iptables最大的问题是带来的网络性能损耗

