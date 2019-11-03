+++
title = "[译] 动态可扩展性和Protocol Buffer"

date = 2019-09-20
lastmod = 2019-09-20
draft = false

tags = ["Protocol Buffer"]
summary = "WebAssembly宣布开始新的标准化工作--WASI，WebAssembly系统接口。通过WASI，可以将WebAssembly和Web的优势扩展到更多的用户，更多的地方，更多的设备，带来更多的体验。"
abstract = "WebAssembly宣布开始新的标准化工作--WASI，WebAssembly系统接口。通过WASI，可以将WebAssembly和Web的优势扩展到更多的用户，更多的地方，更多的设备，带来更多的体验。"

[header]
image = ""
caption = ""

+++

英文原文来自 [Dynamic extensibility and Protocol Buffers](https://hacks.mozilla.org/2019/08/webassembly-interface-types/)，作者 [Harvey Tuch](https://blog.envoyproxy.io/@htuch)。

> 备注：快速翻译（机翻+人工校对，没有精修），质量不高，一般阅读可以，不适合传播，谢绝转载。

------

Protocol Buffers（protobuf）是Google推出的高效，静态类型，语言无关的数据序列化格式。我们在Envoy代理中使用protobuf 定义其v2 API，也称为网络代理的通用数据平面API。

在本文中，我将深入探讨动态扩展 Protobuf 时的一些细微差别和权衡取舍。也就是说，在编译时将不透明的消息字段用未知类型消息嵌入到protobuf中。我将重点介绍Envoy项目，这是我们最近探讨了这种折衷方案的上下文，但是本文适用于任何需要不透明配置嵌入的情况。

## Envoy可扩展性要求

Envoy的主要功能之一是其可扩展性。每个 request/stream/connection 都要遍历 L4/L7过滤器的可配置堆栈。这些过滤器可以检查或更改流量，例如通过插入header，调用身份验证服务或在协议之间进行代码转换。筛选器遵循定义良好的API，任何Envoy使用者都可以链接自己的自定义筛选器，例如，包含组织特定业务逻辑的筛选器，并通过数据平面API配置客户筛选器。除了其L4/L7过滤器外，Envoy还具有用于记录，跟踪和统计信息输出的插件体系结构。

我们在数据平面API中的 https://github.com/envoyproxy/data-plane-api/tree/master/api  的 `.proto` 文件中定义了固定消息类型，用于Envoy的内置功能和过滤器。例如，Envoy的 [RouteConfiguration](https://github.com/envoyproxy/data-plane-api/blob/30b519882b82d4f6a0cf1b502258e35cae9292a2/api/rds.proto#L534) 消息描述了一个路由表，从虚拟主机和路径到路由操作的映射：

与Envoy核心功能的配置相对应的消息类型在我们的GitHub存储库中指定，并将随着Envoy功能的增长而扩展。但是，在配置更新中，Envoy用户需要一起指定Envoy核心功能的配置以及他们自己的自定义过滤器的配置。

想象一下，Acme Corp编写了一个*AcmeWidget*筛选器，在每次请求时向身份验证服务发起RPC。自定义过滤器的配置将在protobuf中定义，例如：


这个 proto 是专有的，不太可能托管在Envoy的数据平面API存储库中。因此，我们需要提供某种方式在Envoy的配置中进行编码，以更新*AuthService*消息的值，而无需知道静态消息类型。Protobuf 为这种不透明配置嵌入提供了两种众所周知的形式：*Any* 和 *STRUCT* 消息类型。

## google.protobuf.Struct

Struct是实现此角色的两种消息类型中最容易的，因为它只是JSON对象的proto表示。由于 proto3 具有规范的JSON表示形式，任何 proto3 消息都可以机械地转换为 JSON 并嵌入到此类型的字段中。

这是一种非常灵活的类型，并为protobuf带来了动态类型的优点。今天，我们在Envoy中使用这个方式来嵌入任意过滤器：

下面是一个具体示例，嵌入在 Filter 中的 AcmeValue 的文本 proto 表示：

迄今为止，此方法运行良好，但它是有折衷的，这些折衷是灵活的动态类型包的一部分：

- 没有Envoy特定的逻辑，无法进行静态类型检查，带有嵌入的不透明过滤器配置的Envoy配置，无法确定嵌入式不透明配置的类型正确性。相反，当Envoy提取其配置时，会在运行时确定过滤器的相应protobuf类型，并尝试转换 Struct 到 protobuf 类型，失败时会引发异常。外部工具不太可能执行相同的操作，因为从过滤器名称到架构的映射知识尚未标准化。但是，外部工具可以动态显示和操作过滤器的配置，而无需事先了解底层类型，因为它们只是JSON对象。您也可以从二进制proto3表示形式到JSON规范proto3表示形式来回转换，而无需了解每个过滤器的protobuf模式（也称为protobuf描述符）。

- 这种表示方式效率不高。与常规的protobuf相比低效率是一个事实，这种表示方法中字段名在每个定义重复，如对AcmeWidget我们将不得不有 {"cluster": "foo", "auth_type": "JWT"}。使用已知的protobuf描述符，就不用 “cluster” 或 “ auth_type” 字段名称。这是Protobuf比XML小3到10倍的原因（在有效的二进制编码之外）。对于今天的Envoy配置而言，这并不是什么大问题，因为它的配置通常很小，并且属于Envoy控制平面的一部分，在该控制平面中，对性能的关注并不像在数据平面上那样重要。将来，随着我们扩展到非常大的配置，这可能是一个问题。

- 官方语言特定的 protobuf 库不提供在 Struct 和任意 protobuf 消息类型之间进行转换的优先支持，而是始终需要通过JSON 序列化/反序列化操作进行转换。这有性能方面的考虑，但是如上所述，这些都不是当今Envoy中的头等大事。

- 上面的文本 proto 格式的阅读或书写体验都不愉快。

## google.protobuf.Any

Any 消息类型将带有类型信息的二进制序列化的protobuf嵌入到另一protobuf的字段内。在内部，它只是一个字节数组，具有嵌入式消息的protobuf格式序列化和一个包含 type URL 的字符串。Type URL本质上是一个字符串，其中包含形式为type.googleapis.com/packagename.messagename 的类型名称。如果我们使用Any，则上面的Filter定义将如下所示：

现在，嵌入在Filter中的AcmeValue的文本 proto 表示的一个具体示例为：

尽管这看起来类似于Struct示例，但请考虑以下差异：

- 由于嵌入式 proto 具有紧凑的序列化表示，因此这几乎与将嵌入式 protobuf 内联的效率一样，即接近最优。

- 由于没有模式（即protobuf描述符），没有任何有意义的方法可以理解嵌入式proto。对于Envoy二进制文件而言，这不是要考虑的问题，因为所有过滤器都是静态链接的，因此可以使用其关联的protobuf描述符。但是，请考虑独立Web应用程序，它具有用于构建和可视化Envoy配置的UI。可以预期，它已经为Envoy的核心数据平面API提供了protobuf描述符，但对于AcmeWidget的protobuf描述符却一无所知。为此，Web应用程序将需要额外的复杂性，您首先需要让Acme Corp编译protobuf描述符对象并上传它们。从经验中我们发现，当我们对gRPC转码器过滤器有此要求时，这会增加Envoy的运维困难。

- Type URL 提供信息，可用于对Envoy配置及其嵌入式过滤器进行自动静态检查。关于上述问题，关于protobuf描述符的可用性的警告在这里也适用。

- 可以有效地（反）序列化消息，而无需进行JSON往返操作。

- 有一个漂亮的文本 proto 表示，比Struct嵌入要干净得多。如果要使用文本 proto 作为Envoy的配置格式，这很有用，但是我们通常建议使用YAML，因为文本 proto 尚未标准化，也没有在开源protobuf中得到正式支持或文档。

补充（2018-02-09）：我们最近发现的使用 Any 对象时的一个注意事项是，由于嵌入式消息的type URL在 Any 对象内部进行了序列化，因此任何对 Any 中嵌入的消息的包名称空间的变更都会破坏 protobuf 的兼容性。这是因为type URL是从嵌入式消息的包名称空间派生的。对于Struct不会发生这种情况，因为应用程序级有底层类型的知识，而与protobuf包的命名空间的细节不同。

## 应该使用哪个？

在Envoy数据平面API的早期设计中，我们在过滤器、统计、日志和追踪的扩展点采用 struct 。这主要是看重无模式表示的优点（看起来不错，没有proto描述符！）。容易生成Envoy配置并将其转储。

在数据平面API的其他地方，当描述要嵌入很多不同资源类型的gRPC服务时，我们选择使用Any。在这种情况下，我们需要嵌入一组众所周知的proto，这些proto也存在于数据平面API的库中。此处无需担心proto描述符的可用性，并且效率优势是免费提供的。我们在这里也可以使用oneof，而只需要付出在每次添加新类型时都要更新其定义的小代价。

通过构造如下的Filter配置，可以同时拥有Any和Struct的优势：

进一步推动这一设计理念，Lizan Zhou建议，我们在Envoy中使用 Any 作为我们的基础不透明的嵌入类型，然后在 Any proto中嵌入一个Struct，以便实现类似的效果。这是一个超酷的主意，从根本上讲就是嵌套的protobuf类型。Type URL为 type.googleapis.com/google.protobuf.Struct 的任何嵌入式的 protobuf 可以被 Envoy 解释为 Struct，同时在不以这种方式嵌入时保持高效 Any的选项。这将为Envoy最终用户提供最大的灵活性，使他们自己可以进行上述的折衷。双重嵌套的具体示例是：

在将来的某个时候，我们很可能会采用上述 Any/Struct 组合方式中的一种来获得两全其美的效果。目前，我们已经冻结了核心数据平面API，以准备在Envoy 1.5版本中投入生产。在执行此操作时，我们将需要以向后兼容的方式进行此切换，同时在我们的可扩展API之间保持机制的一致性。

Protobuf提供了一些强大的机制来支持将不透明配置嵌入其静态类型的消息模式中。为项目选择正确的方法需要了解这些机制之间的权衡以及如何进行组合。在Envoy项目中做出此设计决定时，我们会发现上面的详细信息非常宝贵，希望我们可以通过分享这些经验教训使社区受益。

致谢：以上对Any与Struct取舍的调查是通过与 John Millikin 和 Lizan Zhou 进行的有益讨论而得出的，非常感谢。当我们制订 Envoy 数据平面API 的 proto 时，也要向 mattklein123 进行有关此主题的许多PR评论和讨论。

免责声明：此处陈述的观点仅代表我个人，而非我公司（Google）的观点。
