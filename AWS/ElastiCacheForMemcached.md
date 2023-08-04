### ElastiCache For Memcached 学习手册

对于一个网站来说数据传输的速度是至关重要的，网页的加载速度直接和浏览量负相关，每当加载速度增加时浏览量将下降，为了提高数据传输的速度，有必要将经常查询的数据缓存起来，提高数据查询速度，就算是优化过的数据库的查询或者远程调用仍然比从内存缓存中取指定键的值要慢的多。使用内存键值数据存储的主要目的就是提供超快和低成本的数据访问。那么我们到底要存储什么呢？

- 查询数据库和远程调用 API 的成本高加之速度慢，特别是对于多表的联合查询，或者是多次远程 API 的调用，对于这样的查询结果就可以考虑存储在缓存中；
- 数据的访问模式也决定是否适合做缓存，当数据修改的不频繁或者数据访问次数很少都不适合做数据缓存；
- 允许在有些场景下，缓存的数据与真实数据不一致，而且这种不一致不会带来很大的问题。

##### ElastiCache 相关概念

- ElastiCache nodes: 一个节点是一个固定 chunk 大小的、安全的、网络内存存储块。每个节点运行一个 Memcached 实例。运行在同一个 cluster 的每个节点都是相同的实例类型并且是同一种 cache 引擎，每个 cache 节点拥有自己的 DNS 和端口号。但需要长期运行 cache 时可以预制一些节点，同时当业务请求临时变大时，可以使用使用一些按需付费的节点。Memcached 引擎支持自动发现功能，允许客户端去自动的发现集群中的节点信息，初始化和维护与 Memcached 的连接。
- ElastiCache cluster: 一个 Memcached cluster 是一个或者多个 ElastiCache node 的逻辑组，数据分区存储在各个节点上。在一个`AWS Region`中一个 AWS 账户可以支持最多 300 nodes，每个 cluster 中可以支持最多 40 个 nodes。为了提供可用性，你可以创建 nodes 分散在多个`Availability Zone`中。当你想在一个 cluster 中增加或减少 nodes 后，cluster service 会重新将数据分区存储在 scale 后的 nodes 中。
- ElastiCache endpoints: 一个 endpoint 是一个唯一的用来连接 ElastiCache node 或 cluster 的地址，cluster 中的每个节点都有自己的 endpoint，cluster 也有一个 endpoint 叫做 configuration endpoint。自动发现机制可以连接到 configuration endpoint 上，你的 application 就能知道所有节点的 endpoint，即使 cluster 中添加或删除节点以后也可以自动发现新的节点。
- ElastiCache parameter groups: Cache parameter groups 是一个可以用来方便管理运行时配置的方法，它将一组指定内存、删除策略、item 大小等配置信息应用于一个 cluster，这样你的配置信息将准确的应用到所有的节点上。
- ElastiCache security groups: 一般来讲，所有新的 ElastiCache cluster 运行在一个 VPC 里面，这样你可以通过将实例运行在子网组来获得访问ElastiCache的权限，如果你选择在 VPC 外运行你的集群，那么你需要创建一个安装组来授权你的实例去访问ElastiCache cluster。`ElastiCache`允许你使用security groups来控制访问权限，一个security group就像一个防火墙，可以控制访问你的cluster，一般对你的cluster的访问是关闭的，如果你允许你的应用程序访问你的cluster，你必须在security group中明确你的ECS实例。一旦入站策略被配置，所有关联这个security group的clusters都将使用该入站策略。
- ElastiCache subnet groups: 如果你在VPC中创建一个cluster，那你必须指定一个`cache subnet group`。ElastiCache使用这个 Cache subnet group去选择一个子网或者子网中的ip地址和你的Cache node关联。
- ElastiCache Memcached event: 当一些重要事件发生时，ElastiCache 会发送一个通知到指定的SNS topic。通过监听SNS的通知，可以对这些事件做出相应的处理。

##### Memcached 和 Redis的对比

||Memcached|Redis|
|:--------:|:--------:|:--------:|
|Data types|simple|complex|
|Data partitioning|yes|yes|
|Online resharding|no|yes|
|Encryption|yes|yes|
|Data tiering|No|yes|
|Multi-threaded|yes|no|
|High availability|no|yes|
|Automatic failover|no|yes|
|Pub/Sub capabilities|no|yes|
|Sorted sets|no|yes|
|Backup and restore|no|yes|
|Geospatial indexing|no|yes|

##### 选择区域和可用区

