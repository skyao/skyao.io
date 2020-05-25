+++
title = "[译] 在AWS上迁移单体应用到serverless架构"

date = 2020-05-16
lastmod = 2020-05-16
draft = true

tags = ["EDA","Serverless"]
summary = "在AWS上迁移单体应用到serverless架构"
abstract = "在AWS上迁移单体应用到serverless架构"

[header]
image = ""
caption = ""

+++

英文原文来自 [Migrating Monolithic Apps to Serverless Architecture on AWS](https://www.sicara.ai/blog/serverless-architecture-migration-aws)，作者 Nicolas。

> 备注：快速翻译（机翻+人工校对，没有精修），质量不高，一般阅读可以，不适合传播，谢绝转载。

许多公司在AWS上使用无服务器架构创建应用。

他们通常从新项目的试点开始。

然后，被该技术所折服，他们开始研究将其战略遗留应用迁移到无服务器架构上。

这些应用可能具有以下特点：

- 构建在传统的基础设施上，如内部服务器

- 为用户提供基本服务，服务中断是不可接受的。

- 不断发展，以满足新的要求

让我们来谈谈将此类应用迁移到AWS云上的无服务器架构的挑战吧!



