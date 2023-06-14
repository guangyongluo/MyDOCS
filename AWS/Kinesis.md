### Kinesis 学习手册

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
- checkpointSubSequanceNumber: 当我们开启了 KCL 的聚合和收集功能时，将使用 subsequancenumber 来扩张 sequance number 来追踪包含在数据记录中的每个 user records。
- leaseCounter: lease 的版本记录，worker 可以判断他们的 lease 是否被其他 worker 占用。
- leaseKey: lease 表中的唯一标识，相当于主键的概念。
- leaseOwner: worker 信息。
- ownerSwitcherSinceCheckpoint: 自从上次游标被设置后 lease 被多少个 worker 处理过。
- parentShardId: 确保子 shard 开始处理前父 shard 被完全处理。这样可以确保按需消费数据记录。
- hashrange: PeriodicShardSyncManager 用来介个时间创建缺失的 lease 信息。
- childshards： LeaseCleanupManager 用来判断是否可以删除父 shard 的租约信息。
- shardID: 分区 ID。
- stream name: `Kinesis Date Stream`的唯一标识。

当应用程序收到了 DynamoDB 的吞吐量异常时，我们需要增加预制的吞吐量，KCL 创建的 DynamoDB 预制的吞吐量是每秒 10 次读和写。

##### 6. Kinesis Video Stream 是什么？

`AWS Service`管理的`Amazon Kinesis Video Stream`可以用来处理和分析实时的或者是批量的视频或音频数据。`Amazon Kinesis Video Stream`不只是存储视频或音频数据，你也可以实时的观看。可以使用`Amazon Kinesis Video Stream`来捕获从各种设备传输来的海量直播视频数据，包括智能手机、安全监控摄像头、网络摄像机，车载摄像头、无人机等。也可以传输没有视频且时间排序的数据比如音频、热成像、深度数据、雷达数据等，一个直播视频流从这些设备传输到`Amazon Kinesis Video Stream`后你可以构建一个应用程序来一帧一帧的实时的访问这些数据。你可以配置`Amazon Kinesis Video Stream`存储流媒体数据一段时间，`Amazon Kinesis Video Stream`将自动的存储和加密这些数据，此外，`Amazon Kinesis Video Stream`将按时间索引（基于生产者的timestamps和摄入Kinesis的timestamps）来存储这些数据，你可以建立应用程序来周期性的批量处理视频数据，或者你也可以根据不同的需求来创建应用程序请求特定的历史数据，`Amazon Kinesis Video Stream`的主要功能包含：

- 可以连接和接收各种设备的数据，只需要使用`producer libraries`配置你的设备就可以实时或批量地上传你的数据流。
- 可以持久化、加密和时间排序媒体数据，可以配置媒体数据持久化的时间，`Amazon Kinesis Video Stream`也可以加密数据，最后根据 producer 产生时间和`Amazon Kinesis Video Stream`服务端时间排序媒体数据，应用程序可以按照时间索引来获取`Amazon Kinesis Video Stream`中的数据。
- 聚焦管理应用程序而非基础资源，`Amazon Kinesis Video Stream`是无服务的应用组件，所以你不需要担心部署，配置和自动伸缩底层基础资源。当你的应用消费增长或是收缩，`Amazon Kinesis Video Stream`会自动的处理所有的管理和维护工作。
- 支持创建实时或批量处理程序，使用`Amazon Kinesis Video Stream`可以创建实时的应用程序来处理流媒体数据，或者在没有严格延迟需求下创建应用程序来批量处理流媒体数据。
- 数据更加安全：`Amazon Kinesis Video Stream`加密所有的流入持久化数据，`Amazon Kinesis Video Stream`强制基于传输层安全的加密策略，初次之外还将使用AWS KMS加密所有的持久化数据。你也可以使用IAM管理访问权限。

##### 7. Amazon Kinesis Video Stream如何工作

