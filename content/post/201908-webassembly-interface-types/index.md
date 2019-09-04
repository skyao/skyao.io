+++
title = "[译] WebAssembly接口类型：与所有事物互操作！"

date = 2019-08-27
lastmod = 2019-08-27
draft = true

tags = ["Web Assembly"]
summary = "WebAssembly宣布开始新的标准化工作--WASI，WebAssembly系统接口。通过WASI，可以将WebAssembly和Web的优势扩展到更多的用户，更多的地方，更多的设备，带来更多的体验。"
abstract = "WebAssembly宣布开始新的标准化工作--WASI，WebAssembly系统接口。通过WASI，可以将WebAssembly和Web的优势扩展到更多的用户，更多的地方，更多的设备，带来更多的体验。"

[header]
image = ""
caption = ""

+++

英文原文来自 [WebAssembly Interface Types: Interoperate with All the Things!](https://hacks.mozilla.org/2019/08/webassembly-interface-types/)，作者 [Lin Clark](https://twitter.com/linclark)。

> 备注：快速翻译（机翻+人工校对，没有精修），质量不高，一般阅读可以，不适合传播，谢绝转载。

------

人们兴奋于在浏览器外运行WebAssembly。

这种兴奋不只在于运行在自己的独立运行时中的WebAssembly。人们也对使用Python，Ruby和Rust等语言运行WebAssembly感到兴奋。

为什么想这么做？原因如下：

- **使“原生”模块不那么复杂**
	像Node或Python的CPython这样的运行时通常允许你用C++等低级语言编写模块。那是因为这些低级语言通常要快得多。因此，您可以在Node中使用原生模块，或在Python中使用扩展模块。但这些模块通常很难使用，因为它们需要在用户的设备上进行编译。使用WebAssembly“原生”模块，您可以获得大部分的速度而避免复杂化。
- **使沙箱原生代码更容易**
	另一方面，像Rust这样的低级语言不会使用WebAssembly来提高速度。但是他们可以用它来保证安全。正如我们在[WASI公告中](https://hacks.mozilla.org/2019/03/standardizing-wasi-a-webassembly-system-interface/)所讨论的那样，WebAssembly默认为您提供轻量级沙盒。因此像Rust这样的语言可以使用WebAssembly来沙箱化原生代码模块。
- **跨平台共享原生代码**
	如果开发人员可以跨不同平台（例如，在Web和桌面应用程序之间）共享相同的代码库，则可以节省时间并降低维护成本。对于脚本和低级语言都是如此。WebAssembly为您提供了一种方法，可以运行在这些平台上，而不会减慢速度。

![](images/01-01-why-768x313.png)

因此，WebAssembly可以真正帮助其他语言解决重要问题。

但是对于今天的WebAssembly，您不希望以这种方式使用它。您可以在所有这些地方*运行* WebAssembly，但这还不够。

现在，WebAssembly只在数字上进行对话。这意味着两种语言可以相互调用对方的函数。

但是如果一个函数接受或返回除数字之外的任何东西，事情变得复杂。你可以：

- 运送一个有非常难用的API的模块，该API仅以数字对话......让模块用户很为难。
- 为希望此模块运行的每个环境添加胶水代码......使模块开发人员很为难。

但事实并非如此。

应该可以运送*单个* WebAssembly模块并让它在任何地方运行......而不会让模块的用户或开发人员为难。

![](images/01-02-user-and-dev-768x737.png)

因此，相同的WebAssembly模块可以使用丰富的API对话，使用复杂类型：

- 在自己的原生运行时运行的模块（例如，在Python运行时中运行的Python模块）
- 用不同源代码语言编写的其他WebAssembly模块（例如，在浏览器中一起运行的Rust模块和Go模块）
- 主机系统本身（例如，为操作系统提供系统接口或提供浏览器的API的WASI模块）

![](images/01-03-star-diagram-768x606.png)

通过一个新的早期提案，我们将看到如何制作这个Just Work™，正如您在本演示中所看到的那样。

https://www.youtube.com/embed/Qn_4F3foB3Q

那么让我们来看看它是如何工作的。但首先，让我们看看我们今天的位置以及我们试图解决的问题。

## WebAssembly与JS对话

WebAssembly不仅限于Web。但到目前为止，WebAssembly的大部分开发都集中在Web上。

那是因为当你专注于解决具体的用例时，你可以做出更好的设计。该语言肯定必须在Web上运行，因此这是一个很好的可以开始的用例。

这给了MVP一个很好的范围。WebAssembly只需要能够与一种语言 - JavaScript对话。

这样做相对容易。在浏览器中，WebAssembly和JS都在同一个引擎中运行，因此引擎可以帮助它们[有效地相互通信](https://hacks.mozilla.org/2018/10/calls-between-javascript-and-webassembly-are-finally-fast)。

![](images/02-01-js-interop-01-768x575.png)![](images/02-01-js-interop-02-768x575.png)

但是当JS和WebAssembly试图互相对话时，有一个问题......他们使用不同的类型。

目前，WebAssembly只能以数值进行对话。JavaScript有数值，但也有很多类型。

甚至数值都不一样。WebAssembly有4种不同的数值：int32，int64，float32和float64。JavaScript目前只有Number（虽然很快会有另一种数字类型，[BigInt](https://github.com/tc39/proposal-bigint)）。

区别不仅在于这些类型的名称。值也是以不同方式存储在内存中。

首先，在JavaScript中，任何值，无论类型，都被放入一个称为盒子（box）的东西（我在另一篇文章中解释了更多的[boxing](https://hacks.mozilla.org/2018/10/calls-between-javascript-and-webassembly-are-finally-fast/#js-to-wasm)）。

相反，WebAssembly的数值具有静态类型。因此，它不需要（或理解）JS盒子。

这种差异使得彼此之间难以沟通。

![](images/02-03-number-mismatch-768x619.png)

但是，如果要将值从一种数值类型转换为另一种数值类型，则有非常简单的规则。

因为它很简单，所以很容易写下来。你可以在[WebAssembly的JS API规范中](https://www.w3.org/TR/wasm-js-api/#tojsvalue)找到这个。

![](images/02-04-mapping-book-768x376.png)

此映射硬编码在引擎中。

这有点像引擎有一本参考书。每当引擎必须在JS和WebAssembly之间传递参数或返回值时，它就会从架子上提取该参考书，以了解如何转换这些值。

![](images/02-05-number-conversion-768x619.png)

拥有如此有限的一组类型（只是数值）使得这种映射非常容易。这对于MVP来说非常棒。它的限制使得无需作出太多艰难的设计决策。

但它使得开发人员使用WebAssembly变得更加复杂。要在JS和WebAssembly之间传递字符串，您必须找到一种方法将字符串转换为数值数组，然后将数值数组转换回字符串。我在上一篇[文章中](https://hacks.mozilla.org/2018/03/making-webassembly-better-for-rust-for-all-languages/)对此进行了解释。

![](images/04_wasm_bindgen_02-768x453.png)

这并困难，但是很乏味。所以构建工具来抽象出来。

例如，像 [Rust的wasm-bindgen](https://rustwasm.github.io/docs/wasm-bindgen/) 和[Emscripten的Embind](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/embind.html#embind) 这样的工具会自动用Web粘合代码包装WebAssembly模块，该代码可以实现从字符串到数值的转换。

![](images/02-07-js-glue-768x735.png)

这些工具也可以为其他高级类型执行类型转换，例如带有属性的复杂对象。

这个方式可行，但有一些非常明显的用例，它不能很好地工作。

例如，有时您只想通过 WebAssembly 透传字符串。您希望JavaScript函数将字符串传递给WebAssembly函数，然后让WebAssembly将其传递给另一个JavaScript函数。

为了达到这个目标，需要做以下事情：

1. 第一个JavaScript函数将字符串传递给JS胶水代码
2. JS胶水代码将该字符串对象转换为数值，然后将这些数值放入线性内存中
3. 然后将一个数值（指向字符串开头的指针）传递给WebAssembly
4. WebAssembly函数将该数值传递给另一侧的JS胶水代码
5. 第二个JavaScript函数从线性内存中提取所有这些数值，然后将它们解码回字符串对象
6. 传递给第二个JS函数

![](images/02-08-encode-decode-01-768x189.png)

![](images/02-08-encode-decode-02-768x328.png)

![](images/02-08-encode-decode-03-768x509.png)

![](images/02-08-encode-decode-04-768x509.png)

![](images/02-08-encode-decode-05-768x328.png)

![](images/02-08-encode-decode-06-768x192.png)

因此，一侧的JS胶水代码只是翻转了它在另一侧所做的工作。很多工作花费在重建基本相同的对象上。

如果字符串只是直接通过WebAssembly透传而没有任何转换，那将更容易。

WebAssembly将无法对此字符串执行任何操作 - 它无法理解该类型。我们不会解决这个问题。

但它可以在两个JS函数之间来回传递字符串对象，因为它们理解类型。

因此，这是[WebAssembly引用类型提议](https://github.com/WebAssembly/reference-types/blob/master/proposals/reference-types/Overview.md#language-extensions)的原因之一。该提议添加了一个名为 `anyref` 的新的基本WebAssembly类型。

使用`anyref`，JavaScript只为WebAssembly提供了一个引用对象（基本上是一个不会泄露内存地址的指针）。此引用指向JS堆上的对象。然后WebAssembly可以将它传递给其他JS函数，这些函数确切地知道如何使用它。

![](images/02-09-anyref-01-768x627.png)

![](images/02-09-anyref-02-768x668.png)

因此，这解决了和JavaScript互操作中最烦人的问题之一。但这不是浏览器中唯一要解决的互操作性问题。

浏览器中还有另一组更大的类型。如果我们要获得良好的性能，WebAssembly需要能够与这些类型进行互操作。

## WebAssembly直接与浏览器通信

JS只是浏览器的一部分。浏览器还有许多其他功能，称为Web API，您可以使用它们。

在幕后，这些Web API函数通常用C++或Rust编写。他们有自己将对象存储在内存中的方式。

Web API的参数和返回值可以是许多不同的类型。很难为这些类型中的每一种手动创建映射。因此，为简化起见，有一种标准的方式来讨论这些类型的结构 - [Web IDL](https://developer.mozilla.org/en-US/docs/Mozilla/WebIDL_bindings)。

当您使用这些功能时，通常是通过使用JavaScript。这意味着您传递的是使用JS类型的值。如何将JS类型转换为Web IDL类型？

就像存在从WebAssembly类型到JavaScript类型的映射一样，也存在从JavaScript类型到Web IDL类型的映射。

所以它就像引擎有另一本参考书，展示了如何从JS到Web IDL。此映射也在引擎中进行了硬编码。

![](images/03-02-mapping-book-768x376.png)

对于许多类型，JavaScript和Web IDL之间的映射是非常直白的。例如，DOMString和JS的String等类型是兼容的，可以直接相互映射。

现在，当您尝试从WebAssembly调用Web API时会发生什么？这是我们遇到问题的地方。

目前，WebAssembly类型和Web IDL类型之间没有映射。这意味着，即使是像数字这样的简单类型，您的调用也必须通过JavaScript。

这是具体工作的方式：

1. WebAssembly将值传递给JS。
2. 在此过程中，引擎将此值转换为JavaScript类型，并将其放入内存中的JS堆中
3. 然后，将该JS值传递给Web API函数。在此过程中，引擎将JS值转换为Web IDL类型，并将其放入内存的不同部分，即渲染器的堆。

![](images/03-03-wasm-to-browser-01-768x422.png)

![](images/03-03-wasm-to-browser-02-768x422.png)

![](images/03-03-wasm-to-browser-03-768x422.png)

这需要更多的工作，并且还会占用更多内存。

有一个明显的解决方案 -创建从WebAssembly到Web IDL的直接映射。但这并不像看起来那么简单。

对于像`boolean`和`unsigned long`（这是一个数字）的简单Web IDL类型，从WebAssembly到Web IDL有明确的映射。

但在大多数情况下，Web API参数是更复杂的类型。例如，API可能需要一个字典，它基本上是一个具有属性或序列（就像一个数组的）对象。

要在WebAssembly类型和Web IDL类型之间进行直接映射，我们需要添加一些更高级别的类型。我们正在这样做 - [GC提案](https://github.com/WebAssembly/gc)。有了它，WebAssembly模块将能够创建GC对象 - 例如结构和数组 - 可以映射到复杂的Web IDL类型。

但是，如果与Web API进行互操作的唯一方法是通过GC对象，那么对于像C++和Rust这样不会使用GC对象的语言来说，这会更加艰难。只要代码与Web API交互，就必须创建一个新的GC对象，并将值从其线性内存复制到该对象中。

这只比我们今天的JS胶水代码略胜一筹。

我们不希望JS胶水代码必须构建GC对象 - 这是浪费时间和空间。出于同样的原因，我们也不希望WebAssembly模块这样做。

我们希望使用线性内存（如Rust和C ++）的语言能够像使用引擎内置GC的语言一样调用Web API。因此，我们需要一种方法来创建线性内存中的对象和Web IDL类型之间的映射。

但是这里有一个问题。这些语言中的每一种都以不同方式表示线性内存中的东西。我们不能只选择一种语言的表示。这将使所有其他语言效率降低。

![](images/03-07-picking-lang-768x497.png)

但内存中针对这些东西的确切布局通常是不同的，也有一些已经通用的抽象概念。

例如，对于字符串，语言通常有一个指向内存中字符串开头的指针，以及字符串的长度。即使字符串具有更复杂的内部表示，通常也需要在调用外部API时将字符串转换为此格式。

这意味着我们可以将此字符串缩减为WebAssembly可以理解的类型...两个i32。

![](images/03-08-types-wasm-understands-768x411.png)

我们可以在引擎中硬编码这样的映射。因此引擎将有另一本参考书，这次是针对WebAssembly的Web IDL映射。

但这里有一个问题。WebAssembly是一种类型检查的语言。为了保证[安全](https://webassembly.org/docs/security/)，引擎必须检查调用代码是否传递了与被调用者要求的类型相匹配的类型。

这是因为攻击者有办法利用类型不匹配从而让引擎做不应该做的事情。

如果你正在使用字符串调用东西，但是你试图将函数传递给整数，引擎会对你大喊大叫。它*应该*对你大喊大叫。

![](images/03-09-type-mismatch-768x418.png)

所以我们需要一种方法让模块明确地告诉引擎，类似这样：“我知道 Document.createElement() 接受一个字符串。但是当我调用它时，我将传递两个整数。使用他们从我的线性内存中的数据创建DOMString。使用第一个整数作为字符串的起始地址，第二个整数作为长度。“

这就是Web IDL提案的作用。它为WebAssembly模块提供了一种在它使用的类型和Web IDL类型之间进行映射的方法。

这些映射在引擎中没有硬编码。相反，一个模块带有自己的映射小册子。

![](images/03-10-booklet-500x272.png)

因此，这为引擎提供了一种方式来表述：“对于此函数，进行类型检查，就好像这两个整数是一个字符串一样。”

不过，这本模块附带的小册子事实是有用的，是因为另一个原因。

有时，通常将其字符串存储在线性内存中的模块希望在特定情况下使用 `anyref` 或者GC类型...例如，如果模块只是传递从JS函数获得的对象到Web API，如DOM节点。

因此，模块需要能够逐个函数（甚至逐个参数）地选择，以便获知如何处理不同的类型。由于映射是由模块提供的，因此可以为该模块定制。

![](images/03-11-granularity-500x272.png)

你怎么生成这本小册子？

编译器会为您处理这些信息。它为WebAssembly模块添加了一个自定义部分。因此对于许多语言工具链，程序员不需要做太多工作。

例如，让我们看一下Rust工具链如何处理最简单的一种情况：将字符串传递给`alert`函数。

```rust
#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}
```

程序员只需告诉编译器使用`#[wasm_bindgen]` 注解将此函数包含在小册子中。默认情况下，编译器会将其视为线性内存字符串，并为我们添加正确的映射。如果我们需要以不同的方式处理它（例如，作为`anyref`），我们必须使用第二个注解告诉编译器。

因此，我们可以在中间剔除JS。这使得在WebAssembly和Web API之间传递值更快。此外，这意味着我们不需要运送太多的JS。

而且我们不必对我们支持的语言做出任何妥协。可以将所有不同类型的语言编译为WebAssembly。这些语言都可以将它们的类型映射到Web IDL类型 - 无论语言是使用线性内存还是GC对象，还是两者都使用。

一旦我们退后一步看看这个解决方案，我们意识到它解决了一个更大的问题。

## WebAssembly与所有事物交谈

这是我们回到介绍中的承诺的地方。

有没有一种可行的方法让WebAssembly使用不同类型的系统与不同的东西对话？

![](images/04-01-star-diagram-768x581.png)

我们来看看有什么可选的方案。

您*可以*尝试创建在引擎中硬编码的映射，例如WebAssembly到JS和JS到Web IDL。

但要做到这一点，对于每种语言，您必须创建一个特定的映射。并且引擎必须明确支持这些映射中的每一个，并在任何一方的语言发生变化时更新它们。这会造成真正的混乱。

这就是早期编译器的设计方式。从每种源语言到每种机器代码语言都有一个管道。我[在WebAssembly上的第一篇文章中](https://hacks.mozilla.org/2017/02/a-cartoon-intro-to-webassembly/)对此进行了更多的讨论。

![](images/03-05-langs05-768x474.png)

我们不想要这么复杂的东西。我们希望所有这些不同的语言和平台能够相互通信。但我们也需要它可扩展。

所以我们需要一种不同的方式来做到这一点...更像现代编译器架构。它们在前端和后端之间分离。前端从源语言到抽象中间表示（intermediate representation/IR）。后端从IR到目标机器代码。

![](images/03-06-langs06.png)

这就是来自Web IDL的洞察力所在。当你眯着眼睛看时，Web IDL看起来像一个IR。

现在，Web IDL非常适合Web。而有很多Web外的WebAssembly用例。因此，Web IDL本身并不是一个很好的IR。

但是，如果您只是使用Web IDL作为灵感并创建一组新的抽象类型呢？

这就是我们提出WebAssembly接口类型提议的由来。

![](images/04-06-types-as-IR-500x321.png)

这些类型不是具体类型。他们不像今天WebAssembly中的 `int32` 或 `float64` 类型。WebAssembly中没有对它们进行任何操作。

例如，WebAssembly中不会添加任何字符串连接操作。相反，所有操作都在两端的具体类型上执行。

有一个可以实现这一点的关键点：对于接口类型，双方并不试图共享表示。相反，默认是在一侧和另一侧之间复制值。

![](images/04-07-copy-768x565.png)

In cases where the reference is just passing through the WebAssembly module (like the `anyref` example I gave above), the two sides still don’t need to share a representation. The module isn’t expected to understand that type anyway… just pass it along to other functions.

有一种情况似乎是这条规则的例外：我之前提到的新参考值（如`anyref`）。在这种情况下，在两侧之间复制的是指向对象的指针。所以两个指针指向同一个东西。理论上，这可能意味着他们需要共享一个表示。

如果引用只是传递WebAssembly模块（就像`anyref`我上面给出的示例），双方仍然不需要共享表示。无论如何，模块不会理解该类型......只需将其传递给其他函数即可。

但有时双方都希望分享代表。例如，GC提案添加了一种[创建类型定义](https://github.com/WebAssembly/gc/blob/master/proposals/gc/MVP-JS.md#type-definition-objects)的方法，以便双方可以共享表示。在这些情况下，要分享多少表示的选择取决于设计API的开发人员。

这使得单个模块与许多不同语言交互变得容易得多。

在某些情况下，与浏览器一样，从接口类型到主机的具体类型的映射将被引入引擎。

因此，一组映射在编译时被烘焙，另一组映射在加载时被传递给引擎。

But there are times where the two sides will want to share a representation. For example, the GC proposal adds a way to [create type definitions](https://github.com/WebAssembly/gc/blob/master/proposals/gc/MVP-JS.md#type-definition-objects) so that the two sides can share representations. In these cases, the choice of how much of the representation to share is up to the developers designing the APIs.

This makes it a lot easier for a single module to talk to many different languages.

In some cases, like the browser, the mapping from the interface types to the host’s concrete types will be baked into the engine.

So one set of mappings is baked in at compile time and the other is handed to the engine at load time.