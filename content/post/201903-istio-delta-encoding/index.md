+++
title = "Istio1.1新特性之弃用Delta Encoding"

date = 2019-03-20
lastmod = 2019-03-20
draft = false

tags = ["Istio", "Mixer"]
summary = "为了尽可能的提升往Mixer批量上报数据的性能，提供了Delta Encoding的特性。但是最近发现存在属性删除的bug，因此Istio1.1之后废弃了这个特性。"
abstract = "为了尽可能的提升往Mixer批量上报数据的性能，提供了Delta Encoding的特性。但是最近发现存在属性删除的bug，因此Istio1.1之后废弃了这个特性。"

[header]
image = "headers/post/201903-istio-service-visibility.jpg"
caption = ""

+++

## 变更分析

在istio1.1的 [release note](https://istio.io/about/notes/1.1/) 中，轻描淡写的提到一点：

> Policies and telemetry
> Reduced Overhead. Added several performance and scale improvements including:
>
>    - Improved the protocol between Envoy and Mixer

Envoy 和 Mixer 的API涉及到 check 和 report 的功能，最近我们正在做这块的内容，因此翻查了 `istio/api` 项目下的 `mixer/v1/mixer.proto` 文件，想知道到底修改了什么。检查git历史记录发现，主要改动是在 ReportRequest 请求中增加了 repeated_attributes_semantics 字段 ：

```protobuf
message ReportRequest {
    ......
    // 就是指这个属性集合，这是 envoy 往 mixer 做 report 上报的内容
    repeated CompressedAttributes attributes = 1 [(gogoproto.nullable) = false];
    
    // 指示如何解码此请求中的属性集合
    RepeatedAttributesSemantics repeated_attributes_semantics = 4;
 }
```

RepeatedAttributesSemantics的定义：

```protobuf
// 用于表示应如何在服务器端重组压缩属性
enum RepeatedAttributesSemantics {
  // Use delta encoding between sets of compressed attributes to reduce the overall on-wire
  // request size. Each individual set of attributes is used to modify the previous set.
  // NOTE: There is no way with this encoding to specify attribute value deletion. This 
  // option should be used with extreme caution.
  // 在压缩属性集之间使用增量编码(delta encoding)来减少整体线上请求的大小。 
  // 属性的每个单独集合都用于修改前一个集合。
  // 注意：此编码无法指定删除属性值。 
  // 应谨慎使用此选项。
  DELTA_ENCODING = 0;

  // Treat each set of compressed attributes as complete - independent from other sets
  // in this request. This will result in on-wire duplication of attributes and values, but
  // will allow for proper accounting of absent values in overall encoding.
  // 将每组压缩属性视为完整个体 - 独立于此请求中的其他集。
  // 这将导致属性和值的重复，但将允许正确计算整体编码中的不存在的值。
  INDEPENDENT_ENCODING = 1;
}
```

这次改动对应的PR为：

- [Add way to signal encoding used for CompressedAttributes to Mixer](https://github.com/istio/api/pull/770): Based on discussions around [istio/istio#11151](https://github.com/istio/istio/issues/11151), this PR is meant to add a way to distinguish between the mixed ways in which `release-1.0` and `release-1.1` handle encoding of `attributes` in the client.

"添加用于标记发送到Mixer的  CompressedAttributes 所使用的编码"： 此PR旨在添加一种方法来区分 `release-1.0` 和 `release-1.1` 在处理客户端属性编码的混合方式。

## 背景介绍

这里所说的 delta encoding 是什么？

这里就涉及到一个背景：envoy 是如何向 mixer 发送 report 数据的。

这是mixer暴露给envoy的接口定义，定义在 `mixer/v1/mixer.proto`：

```protobuf
service Mixer {
  rpc Check(CheckRequest) returns (CheckResponse) {}
  rpc Report(ReportRequest) returns (ReportResponse) {}
}
```

ReportRequest 的内容（简化版本）：

```protobuf
message ReportRequest {
    ......
    // 每个`Attributes`元素表述单个动作的状态。
    // 可以在单个消息中提供多个动作以提高通信效率。
    // 客户端可以累积一组操作并将它们全部发送到一条消息中。
    repeated CompressedAttributes attributes = 1 [(gogoproto.nullable) = false];
 }
```

attributes 是上要上报的内容，如注释所说，考虑到通讯的效率，需要将多个数据放在同一个请求中做批量上报。因此是 repeated，在一个 ReportRequest 请求中携带批量数据。CompressedAttributes 是一个为传输进行了特别优化的压缩格式，具体格式涉及到 dictionary 的使用，就不展开了。

进入正题：在将多个数据批量打包上报的基础上，在 Istio1.1之前，为了更高的效率，Istio对这些同一个请求里面的多个 attributes 做了优化，称为 Delta Encoding。

以下注释内容在Istio1.1之前存在的，Istio1.1之后删除：

```protobuf
Although each `Attributes` message is semantically treated as an independent stand-alone entity unrelated to the other attributes within the message, this message format leverages delta-encoding between attribute messages in order to substantially reduce the request size and improve end-to-end efficiency. Each  individual set of attributes is used to modify the previous set. This eliminates the need to redundantly send the same attributes multiple times over within a single request.

尽管每个“Attributes”在语义上被视为独立实体，与消息中的其他属性无关的，但此消息格式利用属性消息之间的delta encoding，以便显着减少请求大小并改进端到端效率。每组单独的属性用于修改前一组。这消除了在单个请求中多次冗余地发送相同属性的需要。
```

delta-encoding 的设计出发点是在于上报的数据存在大量的重复性，相邻的几条数据可能只有细微差别，因此可以考虑只传递增量。

如下面三条数据，所有字段都相同，只有字段 destination_version 和 destination_workload  的值不同：

```json
istio_requests_total{connection_security_policy="unknown",destination_app="reviews",destination_principal="unknown",destination_service="details.bookinfo.svc.cluster.local",destination_service_name="details",destination_service_namespace="bookinfo",destination_version="v1",destination_workload="reviews-v1",destination_workload_namespace="bookinfo",instance="172.17.0.9:42422",job="istio-mesh",permissive_response_code="none",permissive_response_policyid="none",reporter="source",request_protocol="http",response_code="555",source_app="productpage",source_principal="unknown",source_version="v1",source_workload="productpage-v1",source_workload_namespace="bookinfo"}

istio_requests_total{connection_security_policy="unknown",destination_app="reviews",destination_principal="unknown",destination_service="details.bookinfo.svc.cluster.local",destination_service_name="details",destination_service_namespace="bookinfo",destination_version="v2",destination_workload="reviews-v2",destination_workload_namespace="bookinfo",instance="172.17.0.9:42422",job="istio-mesh",permissive_response_code="none",permissive_response_policyid="none",reporter="source",request_protocol="http",response_code="555",source_app="productpage",source_principal="unknown",source_version="v1",source_workload="productpage-v1",source_workload_namespace="bookinfo"}

istio_requests_total{connection_security_policy="unknown",destination_app="reviews",destination_principal="unknown",destination_service="details.bookinfo.svc.cluster.local",destination_service_name="details",destination_service_namespace="bookinfo",destination_version="v3",destination_workload="reviews-v3",destination_workload_namespace="bookinfo",instance="172.17.0.9:42422",job="istio-mesh",permissive_response_code="none",permissive_response_policyid="none",reporter="source",request_protocol="http",response_code="555",source_app="productpage",source_principal="unknown",source_version="v1",source_workload="productpage-v1",source_workload_namespace="bookinfo"}
```

所以，采用增量编码，可以将数据编码为第一条数据是完整数据，后面两条只保留增量：

```json
istio_requests_total{connection_security_policy="unknown",destination_app="reviews",destination_principal="unknown",destination_service="details.bookinfo.svc.cluster.local",destination_service_name="details",destination_service_namespace="bookinfo",destination_version="v1",destination_workload="reviews-v1",destination_workload_namespace="bookinfo",instance="172.17.0.9:42422",job="istio-mesh",permissive_response_code="none",permissive_response_policyid="none",reporter="source",request_protocol="http",response_code="555",source_app="productpage",source_principal="unknown",source_version="v1",source_workload="productpage-v1",source_workload_namespace="bookinfo"}

istio_requests_total{destination_version="v2",destination_workload="reviews-v2"}

istio_requests_total{destination_version="v3",destination_workload="reviews-v3"}
```

这样数据包的大小就可以显著减少，mixer在收到请求后，只要正常解析出第一条完整数据，然后以这条数据为基础叠加第二条的增量，就可以算出第二条数据的完整值。再以第二条数据为基础，继续计算第三条......

按说这个想法和设计很好，但是 Istio 1.1 之后放弃了 delta encoding，改成了普通的编码，即每条数据单独编码。

给出的解释在代码注释中：

```
enum RepeatedAttributesSemantics {
  // NOTE: There is no way with this encoding to specify attribute value deletion. This 
  // option should be used with extreme caution.
  // 注意：此编码无法指定属性值的删除。 
  // 应谨慎使用此选项。
  DELTA_ENCODING = 0;
}
```

Delta Encoding有bug：无法指定属性值的删除。因此如果某条数据和上一条相比，没有某个属性，则会自动将上一条的属性继承下来，造成错误。

可以通过这个 issue 了解详情

- [Telemetry resulting from injected faults is wrong](https://github.com/istio/istio/issues/11151)

摘录部分关键信息，以下是对这个issue报告的bug的总结：

> Mixer client (prior to 1.1-pre) uses batch compression protocol to compress multiple bags into a single report request sent to Mixer. The protocol does not support deletions.
> When an attribute like destination.uid is not present in a bag, it incorrectly assumes value from the previous bag.
> Mixer客户端（1.1-pre之前）使用批量压缩协议将多个包压缩成单个report请求发送到mixer。 该协议不支持删除。 
> 当包中没有类似 destination.uid 这样的属性时，它会错误地假定获取前一个包中的值。
>
> At present 1.1-pre snapshots (Post Oct 2018) , the client does not send batch compressed data. This change was made as part of a performance change in Mixer client. 1.1-pre mixer however treats incoming data as batch compressed. This change also fixes the above problem. The proposed change:
> 目前1.1-pre快照（2018年10月后发布），客户端不发送批量压缩数据。 此更改是作为Mixer客户端性能更改的一部分而进行的。 然而，1.1之前的 mixer将输入数据视为批量压缩。 此次更改也解决了上述问题。 拟议的变更：
>
> - 更新API以标明CompressedAttributes是否是批量压缩
> - 更新服务器端 Mixer to forgo decompression logic if batch compression is not done.

非常坚决的提出直接去掉delta encoding的特性。也有质疑的声音：

> What's the motivation to turn off batching completely?
> 完全关闭批处理的动机是什么？

> The design intent was always to break up a batch on the client if deletion were necessary. This would seem to me as the lowest impact change, rather than messing with the wire-protocol and potentially introduce some upgrade challenges (when a V1.1 proxy sends stuff to a V1.0 Mixer during an upgrade cycle).
> 如果需要删除，设计上可以在客户端上分解批量处理（即遇到需要删除的情况，就结束当前批量，再新起一个批量）。这在我看来是影响最小的变化，而不是搞乱线上协议并可能引入一些升级挑战（在升级期间，V1.1代理向V1.0 mixer发送内容）。

对此有解释：

> the issues that may arise are that the ordering of the reporting could have a large impact on number of requests sent to Mixer and there may be a fair amount of additional logic that has to be added to detect and handle batch segregation client-side. If the compression logic was removed for perf reasons, we may end up regressing with the intro of new batch separation logic (and return to compression).
> 
> 可能出现的问题是，报告的排序可能会对发送到Mixer的请求数量产生很大影响，并且可能需要添加大量额外的逻辑来检测和处理客户端的批处理隔离。 如果删除压缩逻辑造成性能问题，我们可能会结束回归，引入新的批量分离逻辑。
>
> I guess it comes down to a choice of where to dedicate resources for 1.1. My familiarity (and hence preference) would be to do that work server-side -- and leave the client (mostly) alone. But that definitely reflects my bias.
> 
> 我想这可以归结为1.1的专用资源选择。 我熟悉的是（也就是偏好）是在服务器端进行这个工作 - 并且不让客户端参与（大多数情况下）。 但这肯定反映了我的偏见。

最后的盖棺定论：

> I don't think we should to re-open batch compression issue.
> It has been removed, we can take advantage of the fact that it has been removed on the server to simplify and optimize code.
> 
> 我认为我们不应该重新打开批量压缩的Issue。
> 它已被删除，我们可以利用它已在服务器上被删除的事实来简化和优化代码。
>
> regarding upgrades: v1.1 proxy should not send traffic to v1.0 Mixer. The upgrade sequence is istio components first and then sidecars. Other types of updates are not supported.
> 
> 关于升级：v1.1代理不应该向v1.0mixer发送流量。 升级顺序首先是istio组件，然后是sidecars。 不支持其他类型的更新。

## 总结分析

由于 Delta Encoding 有不能提现属性被删除的缺陷，会造成很大的bug。以及出于简化客户端和服务器端处理代码的考虑，因此，最终的结果是在Istio1.1中废弃了一直沿用的 Delta Encoding 优化特性。

在这里，个人提出几点疑问：

1. Delta Encoding 到底有没有性能提升？

    从设计上看，正常工作时，如果多条记录有大量重复的属性，的确可以做到减少重复。但是从Istio这么坚决的放弃这个特性来看，似乎 Delta Encoding 最终也没起到应有的作用。但话又要说回来：当年选择做 Delta Encoding 的优化时又是如何决策的？有实际验证过开启Delta Encoding前后的性能提升吗？
    
    这里有个悖论：
    
    - 如果 Delta Encoding 没效果，那么当时选择上 Delta Encoding 就是盲目提前优化而且优化无效
    - 如果 Delta Encoding 有效果，那么当前仅仅因为一个bug就立即全面废弃就太过草率

    看后续是否有资料可以说明实际情况，再做补充更新。

2. Delta Encoding 的缺陷是不是可以有办法解决？

    从目前的bug看，主要是如果有属性缺失时，delta encoding没法体现出来。但是这个还是有办法解决的，比如前面提到的遇到属性要删除的情况，直接新起一个批量好了。不过这个的确可能因为属性删除的情况太多会造成包被拆解的太小而影响传输效率，失去批量的意义。另外的确代码复杂度上升了。

3. 为什么这个bug一直没被发现？

    从描述上看，Delta Encoding 存在很长时间了，但是一直没被发现，直到最新。而这个bug触发的情况其实并不复杂，只要某个场景下某条数据的属性相对上一条数据要少，就会触发，而且一旦触发，后续的数据都会被这个错误传染。但是就是这样还是存在很长时间才发现，是否说明，istiio的真的实际使用不多？

最后，不能不说， Kiali 帮了大忙，从几个 issue 的报告来看，都是通过 kiali 的调用关系图发现问题，才最终查找到是 Delta Encoding 引入的bug。可观测性的确是ServiceMesh中至关重要的特性，太重要了！