- Producer：生产者能将流媒体数据发送到`Amazon Kinesis Video Stream`里面，例如：监控摄像头，手机摄像头，电话会议等等。一个生成者可以生产一个或多个`Amazon Kinesis Video Stream`，比如一个摄像头可以将视频数据发送到一个`Amazon Kinesis Video Stream`而将音频数据发送到另一个`Amazon Kinesis Video Stream`。`Kinesis Video Stream Producer libraries`是AWS提供的一个易用的开发包，可以安全可靠的连接到`Amazon Kinesis Video Stream`，实时或者批量的上传流媒体数据；
- `Kinesis Video Stream`：一个可以存储、传输实时流媒体数据的AWS资源，支持一个生成者上传数据，多个消费者并发地接收处理、分析数据。可以存储音频、视频和其他基于时间编码的数据，例如深度传感器、雷达传感器的基于时间编码的数据。可以使用AWS management控制台或者AWS SDK来创建`Amazon Kinesis Video Stream`；
- Consumer：消费者从`Amazon Kinesis Video Stream`接收流媒体数据，例如fragments和frames，支持实时或批量的处理分析流媒体数据,当实时性要求不高时，可以通过时间索引来处理持久数据。AWS提供了一个`Kinesis Video Stream Parser Library`开发包，应用程序可以使用开发包接收流媒体数据，低延时的处理分析数据。它可以帮助开发者解析流媒体数据帧这样开发者只需专注在处理和分析工作上。
- 回放流媒体数据：可以使用HLS(HTTP Live Streaming: 一个标准的流媒体传输HTTP协议)，MPEG-DASH(Dynamic Adaptive Streaming over HTTP: 可以支持高质量的流媒体传输HTTP协议)；
- `Amazon Kinesis Video Stream`提供创建和管理streams的API，同时也提供读取和写入流媒体数据的API；
- Producer API: `Amazon Kinesis Video Stream`提供了`PutMedia`API往`Amazon Kinesis Video Stream`写入媒体数据，生产者发送`media fragments`到Kinesis，一个fragment包含了一连串的数据帧。当一个fragment发送到`Amazon Kinesis Video Stream`后会被赋一个唯一的递增fragment number，保证时间序列化，同时生产者生成的时间和服务端时间也将会被当成metadata记录下来；
- Consumer API: 指定一个开始的fragment使用`GetMedia`可以按被写入的顺序(fragment number)返回fragments。这些在fragment中的流媒体数据被打包成MKV结构的数据。`GetMedia`能够自动的分析fragment是否已被打包存储，如果已经被打包存储将从data store返回，如果新的fragment还没有被打包存储就直接去内存中的stream buffer里读取。`GetMedia`还可以处理已经持久化打包的数据，然后追上生产者写入速度转变为实时消费。使用`GetMediaFromFragmentList`和`ListFragments`组合API可以指定特定的时间范围或fragments范围，使用顺序或者并发的方式批量获取fragments，这样可以使用分布式应用处理，将加快并行处理大量数据；
- 当生产者发送一个PutMedia请求时，它会发送一个连续的流媒体数据fragments，和一个`media metadata`。`Amazon Kinesis Video Stream`使用`Kinesis Video Streams chunks`来存储进来的流媒体数据。每个chunk包含一个media meatdata,一个fragment和一个`Amazon Kinesis Video Stream`自身的metadata例如: fragment number, server-side time, produer-side time。当一个消费者请求一个流媒体数据时，`Amazon Kinesis Video Stream`返回一连串的chunks。

##### 8. Kinesis Video Streams playback

- GetMedia：可以使用GetMedia API构建一个应用程序来处理Kinesis Video Streams。GetMedia是一个实时的低延时API。
- HLS：HTTP Live Steaming(HLS)是一个基于HTTP协议的行业标准流媒体通信协议，可以使用HLS去预览Kinesis video steam，也可以实时播放视频。一般情况下延迟3-5秒最大范围1-10秒主要取决于你的使用场景和网络。你也可以使用第三方的播放器比如：Video.js，Google Shaka Palyer。还可以直接使用浏览器播放HLS(Apple Safari, Microsoft Edge)。
- MPEG-DASH：Dynamic Adaptive Streaming over HTTP(DASH)：是一个自适应码率的流媒体协议可以通过HTTP的web服务提供高质量的媒体内容.
- GetClip API：你可以使用GetClip API下载一个包含指定时间范围的流媒体片段(一个MP4文件)。
- Video playback with HLS：预览Kinesis video stream首先需要使用GetHLSStreamingSessionURL创建一个streaming session，这个API返回一个包含session token的URL，使用这个URL来播放。
- Video playback with MPEG-DASH：预览Kinesis video stream首先需要使用GetDASHStreamingSessionURL创建一个streaming session，这个API返回一个包含session token的URL，使用这个URL来播放。

##### 9.使用元数据

可以使用Amazon Kinesis Video Streams Producer SDK来为每个fragment嵌入元数据，元数据是一个可以修改的键值对，你可以用它来描述fragment的内容，使用GetMedia或者GetMediaForFragmentList来获取元数据。在整个流数据保留期内元数据和fragments一起存储，你的消费者应用使用Kinesis video stream Parser Library来读取，处理和响应元数据。

在数据流中有两种模式的元数据可以嵌入fragments：

- 不持久 - 在一个数据流中你可以将元数据一次或临时地附加在fragments上，基于业务的需要附加。举个列子一个智能摄像头检测到了一种动作就添加metadada到相应的fragments上然后再发送到Kinesis video stream，元数据的格式例如：Motion=true。
- 持久 - 可以在一个数据流中持久地附加元数据到后续的fragments上，举个例子一个智能摄像头将当前的经度和纬度附加到所有的fragments然后再发送到Kinesis video stream，元数据的格式例如：Lat = 47.608013N，Long = -122.335167N。

你可以根据应用程序的需要独立地附加两种模式的元数据在同一个fragment上，这个嵌入的元数据可能包含对象检测、活动追踪、GPS坐标或者是任何你想附加到相关的fragment上的元数据信息。临时的元数据主要用于标记数据流内的事件，持久的元数据主要用于识别发生给定事件的片段，持久的元数据将应用到每个连续片段直到将其取消。

