+++
title = "[译] 使用CloudEvents和CloudEvents生成器"

date = 2020-04-07
lastmod = 2020-04-07
draft = false

tags = ["Istio"]
summary = "本文档讨论了CloudEvents和CloudEvents Generator的使用方法，帮助更好地理解本教程系列其他教程中使用的演示项目，这是《构建事件驱动的云应用和服务》系列教程的第二篇。"
abstract = "本文档讨论了CloudEvents和CloudEvents Generator的使用方法，帮助更好地理解本教程系列其他教程中使用的演示项目，这是《构建事件驱动的云应用和服务》系列教程的第二篇。"

[header]
image = "headers/post/202004-microservices-choreography-vs-orchestration.jpg"
caption = ""

+++

英文原文来自 [Using CloudEvents and CloudEvents Generator](https://medium.com/google-cloud/using-cloud-events-and-cloud-events-generator-4b71b8a90277)，作者 [Ratros Y.](https://medium.com/@ratrosy)，文章发表于2019年9月。 

------

本文档讨论了CloudEvents和CloudEvents Generator的使用方法，帮助更好地理解本教程系列其他教程中使用的演示项目，这是 [《构建事件驱动的云应用和服务》](../202004-building-event-driven-cloud-applications-and-services/)系列教程的第二篇。

## CloudEvents

CloudEvents是由云原生计算基金会的serverless工作组组织的一个倡议，其目标是规范事件发布者如何描述他们的事件。目前这个倡议还在努力中，规范还没有稳定下来；许多云服务提供商和开源项目已经宣布了采用这个规范的计划，包括Knative Eventing和Azure。

> **备注**
>
> 您可以在这里阅读 [最新版本的规范（0.3）](https://github.com/cloudevents/spec/blob/v0.3/spec.md)。

CloudEvent 由许多属性组成，例如事件的 ID 和事件的类型。CloudEvent Specification 定义了 CloudEvent 可能具有的必要和可选属性集合，如下所示：

| Attribute Name        | 类型                          | 备注                                                         |
| --------------------- | ----------------------------- | ------------------------------------------------------------ |
| `id`                  | String                        | Required. The ID of the event. A CloudEvent is uniquely identified with its `source` and `id`. |
| `source`              | String (URI-reference)        | Required. The source of the event.                           |
| `specversion`         | String                        | Required. The version of CloudEvents Specification the Cloud Event uses. |
| `type`                | String                        | Required. The type of the event.                             |
| `datacontentencoding` | String (RFC 2045 Section 6.1) | Optional. The encoding of `data` (if the field stores binary data). |
| `datacontenttype`     | String (RFC 2046)             | Optional. The content type of `data`.                        |
| `schemaurl`           | String (URI-reference)        | Optional. The schema of data.                                |
| `subject`             | String                        | Optional. The subject of the event.                          |
| `time`                | String (Timestamp)            | Optional. The timestamp when the event happens.              |
| `data`                | N/A                           | Optional. The payload of the event.                          |

此外，CloudEvents 允许开发人员通过扩展来添加自己的属性集。[文档化的扩展列表可在这里获得](https://github.com/cloudevents/spec/blob/master/documented-extensions.md).

CloudEvents 绑定有助于在应用、服务和设备之间传输事件。例如，您可以将事件绑定到 JSON 格式，或者将其映射到 HTTP 请求。

## CloudEvents 生成器

Normally, to build a CloudEvent, you will have to use an in-memory structure of your preferred programming language directly, or uses CloudEvents SDK (also a work in progress):

通常情况下，要构建一个CloudEvent，需要直接使用自己喜欢的编程语言的内存结构，或者使用CloudEvents SDK（也在进行中）:

```javascript
import datetime
import json
import uuid

event = {}
event['id'] = str(uuid.uuid4())
event['source'] = 'my-event-source'
event[type] = 'my-event-type'
event['specversion'] = '0.3'
event['time'] = datetime.datetime.utcnow().isoformat('T') + 'Z'
event['data'] = 'Hello World!'
event_json_str = json.dumps(event)

# Alternatively with Cloud Events SDK
from cloudevents.sdk.event import v03

event = (
	v03.Event().
	SetEventID('my-event-id').
	SetSource('my-event-source').
	SetEventType('my-event-type').
	SetEventTime(datetime.datetime.utcnow().isoformat('T') + 'Z').
	SetData('Hello World!')
)
```

在本系列教程中，为了简单起见，我们使用一个实验性的项目CloudEvents Generator来发布和接收事件。该工具以JSON或YAML格式的事件模式作为输入，并准备一个自己的事件schema，你可以用它来发布和接收事件。schema输入和事件库也可以帮助团队在事件驱动的系统中更好地协作。例如，要用CloudEvents Generator发送上述片段中的事件，首先指定 schema 如下:

```javascript
events:
  # Define an event type, basic
  basic:
    attributes:
      # Set up an attribute id which is auto-poulated with UUIDv4 string
      id:
        type: string
        format: UUIDv4
        auto: true
      # Set up an attribute source with a default value
      source:
        type: string
        default: my-event-source
      # Set up an attribute type with a default value
      type:
        type: string
        default: my-event-type
      # Set up an attribute specversion with a default value
      specversion:
        type: string
        default: "0.3"
      # Set up an attribute time which is auto-populated with RFC3339 timestamp
      time:
        type: string
        format: RFC3339
        auto: true
      # Set up an attribute data
      data:
        type: string
```

Pass the schema to CloudEvents Generator, and ask it to prepare a Python package. You can then use this package to create the same event:

将模式传给CloudEvents Generator，并要求它准备Python包。然后你可以使用这个包来创建同样的事件：

```javascript
from mypackage import Basic

# Attributes id and time will be auto-populated
# If not specified, attributes source, type, and specversion use their respective default values
event = Basic(data = 'Hello World!')
event_json_str = event.to_JSON()
```

要查看CloudEvents Generator的运行情况，请点击下面的按钮在Cloud Shell中试用。

> 译者注：实操环节请在原文中操作。
