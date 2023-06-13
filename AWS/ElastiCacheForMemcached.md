### ElastiCache For Memcached 学习手册

对于一个网站来说数据传输的速度是至关重要的，网页的加载速度直接和浏览量负相关，每当加载速度增加时浏览量将下降，为了提高数据传输的速度，有必要将经常查询的数据缓存起来，提高数据查询速度，就算是优化过的数据库的查询或者远程调用仍然比从内存缓存中取指定键的值要慢的多。使用内存键值数据存储的主要目的就是提供超快和低成本的数据访问。那么我们到底要存储什么呢？

- 查询数据库和远程调用 API 的成本高加之速度慢，特别是对于多表的联合查询，或者是多次远程 API 的调用，对于这样的查询结果就可以考虑存储在缓存中；
- 数据的访问模式也决定是否适合做缓存，当数据修改的不频繁或者数据访问次数很少都不适合做数据缓存；
- 允许在有些场景下，缓存的数据与真实数据不一致，而且这种不一致不会带来很大的问题。

##### ElastiCache 相关概念

- ElastiCache nodes: 一个节点是一个固定 chunk 大小的、安全的、网络内存存储。每个节点运行一个 Memcached 实例。运行在同一个 cluster 的每个节点都是相同的实例类型并且是同一种 cache 引擎，每个 cache 节点拥有自己的 DNS 和端口号。但需要长期运行 cache 时可以预制一些节点，同时当业务请求临时变大时，可以使用使用一些按需付费的节点。Memcached 引擎支持自动发现功能，允许客户端去自动的发现集群中的节点信息，初始化和维护与 Memcached 的连接。
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
