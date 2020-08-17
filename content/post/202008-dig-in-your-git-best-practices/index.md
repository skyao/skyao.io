+++
title = "[译] 挖掘git最佳实践"

date = 2020-08-17
lastmod = 2020-08-17
draft = true

tags = ["Git"]
summary = "最简单的最佳实践之一: 正确使用  .gitignore 文件"
abstract = "最简单的最佳实践之一: 正确使用  .gitignore 文件"

[header]
image = ""
caption = ""

+++

英文原文来自 [DIG in Your GIT — Best Practices](https://dzone.com/articles/dig-in-your-git-best-practices)，作者  [Rajeev Bera](https://dzone.com/users/4394462/acompiler20.html)。

-----------------------

这是**最简单的最佳实践之一**，你可以在2分钟内开始使用。但影响将是巨大的。

今天我将分享我一直以来最喜欢的实践之一--**DIG in your GIT**

而且我还为你准备了一个鼓励环节，我在这篇文章中与你分享了两个可下载的pdf，其中包含51+重要的git命令与单行总结，以及35+git最佳实践。

不要忽略Git仓库中的.gitignore（DIG）。我注意到过去很多开发者都没有使用.gitignore文件。

使用.gitignore文件是git的最佳实践之一。而我将在这篇文章中介绍gitignore如何通过其他优势来提升你的代码质量。

此外，我还将解释如何使用你的全局.gitignore文件（无需添加或推送）。而这个综合文件将被你所有的仓库使用。 

所以，让我们开始吧......

### 什么是.gitignore？

没有任何 git ignore 命令可以直接用来忽略版本库中不需要的文件，取而代之的是，应该使用 .gitignore 文件。

简单来说，.gitignore文件是一个文本文件，它告诉Git要忽略哪些文件。

Git 在工作副本中会检查三种东西：

1. Untracked - 未被暂存（staged）或提交（committed）的变更。

2. Tracked - 之前已经暂存（staged）或提交（committed）的所有变更。

3. 忽略 - 您让 Git 忽略的所有文件。

创建 .gitignore 文件很简单，创建一个文本文件，并将其命名为 .gitignore (就是这样)

记得在这个文件名的开头加一个点.。

### .gitignore文件有几种类型？

我见过很多开发者使用本地的.gitignore文件。他们将gitignore文件添加到他们的项目仓库中。但很少有人使用全局文件。在本节中，我将解释这两种类型。

有两种类型的.gitignore文件：

1. 本地.gitignore文件

2. 全局.gitignore文件

#### Local .gitignore 文件

如果把.gitignore文件添加到git仓库的根目录下，它将被视为一个本地文件。这意味着.gitignore文件将在该仓库中工作，而且.gitignore文件应该提交到你的仓库中。 

#### Global .gitignore 文件

如果你把一个类似的文件放在你的 home 目录的根目录下，它将作为一个全局的.gitignore文件。

这意味着什么？

这个文件会影响你在机器上使用的每个仓库。

使用全局文件最显著的好处是，你不需要提交它。而且做一个改动就会影响你所有的仓库。

### .gitignore文件的基本规则

.gitignore文件中的每一行都指定了一个模式。 以下是一些基本的规则，可以帮助你设置.gitignore文件：

1. .gitignore文件中任何以hash（#）开头的行都是注释。
2. \ 符号用于转义特殊字符
3. / 表示，该规则只适用于位于同一文件夹中的文件和文件夹。
4. 星号(`*`)表示任何数量的字符(零次或多次出现)
5. 两个星号(`**`)用于指定任意数量的子目录。
6. 问号(?)代替零或一个字符。
7. 感叹号(!)表示反转规则。
8. 空行被忽略
9. 你可以忽略整个目录路径，并在末端添加一个/。

### 哪些文件应该被忽略

您可以忽略许多文件，这些文件通常是自动生成的，平台特定的，以及其他本地配置文件。

1. 含有敏感信息的文件 
2. 编译后的代码，如.dll或.class。
3. 系统文件，如.DS_Store或Thumbs.db。
4. 包含临时信息的文件，如日志、缓存等。
5. 生成的文件，如 dist 文件夹

### 使用gitignore的优势

这里有三大优势（这就是为什么我使用.gitignore的原因）：

1. 通过忽略不需要的文件来清理仓库。
2. 仓库的大小可以得到控制，特别是在做一个大项目的时候。
3. 每一次提交、推送和拉取请求都将是干净的。

毋庸置疑，Git 是强大的。但归根结底，它只是另一个计算机程序。

所以，使用最佳实践和保持代码仓库稳定需要团队的努力，并确保你使用git ignore文件。

另外，你可以从 [这里](https://acompiler.com/git-commands/) 下载51个git命令和35个Git最佳实践。

所以让我知道，你是喜欢本地的gitignore还是全局的gitignore文件？