将你的Memcached节点分布在一个区域中的多个可用区中，可以保护你的应用免于灾难性错误的影响，比如一个可用区的断电。当你创建memcached cluster时可以为所有的节点指定一个可用区或者为每个节点指定不同的可用区，一旦Cache节点创建，它的可用区将无法改变。

##### 管理节点

一个节点是Amazon ElastiCache最小的基本要素，它是一个大小固定的安全的，连接网络的RAM块。当一个cluster被创建或修改每个节点的引擎将被固定下来。每个节点有自己的DNS名字和端口。Amazon ElastiCache支持多种节点类型，每种类型的内存大小，处理器性能都不一样。连接单个节点需要知道节点的endpoint和端口。

- Amazon ElastiCache for Memcached将通过打补丁和升级的方式频繁地更新它的集群，无缝地应用到集群中的实例上，然而我们需要时不时地强制底层操作系统的更新，这些替换需要增强地安全性、可靠性和使用性能。你可以手动的添加和删除节点，每次手动替换操作后，你的键值将重新分区存储，这个过程将引起Cache misses。
- 预制一个或多个节点是一个节省成本的方式，这种预制的费用根据节点类型和预制的时间长短相关。

##### 选择网络类型

Elasticache支持IPv4和IPv6，你可以选择只支持IPv4或者只支持IPv6,或者支持IPv4和IPv6双栈协议。如果你创建在Amazon VPC里面，你必须指定一个子网group，Elasticache使用这个子网group为cluster里面的node选择一个子网和IP地址。当你创建cluster选择双栈协议作为网络类型，你需要指定一个IP寻址类型-IPv4或IPv6，Elasticache默认使用IPv6的寻址，你也可以自己指定。如果你使用自动寻址只有你指定的类型会返回给Memcached客户端。

##### 前期准备

- 内存和处理器：node是elasticache的基本单位，需要考虑cache数据量的大小来决定使用哪种类型的节点，同时Memcached的引擎是多线程的，所以节点的核心数决定了处理的能力；
- Memcached集群的配置：Elasticache包含1到40个节点，数据将分区存放在各个节点上，应用程序连接Memcached集群使用一个网络地址endpoint。每个节点都有自己的endpoint，应用程序可以使用这个endpoint读写指定节点的数据。整个集群也有个endpoint，应用程序可以使用集群的endpoint去读写数据，将寻址节点交给自动寻址来完成；
- 弹性扩容：Elasticache允许cluster自动弹性扩容，仅仅只需要添加或删除节点，如果你开启了自动寻址，使用cluster endpoint来读写数据，节点变动不会影响应用程序对Elasticache的访问；
- 访问许可：如果应用程序部署在同一个VPC中，需要对集群添加入站规则，如果不在一个VPC需要授权应用的安全组访问Elasticache安全组；
- 可用区：如果cluster有多个节点，将其部署在不同的可用区中可以减少cluster故障的影响；
- 节点数量：节点的数量是一个关键参数，当一个节点故障时会影响后台数据库的负载，Elasticache将对一个故障节点预制一个替换并重新填充再对外服务，要减少这种故障发生，应该在总容量不变的情况下，尽量选择多个小容量的节点而不是一两个大容量的节点；

##### 自动寻址

Elasticache支持自动寻址，客户端程序可以自动找到cluster中所有的nodes，同时初始化和维护所有和nodes之间的连接。使用自动寻址，你的应用程序不需要指定连接单一的节点，而是去连接一个Memcached节点获取所有节点的列表，通过这个列表你的应用程序知道了cluster中所有的节点，这样就可以连接cluster中所有的节点。Elasticache维护着一个关于所有节点的元数据，当添加和删除节点时将会更新这个元数据，如果需要更新元数据时将会同时所有节点的元数据，这样就保证了在cluster中多有节点的元数据的一致性。自动寻址有如下好处：

- 当新增节点时，这个新的节点将会注册到cluster endpoint和其他所有的节点中，当你删除节点时，也会被注销，因此cluster中的所有节点都保存一个最新的元数据；
- 节点故障会自动被发现，同时会被自动替换；
- 应用程序只需要连接配置endpoint，自动寻址会连接cluster中所有其他的节点；
- 应用程序每分钟轮询整个cluster，如果cluster configuration有任何改动，应用程序将收到一个更新过后的metadata，这样客户端就可以接连新增的节点或者断开删除的节点。

使用配置endpoint创建client时，首先将解析endpoint的DNS，因为配置endpoint维护着所有Cache nodes的CNAME记录，所以DNS可以解析其中一个node，然后连接这个node并向这个node请求所有节点的配置信息，因为cluster中所有节点都维护着配置信息，任何一个节点都可以返回配置信息给客户端，当客户端收到所有节点的主机名和IP地址，然后连接所有的nodes。