添加metadata可以使用相同的名字，Producer SDK收集所有的metadata items到metadata queue里面直到它们被附加到下一个fragment，这个队列会被清理，如果需要再附加metadata需要再次调用putKinesisVideoFragmentMetadata或者putFragmentMetadata。

##### 10.Kinesis Video Streams data model

Producer库和Stream Parser库支持视频数据中嵌入信息发送和接收数据，这种数据包格式是MKV(Matroska)声明，MKV格式是一个开源的流媒体声明，在Amazon Kinesis Video Streams Developer Guide中所有的库和代码示例都使用MKV格式来发送和接收数据。Kinesis Video Streams Producer Libraries使用StreamDefinition和frame类型来生成MKV stream头信息，frame头信息和frame数据。

##### 11.获取`Amazon Kinesis Video Stream`中的图片

- `Amazon Kinesis Video Stream`的APIs和SDKs从stream中可以提取图片，`Amazon Kinesis Video Stream`提供两种方式一种On-demand方式，API支持用户提取一张或多张图片，一种自动提取方式，可以配置stream自动通过上传video的中的tag来提取图片存放到S3桶里。
- `GetImages`支持用户从`Amazon Kinesis Video Stream`获取图片或者存储图片到`Amazon Kinesis Video Stream`。用户可以使用这些图片进行机器学习的工作，例如识别人、宠物或者交通工具等。图片还可以用于在播放中添加交互元素，例如动作事件的图像预览和视频片段的擦除。
- 客户运行和管理自己的图片转码流水线去为了各种需求例如擦除、图片预览、运行机器学习模型去创建图片，Kinesis Video Streams提供了这个传码和传输的能力，Kinesis Video Streams实时地从视频数据中自动解析图片，然后再将图片传送到S3桶中。
- 使用UpdateImageGenerationConfiguration API来更新自动生成图片配置信息，也可以使用DescribeImageGenerationConfiguration来查看生成图片的配置信息，你可以使用Kinesis Video Streams Producer SDK来附加tag到指定的fragments。通过调用这个API，SDK将会加入一个预先定义的MKV tags组合到fragment，Kinesis Video Streams将会识别这些特定的MKV tags然后基于之前的配置初始化图片生成流水线。所有的这些fragment metadata都将保存在S3的metadata中。

##### 12.Notifications

使用UpdateNotificationConfiguration API为Kinesis Video Stream去配置一个通知服务，还可以使用DescribeNotificationConfiguration来查看附加到Kinesis Video Stream上的通知服务，可以使用Kinesis Video Streams Producer SDK附加tag到指定的fragments，通过暴露这样的API，SDK将添加一个预定义的MKV tags的集合到fragment data。Kinesis Video Streams可以识别这些特定的MKV tags并且初始化通知。任何fragment metadata中提供的notification  MKV的tags都会作为SNS topic payload一部分发送。

##### 13. Kinesis Video Streams Producer Libraries

`Kinesis Video Streams Producer Libraries`是一个Kinesis Video Streams Producer SDK库，客户端可以使用这个类库去构建设备上的应用程序，可以安全的连接Kinesis Video Streams然后实时的摄入流媒体数据支持在控制台上查看。流媒体数据可以通过一下方式摄入：1. 实时摄入，2.缓存几秒后摄入，3.在媒体数据上传后摄入。

- Kinesis Video Streams Producer Client：`Kinesis Video Streams Producer Client`包含一个KinesisVideoClient类，这个类管理流媒体数据源，接收从数据源发来的数据，同时管理整个从数据源到Kinesis的数据流的生命周期。Kinesis Video Stream不支持相机硬件设备中内置的实现，如果需要从这些设备中提取数据，必须实现自定义的媒体数据源实现，然后在KinesisVideoClient中注册你的数据源；
- Kinesis Video Streams Producer Library：`Kinesis Video Streams Producer Library`这个类库被包含在Kinesis Video Streams Producer Client中，客户端也可以直接使用这个类库和Kinesis Video Streams深度集成，它支持硬件设备和适配的操作系统、网络协议栈、有限的内置资源做集成。Kinesis Video Streams Producer Library针对摄入数据到Kinesis Video Streams实现了状态机，也支持回调函数，你需要提供处理所有消息事件的实现。
- 使用Java Producer Library：1. 创建一个KinesisVideoClient实例；2.创建一个MediaSource提供media source信息，比如摄像头的标识，使用的编码格式；3. 注册MediaSource。

##### 14. Kinesis Video Stream parser Library

`Kinesis video stream Parser Library`是一组Java应用程序消费Kinesis video stream中的MKV数据的类库：

- StreamingMkvReader：用于从video stream中读取指定的MKV元素；

- FragmentMetadataVisitor：用于获取fragments的metadata和轨道(单独的数据流包含流媒体信息例如：视频或者音轨)；

- OutputSegmentMerger：用于将连续的fragments合并成一个video stream；

  





