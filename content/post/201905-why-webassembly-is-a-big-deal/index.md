+++
title = "[译] 为何 WebAssembly 如此重要"

date = 2019-05-16
lastmod = 2019-05-16
draft = false

tags = ["Web Assembly"]
summary = "WebAssembly是一个每个程序员都应该关注的技术。它会变得更流行。它将取代JavaScript。它将取代HTML和CSS。它将取代手机应用。它将取代桌面应用。"
abstract = "WebAssembly是一个每个程序员都应该关注的技术。它会变得更流行。它将取代JavaScript。它将取代HTML和CSS。它将取代手机应用。它将取代桌面应用。"

[header]
image = ""
caption = ""

+++

英文原文来自 [Why WebAssembly is a Big Deal](https://medium.com/@mikevdg/why-webassembly-is-a-big-deal-a308d72c6de1)，作者 [Michael van der Gulik](https://medium.com/@mikevdg) 

------

WebAssembly是一个每个程序员都应该关注的技术。它会变得更流行。它将取代JavaScript。它将取代HTML和CSS。它将取代手机应用。它将取代桌面应用。在10年内，我保证每个程序员至少需要知道如何使用工具来操作WebAssembly并理解它是如何工作的。

你可能会说，“太离谱了！” 好吧，请继续阅读。

### 什么是WebAssembly

当前形式的WebAssembly是Web浏览器的新扩展，可以运行预编译代码…**快速**运行。在C ++中编写了一些小代码，然后使用Emscripten编译器将该代码编译为WebAssembly。通过一些Javascript粘合，就可以在Web浏览器中调用这一小段代码，例如，运行[粒子模拟](https://embed.plnkr.co/jsMi5oltGnT0Jn38js3v/)。

WebAssembly文件，扩展名为.wasm，本身是包含可执行指令的[二进制格式](https://webassembly.github.io/spec/core/binary/index.html)。要使用该文件，必须编写一个运行某些Javascript的HTML文件来获取、编译和执行WebAssembly文件。WebAssembly文件在基于堆栈的虚拟机上执行，并使用共享内存与其Javascript包装器进行通信。

到目前为止，这似乎并不有趣。它看起来只不过是Javascript的加速器。但是，精明的读者会对WebAssembly可能成为什么有所了解。

### WebAssembly将成为什么？

第一个重要发现是WebAssembly是一个安全的沙盒虚拟机。可以从Internet运行喜欢的WebAssembly代码，而确保它不会接管PC或服务器。四个主流Web浏览器对它的安全性非常有信心，它已经默认实现并启用了。它的真正安全性还有待观察，但安全性是WebAssembly的核心设计目标。

第二个重要发现是WebAssembly是一个通用的编译目标。它的原始编译器是一个C编译器，这个编译器很好地指示了WebAssembly虚拟机的低级和可重定向性。许多编程语言都使用C语言编写虚拟机，其他一些语言甚至使用C本身作为编译目标。

此时，有一个[可以编译为WebAssembly的编程语言列表](https://github.com/appcypher/awesome-wasm-langs)。这份名单将在未来很多年中继续增长。

WebAssembly允许使用任何编程语言编写代码，然后让其他人在任何平台上安全地运行该代码而无需安装任何内容。朋友们，这是美好梦想的开始。

### 部署问题

我们来谈谈如何将软件提供给用户。

为新项目选择编程语言的一个重要因素是如何将项目部署到客户。您的程序员喜欢用Haskell，Python，Visual Basic或其他语言编写应用程序，具体取决于他们的喜好。要使用喜欢的语言，他们需要编译应用，制作一些可安装的软件包，并以某种方式将其安装在客户端的计算机上。有许多方法可以提供软件 - 包管理器，可执行安装程序或安装服务，如Steam，Apple App Store，Google Play或Microsoft store。

每一个安装机制都意味着痛苦，从应用商店安装时的轻微疼痛，到管理员要求在他的PC上运行一些旧的COBOL代码时的集群头痛。

部署是一个问题，对于开发人员和系统管理员来说，这一直是一个痛点。我们使用的编程语言与我们所针对的平台密切相关。如果大量用户在PC或移动设备上，我们使用HTML和Javascript。如果用户是Apple移动设备用户，我们使用......呃...... Swift？（我实际上不知道）。如果用户在Android设备上，我们使用Java或Kotlin。如果用户在真实计算机上并且愿意处理掉他们的部署问题，那么我们开发人员才能在我们使用的编程语言中有更多选择。

WebAssembly有可能解决部署问题。

使用WebAssembly，您可以使用任何编程语言编写应用，只要这些编程语言可以支持WebAssembly，而应用可以在任何设备和任何具有现代Web浏览器的操作系统上运行。

### 硬件垄断

想购买台式机或笔记本电脑。有什么选择？好吧，有英特尔，有AMD。多年来一直是双寡头垄断。保持这种双寡头垄断的一个原因是x86架构只在这两家公司之间交叉许可，而且通常预编译的代码需要x86或x86-64（也就是 AMD-64）架构。还有其他因素，例如设计世界上最快的CPU是一件很艰难而去很昂贵的事情。

WebAssembly是一种可让您在任何平台上运行代码的技术（之一）。如果它成为下一个风口，硬件市场将变得商品化。应用编译为WebAssembly，就可以在任何东西上运行 - x86，ARM，RISC-V，SPARC。即便是操作系统市场也会商品化; 您所需要的只是一个支持WebAssembly的浏览器，以便在硬件可以运行时运行最苛刻的应用程序。

### 云计算

但等等，还有更多。云计算成为IT经理办公室的流行词已有一段时间，WebAssembly可以直接迎合它。

WebAssembly在安全沙箱中执行。可以制作一个容器，它可以在服务器上接受和执行WebAssembly模块，而资源开销很小。对于提供的每个服务，无需在虚拟机上运行完整的操作系统。托管提供商只提供对可以上传代码的WebAssembly容器的访问权限。它可以是一个原始容器，接收socket并解析自己的HTTP连接，也可以是一个完整的Web 服务容器，其中WebAssembly模块只需要处理预解析的HTTP请求。

这还不存在。如果有人想变得富有，那么可以考虑这个想法。

### 不是云计算

WebAssembly足以取代PC上本地安装的大多数应用程序。我们已经使用WebGL（又名OpenGL ES 2.0）移植了游戏。我预测不久之前，像LibreOffice这样的大型应用可以直接从网站上获得而无需使用WebAssembly进行安装。

在这种情况下，在本地安装应用没什么意义。本地安装的应用和WebAssembly应用之间几乎没有区别。WebAssembly应用已经可以使用屏幕，键盘和鼠标进行交互。它可以在2D或OpenGL中进行图形处理，并使用硬件对视频流进行解码。可以播放和录制声音。可以访问网络摄像头。可以使用WebSockets。可以使用IndexedDB存储大量数据在本地磁盘上。这些已经是Web浏览器中的标准功能，并且都可以使用Javascript向WebAssembly暴露。

目前唯一困难的地方是WebAssembly无法访问本地文件系统。好吧，可以通过HTML使用文件上传对话，但这不算。最终，总会有人为此创建API，并可能称之为“WASI”。

“从互联网上运行应用程序！？胡说八道！“，你说。[好吧，这是使用Qt和WebAssembly 实现的文本编辑器](http://example.qt.io/qt-webassembly/widgets/richtext/textedit/textedit.html) （[以及更多](https://blog.qt.io/blog/2018/05/22/qt-for-webassembly-examples/)）。

这是一个简单的例子。复杂的例子是在WebBrowser中运行的 Adobe Premier Pro 或 Blender。或者考虑像Steam游戏一样可以直接从网络上运行。这听起来像小说，但从技术上说这并非不能发生。

它会来的。

### 让我们裸奔！

目前，WebAssembly在包含HTML和Javascript包装器的环境中执行。为什么不脱掉这些？使用WebAssembly，为什么要在浏览器中包含HTML渲染器和Javascript引擎？

通过为所有服务提供标准化API，这些服务通常是Web浏览器提供的，可以创建裸 WebAssembly。就是没有HTML和Javascript包装来管理的WebAssembly。访问的网页是.wasm文件，浏览器会抓取并运行该文件。浏览器为WebAssembly模块提供画布，事件处理程序以及对浏览器提供的所有服务的访问。

这目前还不存在。如果现在使用Web浏览器直接访问.wasm文件，它会询问是否要下载它。我假设将设计所需的API并使其工作。

结果是web可以发展。网站不再局限于HTML，CSS和Javascript。可以创建全新的文档描述语言。可以发明全新的布局引擎。而且，对于像我这样的polyglots最相关，我们可以选择任何编程语言来实现在线服务。

### 可访问性

但我听到了强烈抗议！可访问性怎么样？？搜索引擎怎么办？

好吧，我还没有一个好的答案。但我可以想象几种技术解决方案。

一个解决方案是我们保留内容和表现的分离。内容以标准化格式编写，例如HTML。演示文稿由WebAssembly应用管理，该应用可以获取并显示内容。这允许网页设计师使用想要的任何技术进行任意演示 - 不需要CSS，而搜索引擎和需要不同类型的可访问性的用户仍然可以访问内容。

请记住，许多WebAssembly应用并不是可以通过文本访问的，例如游戏和许多应用。盲人不会从图像编辑器中获得太多好处。

另一个解决方案是发明一个API，它可以作为WebAssembly模块，来提供想在屏幕上呈现的DOM，供屏幕阅读器或搜索引擎使用。基本上会有两种表示形式：一种是在图形画布上，另一种是产生结构化文本输出。

第三种解决方案是使用屏幕阅读器或搜索引擎可以使用的元数据来增强画布。执行WebAssembly并在画布上呈现内容，其中包含描述渲染内容的额外元数据。例如，该元数据将包括屏幕上的区域是否是菜单以及存在哪些选项，或者区域是否想要文本输入，以及屏幕上的区域的自然排序（也称为标签顺序）是什么。基本上，曾经在HTML中描述的内容现在被描述为具有元数据的画布区域。同样，这只是一个想法，它可能在实践中很糟糕。

### 可能是什么

1995年，Sun Microsystems发布了Java，带有Java applets和大量的宣传。有史以来第一次，网页可以做一些比`<marquee>`和GIF动画更有趣的事情。开发人员可以使应用完全在用户的Web浏览器中运行。它们没有集成到浏览器中，而是实现为繁重的插件，需要安装整个JVM。1995年，这不是一个小的安装。applets也需要一段时间来加载并使用大量内存。我们现在凭借大量内存，这不再是一个问题，但在Java生命的第一个十年里，它让体验变得令人厌烦。

applets也不可靠。无法保证它们会运行，尤其是在用户使用Microsoft的实现时。他们也不安全，这是棺材里的最后一颗钉子。

以JVM为荣，其他语言最终演变为在JVM上运行。但现在，那艘船航行了。

FutureSplash / Macromedia / Adobe Flash也是一个竞争者，但是是专有的，具有专有工具集和专有语言的专有格式。我读到他们确实在2009年开启了文件格式。最终从浏览器中删除了支持，因为它存在安全风险。

这里的结论是，如果希望您的技术存在于每个人的机器上，那么安全性就需要正视。我真诚地希望WebAssembly作为标准对安全问题做出很好的反应。

### 需要什么？

WebAssembly仍处于初期阶段。它目前能很好的运行代码，而规范版本是1.0，二进制格式定型。目前正在开展SIMD指令支持。通过Web Workers进行多线程处理也正在进行中。

工具可用，并将在未来几年不断改进。浏览器已经让你窥视WebAssembly文件。至少Firefox允许查看WebAssembly字节码，设置断点并查看调用堆栈。我听说浏览器也有profiling支持。

语言支持包括一套不错的语言集合--C，C++和Rust是一流的公民。C＃，Go和Lua显然有稳定的支持。Python，Scala，Ruby，Java和Typescript都有实验性支持。这可能是一个傲慢的陈述，但我真的相信任何想要在21世纪存在的语言都需要能够在WebAssembly上编译或运行。

在访问外部设备的API支持方面，我所知道的唯一可用于裸WebAssembly的API是WASI，它允许文件和流访问等核心功能，允许WebAssembly在浏览器外运行。否则，任何访问外部世界的API都需要在浏览器中的Javascript中实现。除了本地机器上的文件访问，打印机访问和其他新颖的硬件访问（例如非标准蓝牙或USB设备）之外，应用所需的一切几乎都可以满足。“裸WebAssembly”并不是它成功的必要条件; 它只是一个小的优化，不需要浏览器包含对HTML，CSS或Javascript的支持。

我不确定在桌面环境中让WebAssembly成为一等公民需要什么。需要良好的复制和粘贴支持，拖放支持，本地化和国际化，窗口管理事件以及创建通知的功能。也许这些已经可以从网络浏览器中获得; 我经常惊讶与已经可能的事情。

引发爆炸的火花是创建允许现有应用移植的环境。如果创造了“用于WebAssembly的Linux子系统”，那么可以将大量现有的开源软件移植到WebAssembly上。它需要模拟一个文件系统 - 可以通过将文件系统的所有只读部分都缓存为HTTP请求来完成，并且所有可写部分都可以在内存中，远程存储或使用浏览器可以提供的任何文件访问。图形支持可以通过移植X11或Wayland的实现来使用WebGL（我理解已经作为AIGLX存在？）。

一些SDL游戏已经被移植到WebAssembly - 最着名的是官方演示。

一旦JVM在WebAssembly中运行，就可以在浏览器中运行大量的Java软件。同样适用于其他虚拟机和使用它们的语言。

与Windows软件的巨大世界一样，我没有答案。WINE和ReactOS都需要底层的x86或x86-64机器，所以唯一的选择是获取源代码并移植它，或者使用[x86模拟器](https://copy.sh/v86/)。

### 尾声

WebAssembly即将到来。它来得很慢，但现在所有的部分都可以在你正在使用的浏览器上使用。现在我们等待构建用于从各种编程语言中定位WebAssembly的基础设施。一旦构建完成，我们将摆脱HTML，CSS和Javascript的束缚。

https://webassembly.org/

