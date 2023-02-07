### Kinesis Date Stream 学习手册

##### 1. Kinesis Date Stream 是什么？

`Kinesis Date Stream`主要用于收集和处理流式数据记录，可以使用`Kinesis Date Stream`接受和聚集持续增长的数据例如：基础设施的日志，应用程序的日志，流媒体数据。伴随的数据的摄入可以实时的处理这些摄入的数据，而且一般处理过程都是非常轻量级的。可以使用`Kinesis Client Library`来创建处理`Kinesis Date Stream`流式数据记录的应用程序，读取数据流中的记录做逻辑处理后再发送到 AWS 的其他组件。使用`Kinesis Date Stream`做流式数据记录处理的最大好处是：你可以几乎同时处理`Kinesis Date Stream`中的数据记录，一旦数据被摄入到`Kinesis Date Stream`中来。`Kinesis Date Stream`确保数据流中的记录的持久性和弹性伸缩。理论上数据摄入到`Kinesis Date Stream`到可以被处理的延时通常小于 1s。

##### 2. Kinesis Date Stream 术语和概念

1. Kinesis Data Stream ：包含一组分片，每个分片中包含一组连续的记录，`Kinesis Date Stream`中的每个记录中包含一个序列 ID；
2. Data Record ：一个`Kinesis Date Stream`的基本存储单元，包含三个部分：一个序列的 ID，一个分区键和一个数据`blob`(无法修改的字节序列)，`Kinesis Date Stream`无法解析，检查和修改这个字节序列；
3. Capacity Mode ：`Kinesis Date Stream`的容量模式解决了怎样管理`Kinesis Date Stream`的容量和需要处理的数据量，容量模式分成两种**on-demand**、**provisioned**。**on-demand**模式能自动管理`Kinesis Date Stream`的分片来满足吞吐量的需求。**provisioned**模式需要指定分片数，这种情况下总的容量将所有分片的容量总和；
4. Retention Period ：指当记录被摄入到`Kinesis Date Stream`后可以访问到该记录的时长，默认是 24 小时，最长支持 365 天；
5. Producer ：生产者可以摄入数据记录到`Kinesis Date Stream`；
6. Consumer ：消费者可以访问数据记录并可以处理该数据记录；
7. Amazon Kinesis Data Streams Application ：应用程序可以部署在 AWS 的计算资源上来访问和处理`Kinesis Date Stream`中的记录，同时应用程序可以在处理后将数据结果再摄入另一个`Kinesis Date Stream`这样可以使应用程序可以实现一个复杂的拓扑实时处理流。多个应用程序可以同时消费`Kinesis Date Stream`中的记录。我们可以开发两种 consumer：1.共享的扇出消费者；2.增强的扇出消费者。
8. Shard ：在`Kinesis Date Stream`中的一个分片关联一组连续的数据记录，一个`Kinesis Date Stream`包含一个或多个分片，每个分片提供固定的容量，最多每秒 5 次或最大 2M 每秒的读数据和最多每秒 1000 次或最大 1M 每秒的写数据(数据大小中包含了分区键)，所以计算`Kinesis Date Stream`的容量总和是包含所有分片容量的总和。
9. Partition Key ：`Kinesis Date Stream`将所有的数据记录分别存储在几个分片中，在记录中的分区键将决定该记录最后关联到哪个分片中。partition key 使一个 unicode 的编码字符串，最大的长度是 256 个字符，`Kinesis Date Stream`把 partition key 用 MD5 计算成一个 128 的数据，每个分区有个一个 hash key 的范围，这样将一个分区键与一个`Kinesis Date Stream`里的分区关联起来。当一个应用程序摄入一个数据记录时，必须指定一个分区键。
10. Sequence Number ：`Kinesis Date Stream`将为摄入的数据记录赋值一个序列号，在一个分片中的每一个分区键这个序列都是唯一的，同时随的摄入时间的增加这个序列号也会自增。
11. Kinesis Client Library ：`Kinesis Client Library`可以使你开发的应用程序能容错的消费`Kinesis Date Stream`中的数据记录。可以支持独立的处理器处理每个有数据记录的分区。同时也支持简单的读取`Kinesis Date Stream`中的数据记录。

##### 2. 分区键和MD5 hash key和分区的关系

当写入一个数据记录到`Kinesis Date Stream`时，除了要提供Stream name以外还需要提供partition ID,`Kinesis Date Stream`使用MD5算出一个hash key,`Kinesis Date Stream`中的shard对应着一组hash key, 这样写入的数据记录就存储到了对应的shard上了，每个shard上的数据记录时顺序存放的，`Kinesis Date Stream`会为每个数据记录赋值一个序列号，这个序列号是随着写入时间递增的，如果需要顺序写入必须使用同一个partition ID。

##### 3. Kinesis Date Stream两种容量模式

1. 按需模式：`Kinesis Date Stream`会根据写入和读取的吞吐量来自动调节shard数量，但是需要处理在自动调节过程中出现的写入和读取异常；
2. 预制模式：在创建`Kinesis Date Stream`的时候就指定shard的数量，当吞吐量无法满足实现需求时，可以手动调节shard的数量；
