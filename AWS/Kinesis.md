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

##### 2. 分区键和 MD5 hash key 和分区的关系

当写入一个数据记录到`Kinesis Date Stream`时，除了要提供 Stream name 以外还需要提供 partition ID,`Kinesis Date Stream`使用 MD5 算出一个 hash key,`Kinesis Date Stream`中的 shard 对应着一组 hash key, 这样写入的数据记录就存储到了对应的 shard 上了，每个 shard 上的数据记录时顺序存放的，`Kinesis Date Stream`会为每个数据记录赋值一个序列号，这个序列号是随着写入时间递增的，如果需要顺序写入必须使用同一个 partition ID。

##### 3. Kinesis Date Stream 两种容量模式

1. 按需模式：`Kinesis Date Stream`会根据写入和读取的吞吐量来自动调节 shard 数量，但是需要处理在自动调节过程中出现的写入和读取异常；
2. 预制模式：在创建`Kinesis Date Stream`的时候就指定 shard 的数量，当吞吐量无法满足实现需求时，可以手动调节 shard 的数量；

##### 4. 写入数据到`Kinesis Date Stream`

可以使用 AWS SDK 创建生产者程序来写入数据到`Kinesis Date Stream`。有两个不同的 API 来处理写入数据`PutRecords`和`PutRecord`。`PutRecords`使用一个 HTTP 连接来发送多个`Data Record`到`Kinesis Date Stream`,而`PutRecord`每次 HTTP 连接只发送一个`Data Record`。

1. `PutRecords`提供更高的吞吐量，一个 HTT 请求中可以最多包含 500 个`Data Record`。支持最大 1MB 的`Data Record`和 5MB 的 HTTP 请求，发送顺序是在 HTTP 请求中的顺序。每个 HTTP 请求可以包含不同分区键的`Data Record`，分区键的数量最好要远远大于分区的数量，这样的分区键的设计有助于提高吞吐量。对于每个`Data Record`的处理结果在请求响应中都有反馈，正确写入的`Data Record`将返回`Sequence Number`和分区 ID，对于异常写入将返回`error code`和`error message`。

2. `PutRecord`每次 HTTP 连接写入一个`Data Record`。当写入的操作几乎同时进行的时候会发生`Sequence Number`不保证自增的情况，这时如果需要强顺序一致性的写入我们需要添加`SequenceNumberForOrdering`来保证强顺序一致性。不管生产者是否保证强顺序一致性消费者程序始终按照`Sequence Number`的顺序来消费`Data Record`。

3. 使用 KPL(Kinesis Producer Library)来写入数据
   KPL 是对 AWS SDK 的一层逻辑封装，它提供了高吞吐量的数据摄入，它支持同步和异步的摄入，KPL 可以将例如吞吐量、error 或者其他的指标发送到 cloudwatch 用于监控 KPL 的处理过程。以下是一些 KPL 的技术术语和一些基本概念：

- User Record：我们之前提到的`data record`是一个序列号+分区键+数据的组合，而 KPL 的 user record 指的是一个逻辑概念，它包含 Kinesis 的`data record`的三个要素但是可以有更多的逻辑属性；
- 批量处理：KPL 使用批量处理来提高数据摄入的吞吐量，批量处理有两种方式：聚合，将多个`User Record`聚合到一个`data record`里面；收集，使用`PutRecords`来发送多个 records 到多个 shards，默认这两种批处理的方式都开启。
  **KPL 目前不支持 Windows10 本地调试**

##### 5. 读取数据到`Kinesis Date Stream`

1. 使用 console 上的 Data Viewer 来读取数据，当`Kinesis Date Stream`中有数据记录时，我们首先需要选择 shard-id 来指定我们从哪个 shard 读取数据，还有 5 个读取数据的参数说明如下：

- At sequence number: 指定序列号来指定读取数据记录；
- After sequence number: 指定从哪个序列号开始读取数据记录；
- At timestamp: 指定数据摄入的时间开始读取数据记录；
- Trim horizon: 从最早的数据记录读取游标开始读取；
- Latest: 读取最近刚摄入的数据记录。

2. 使用 KCL(Kinesis Client Library)来读取数据

KCL 可以用来消费和处理`Kinesis Date Stream`中的数据记录，并提供了分布式处理数据的复杂逻辑，包括负载均衡、异常处理、租约处理、对重分区的支持，使用者只需要专注在处理数据记录的逻辑上。KPL 的主要功能是连接`Kinesis Date Stream`，获取所有分区，读取每个分区上的数据记录，简化管理每个数据分区的读取程序，拉取数据记录到每个分区的处理程序，游标处理程序会记录游标位置来处理中断和异常，协同所有分区处理程序同步处理重分区。

- KCL consumer application: 一个使用 KCL 来读取`Kinesis Date Stream`数据记录的应用程序；
- Consumer application instance: 一般`KCL consumer application`使分布式的应用程序，有多个实例协同读取数据记录；
- worker: 对于消费者实例的抽象化概念，同步分区和租约信息，跟踪分区分配状态，处理分区数据记录；
- lease: worker 和 shard 之间的绑定信息，一个 worker 默认可以同时保存多个 lease，但是一个 lease 只能被一个 worker 持有；
- lease table: 一个 DynamoDB 表记录租约信息，用于多个 worker 之间同步；
- Record processor: 对消费者处理数据记录的逻辑定义，一个 woker 可以实例化一个 record processor。

lease table 将是全局唯一的 DynamoDB 表，一般使用应用程序名来命名。当应用程序启动后，由一个 worker 来创建这个表，表中的每行记录代表着一个被 worker 处理的 shard 信息。表结构定义如下：

- checkpoint: 最近的游标指向位置的序列号，这个值是每个`Kinesis Date Stream`唯一的。
- checkpointSubSequanceNumber: 当我们开启了KCL的聚合和收集功能时，将使用subsequancenumber来扩张sequance number来追踪包含在数据记录中的每个user records。
- leaseCounter: lease的版本记录，worker可以判断他们的lease是否被其他worker占用。
- leaseKey: lease表中的唯一标识，相当于主键的概念。
- leaseOwner: worker信息。
- ownerSwitcherSinceCheckpoint: 自从上次游标被设置后lease被多少个worker处理过。
- parentShardId: 确保子shard开始处理前父shard被完全处理。这样可以确保按需消费数据记录。
- hashrange: PeriodicShardSyncManager用来介个时间创建缺失的lease信息。
- childshards： LeaseCleanupManager用来判断是否可以删除父shard的租约信息。
- shardID: 分区ID。
- stream name: `Kinesis Date Stream`的唯一标识。

当应用程序收到了DynamoDB的吞吐量异常时，我们需要增加预制的吞吐量，KCL创建的DynamoDB预制的吞吐量是每秒10次读和写。