应用程序连接所有的Cache nodes后，Elasticache cluster client决定哪个节点存储一个数据记录和从哪个节点获取一个数据记录。当应用程序发出get请求后，将适用hash算法决定指定key存储到哪个node上，然后连接到正确的节点上，Cache node返回指定的键值的value。

##### 集群管理

当集群需要升级时，请注意Memcached是不支持持久化的，所以每次将节点类型升级到新的类型都是一个重构的过程，将会丢失所有的数据。当升级到1.4.33及以后的版本时，执行CreateCacheCluster和ModifyCacheCluster如遇下列条件时将失败：

1. slab_chunk_max > max_item_size;
2. max_item_size modilo slab_chunk_max != 0;
3. max_item_size > ( ( max_cache_memory - memcached_connections_overhead ) / 4 )

当任何系统变化时，每个cluster必须有一个每周的维护窗口。如果你不指定的话，Elasticache会随机指定一个60分钟的维护时间窗口。一般这个维护时间窗口应该选择系统请求少的时候进行，这个窗口将进行系统升级，scale in/out的动作影响Elasticache的性能。

##### 缓存策略

1. 延迟加载: 只有当需要的时候才去Cache里load数据，缓存存在数据库和应用程序之间，一般当你的应用程序需要请求数据时首先从缓存中加载，如果数据存在缓存中且有效将会返回给应用程序，如果数据不存或者数据过期则从数据库请求数据返回给应用程序，然后写入缓存，这样下次请求就可以直接从缓存中返回。
   - 延迟加载的好处很明显只有有访问过的数据才会被写入Cache，Cache不会被大部分没有访问请求的数据填充，当节点故障对于应用程序来说不是致命的故障；
   - 延迟加载的劣势是当key没有命中时，会有额外的两次请求，开始第一次访问Cache放回null和最后一次写入缓存请求，这将明显延迟数据访问请求。同时当只有数据不存在缓存中时才写入缓存会出现缓存数据过时的问题。引文当更新数据库时没有同步更新Cache。
2. 双写策略：只要写入数据库(插入、更新)都需要写入缓存。
   - 双写的好处是不会有数据过时的问题；
   - 双写的缺点也很明显，所有的数据都跟数据库同步，所有在写入时增加了延迟，特别是针对新的节点写入都会增加延迟，其实数据全部同步对存储资源的浪费，其实有很多数据是不常被访问的，需要添加TTL来避免资源浪费
3. 增加TTL：懒加载允许数据过时但是不会因为节点故障对应用程序照成致命影响，而双写数据不会过时但是当节点故障时会影响写入缓存报错对应用程序造成很大影响，所以添加TTL(Time to live)将会优化两个缓存策略，TTL是一个整型类型指定了key在多少时间后过期，当应用程序尝试读取过期的key时，将把这个key当不存在一样，通过查询数据库来同步缓存数据。

##### 配置ElastiCache客户端更有效的读取

需要使用多个ElastiCache的node更有效的读取，需要将cache的键值平均的分布到各个节点中，一个简单的方式hash函数是`n - hash(key) mod n` 当节点数不变时这样的hash行之有效，但是一旦节点数发现化就需要重新迁移数据，需要迁移的键值是`(n - 1)/n` 比如从一个节点到两个节点那就是2-1/2=50%。解决这个问题就需要Memcached客户端使用一致hash算法，使用这种Hash算法后需要移动的key是1/n。

##### Scaling out Scaling in

横向扩展Memcached cluster指的是增加和删除memcached node，这样当你配置了maintanace window所有key的重定向工作将在maintanace window中完成，同时如果你使用了自动寻址将不需要修改你memcached client中的node endpoint，client会自动获取新的元数据来自动找到新的节点。

纵向扩展Memcached cluster是指改变节点的类型，这种变化也是在maintanace window中进行但是使用纵向扩展由于memcached没有持久化，所以Cache的数据将全部清空。

##### 性能优化Parameter group

Amazon Elasticache使用parameters去控制cluster和node的运行参数，一个parameter group代表了一组命名的参数，当memcached启动时将使用这组参数来初始化memcached引擎，所有附加了Parameter group的节点都将使用这组参数初始化和启动。如果你需要优化Memcached的性能，需要修改一些参数的值，需要创建自己的Parameter group。首先你不能修改AWS默认的Parameter group，这些Parameter group是根据引擎版本制定的默认启动参数，你可以从这些parameter group family继承你自己的parameter group。无论你更改的是替换Parameter group还是修改了参数组里的值这些改动都立即应用到cluster。

