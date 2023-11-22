# Memcache VS Redis



### 1. 缓存读写模式

- Cache Aside(旁路缓存)：可以确保数据以DB结果为准，可以大幅降低DB与Cache不一致的概率。如果没有专门的存储服务同时对数据一致性要求较高或者value需要复杂计算的业务都比较适合旁路缓存模式。

  读请求：先读cache如果cache有则直接返回，如果cache中没有就先读DB然后回写cache再返回；

  写请求：先从cache中删除，然后更新DB再由DB驱动value的计算最后更新Cache;

- Read/Write Through(缓存读写穿透)：业务引用只关注存储服务，存储服务封装了所有存储的细节，对DB的读写操作都使用存储服务即可。

  读请求：先读cache如果cache有则直接返回，如果cache中没有就先读DB然后回写cache再返回；

  写请求：如果cache中有先更新cache，再更新DB，如果cache没有则直接更新DB；

- Write behind cache(缓存异步写入)：与缓存读写穿透类似，存储服务处理所有存储请求，不同的是对于写请求的异步批量更新，这个模式的特点是写数据的性能非常高。

  读请求：先读cache如果cache有则直接返回，如果cache中没有就先读DB然后回写cache再返回；

  写请求：只更新缓存不直接更新DB，而是用异步批量的方式来更新DB；



### 2. 缓存的7大经典问题

- 缓存失效：当大量key同时失效时，同时对这些key的请求量增大时，会出现缓存失效的问题。比如火车票的场景，当开始买票时设置的同一TTL那么这些key将同时失效，就会造成请求响应延迟。解决方法是在设置key的TTL时使用baseline + random的计算公式，这样可以确保大量key不会在同一时间失效，避免缓存失效问题。
- 缓存穿透：当有攻击者大量请求不存在的key就会造成缓存穿透问题，所有对不存在的key的请求都打到DB上造成请求响应延时，同时可能造成DB负载过高导致服务瘫痪。对于不存在的key我们也需要存储一个特殊值，这样可以有效地避免缓存穿透，但这也有可能引起另一个问题，为了存储大量不存在的key导致缓存存储容量减少，这时我们需要考虑分池存储，将不存在的key存放到一个特殊的缓存池里，请求访问先查询特殊缓存池里是否存在，再查询业务缓存，或者我们可以考虑使用bloomfilter算法过滤掉不存在的key。
- 缓存雪崩：如果缓存支持rehash则是大量节点故障引起的DB负载过大，导致整个服务不可用。如果支持rehash则是由于流量洪峰引起的部分节点不可用导致整个cache异常。对于缓存雪崩主要有三个解决方案，第一是在DB端设置慢请求阈值，当慢请求超过阈值时，则关闭DB读请求直接返回failure，在DB恢复正常后打开DB读请求。第二是增加缓存副本，将读请求分发到多个副本处理，降低缓存的读请求负载。第三实时监控缓存状态，当缓存出现故障时，提供及时库容方案。
- 数据一致性：主要跟缓存更新失败，或者多个缓存副本节点更新异常。主要有三个解决方案，第一是cache更新失败后加入重试机制，如果重试也失败，则将key写入消息队列中等缓存恢复后直接删除。第二是调整TTL，尽量缩短TTL来保证数据一致性。第三是不用rehash算法，而是使用缓存分成策略来避免脏数据的产生。
- 数据并发竞争：大量线程同时请求一个不存在或者过期的key，导致同时去查询DB导致DB压力过大。主要解决方案是当大量线程请求miss后加全局锁，保证一个线程查询DB并回写缓存。
- Hot key：Hot key是指头条的某个热门事件，但全国人民都在吃这个瓜时，就有可能数以百万千万的访问请求打到key所在的缓存节点，解决方案是首先将hot key打散成多个key，对原key的访问映射成对多个key的随机访问，同时将多个key分别rehash到不同的缓存节点上，还可以将缓存分层存储，使用多级缓存，将极热key加载到本地存储。同事需要加入缓存状态监控，以便及时扩容。
- Big key：Big key是指value的值过长，属性过多的key。对于这样的，查询加载成本过高，对于不同属性的修改都需要修改这个key对应的缓存，还很容易造成网络和带宽大量占用。解决方案有：第一对于Memcache，可以对slab设置一个阈值，如果value的大小超过阈值则需压缩value的大小再存储，而且还可以在启动Memcache时预先分配大的slab使这些big key预先加载；第二对于Rdis，可以对像set这样有成百上千个属性的big key可以换一种数据类型，在client序列化后一次存入；第三是可以将big key拆分成多个小key，同时在设置TTL时给与更长的过期时间。



### 3. Memcache的原理及特性

Memcache是一个开源的高性能的分布式key/value内存缓存系统，各个MC节点之间互不通信，主要由client负载分布协同，内部是采用多线程处理，主线程主要监听端口及接受请求，工作线程来接受处理请求并返回响应。由于是内存缓存系统，当MC重启后数据将完全丢失。

##### 3.1 Memcache的系统架构

Memcache的系统架构主要包括：网络处理模块，多线程处理模块，HashTable，LRU，slab内存分配模块。Memcache基于Libevent实现了网络处理模块，通过多线程处理用户的请求，基于hash table对于key进行快速定位，使用LRU算法来进行数据淘汰，基于slab机制进行快速分配内存。Memcache引擎启动后，主要使用主线程和工作线程通过多路复用来处理网路请求，处理主线程和工作线程外还有item爬虫线程，LRU维护线程，hash table维护线程等。

##### 3.2 Memcache hash table

Memcache使用hash table快速定位key，在查询key时，首先使用hash算法对key进行hash计算，当在hash table中找到指定的hash位置，我们把每个hash table中的位置称为桶，为了解决hash冲突，使用单向链表的方式来存储数据item，每个item除了存储key/value还需要存储一个指向item的指针，通过轮询的方式来查找对应的key值。当储存在hash table中的item数量大于hash table长度的1.5倍时，就对hash table进行扩容，新的hash table长度是老的hash table的2倍，在扩容期间，维护线程会逐步将老的hash table的桶迁移到新的hash table中，这时对Memcache的操作会同时查询老的hash table和新的hash table，当迁移完成时，新的hash table完全替代老的hash table成为主表。

##### 3.1 Memcache存储管理slab机制

当我们管理内存时，往往根据malloc和free来分配和回收内存，这样的简单管理方式长时间运行后会导致大量的内存碎片，大量的内存碎片会导致内存管理越来越复杂，内存分配越来越慢进而导致系统的储存效率越来越差。Memcache使用slab的机制来管理内存，当Memcache引擎启动时会分配64个slabclass，索引为0的slabclass做slab重新分配使用，不参与其他slabclass的分配活动。每个slabclass会根据需要创建多个大小为1M的slab，每个slab又会分成相同大小的trunk，trunk就是Memcache存储数据的基本存储单位，slabclass索引为1的trunk size最小为102字节，后续的slabclass会按照增长因子对8取整逐步增大trunk size，Memcache默认的增长因子为1.25。最后一个slabclass的trunk size默认值时0.5M。Memcache通过item结构存储key/value，item的头部存储item指针、flag、过期时间等，item一般不会占满整个trunk，但由于Memcache会根据key/value的大小来选择相近的trunk size来存储，所以trunk的浪费会非常有限基本可以忽略不计。每次新分配slab后会将slab空间等分成相同size的trunk，分拆出来的trunk会按item结构进行初始化，然后加入slabclass的freelist中等待后续分配，分配出去的trunk存储item数据等待过期后会再次加入到freelist中，供后续使用。

##### 3.2 Memcache的Item结构

![memcache_item_structure](/Users/luowei/Documents/HBuilderProjects/MyDOCS/image/memcache_item_structure.png)

Memcache中的slabclass首先用item的结构来初始化已分配的slab中的trunk，然后存到freelist链表中，待需要存储数据时，从freelist中取出存入key/value和各种属性，然后再存到LRU链表和HashTable中，如上图所示，首先有两个prev、next指针，在没有存储数据时用于关联freelist链表，在分配存储数据后则用来关联LRU链表。接下来有一个h_next指针，用来关联分配之后的hashtable单向链表。即item的初始化或被回收后被freelist管理，在存储期间被hashtable和LRU管理。

### 4. Redis的原理及特性

Redis是单进程、单线程组件，因为Redis的网络IO和命令处理，都在核心进程中由单线程处理。Redis基于Epoll事件模型开发，可以进行非阻塞网络IO，同时由于单线程命令处理，整个处理过程不存在竞争，不需要加锁，没有上下文切换开销，所有数据操作都是在内存中操作，所以Redis的性能很高，单个实例即可以达到10w级的QPS。核心线程除了负载网络IO及命令处理外，还负责写数据到缓冲，以方便将新写入操作同步到AOF、slave。

除了主进程，Redis还会fork一个子进程，来进行重负荷任务的处理。Redis fork子进程主要有3中场景：

- 收到bgrewriteaof命令时，Redis调用fork，构建一个子进程，子进程往临时AOF文件中，写入重建数据库状态的所有命令，当写入完毕，子进程则通知父进程，父进程把新增的写操作也追加到临时AOF文件，然后将临时文件替换老的AOF文件，并重命名。
- 收到bgsave命令时，Redis构建子进程，子进程将内存中的所有数据通过快照做一次持久化落地，写入到RDB文件中。
- 当需要全量复制时，master也会启动一个子进程，子进程将数据库快照保存到RDB文件中，在写完RDB快照文件后，master就会把RDB发给slave同时将后续新的写命令都同步给slave。

主进程中，除了主线程处理网络IO和命令操作外，还有3个辅助BIO线程。这3个BIO线程分别负责处理，文件关闭、AOF缓冲数据刷新到磁盘，以及清理对象这三个任务队列。

Redis持久化时通过RDB和AOF文件进行的。RDB只记录某个时间点的快照，可以通过设置指定时间内修改keys数的阀值，超过则自动构建RDB内容快照，不过线上运维，一般会选择在业务低峰期定期进行。RDB存储的是构建时刻的数据快照，内存数据一旦落地，不会理会后续的变更。而AOF，记录是构建整个数据库内容的命令，它会随着新的写操作不断进行追加操作。由于不断追加，AOF会记录数据大量的中间状态，AOF文件会变得非常大，此时，可以通过bgrewriteaod命令，对AOF进行重写，只保留数据的最后内容，来大大缩减AOF的内容。

Redis为了提升系统的可扩展性，提升读操作的支撑能力，Redis支持master-slave的复制功能。当Redis的slave部署并设置完毕后，slave会和master建立连接，进行全量同步。第一次建立连接，或者长时间断开连接后，缺失的指令超过master复制缓冲区的大小，都需要先进行一次全量同步。全量同步时，master会启动一个子进程，将数据库快照保存到文件中，然后将这个快照文件发给slave，同时将快照之后的写指令也同步给slave。全量同步完成后，如果slave短时间中断，然后重连复制，缺少的写指令长度小于master的复制缓冲区大小，master就会把slave缺失的内容全部发送给slave，进行增量复制。Redis的master可以挂载多个slave，同时slave还可以继续挂载slave，通过这种方式，可以有效减轻master的压力，同时在master挂掉后，可以在slave通过salveof no one指令，使当前slave停止与master的同步，转而成为新的master。

##### 4.1 Redis的十大核心类型

1. String：使Redis最基本类型，可以理解为memcache中的key对应的value类型，String类型是二进制安全的，即可以包含任何数据。Redis中的普通String采用raw encoding即原始编码方式，该编码会动态扩容，并通过预分配冗余空间来减少内存频繁的开销。Redis中的数字也存为String类型，但是编码方式跟普通String不同，采用整形编码，字符串内容直接为整数值的二进制字节序列。
2. List：Redis的List是一个双向链表，存储了一系列的String类型的字符串。List中的元素按照插入顺序排列。插入元素的方式，可以通过lpush将一个或多个元素插入到列表头部，也可以通过rpush将一个或多个元素插入到列表尾部，还可以通过lset、linsert将元素插入到指定位置或指定元素的前后。List列表的获取，可以通过lpop、rpop从队头或队尾弹出元素，如果队列为空，则返回nil。还可通过Blpop、Brpop从队头或队尾阻塞式弹出元素，如果List列表为空，没有元素可弹出，则持续阻塞，知道有其他client插入新的元素。这里的阻塞可以设置过期时间避免无限等待。最后可以通过LrangeR获取队列内指定范围内的所有元素，还可以通过lrem来删除指定元素。Redis中，list列表的偏移位置都是基于0的下标，即列表第一个元素的下标是0，第二个是1.偏移量也可以是负数，倒数第一个是-1，倒数第二个是-2，以此类推。
3. Set：Set是String类型的无序集合，Set中的元素是唯一的，即Set中不会出现重复元素。Redis中的集合一般是通过dict哈希表实现的，所以插入、删除以及查询元素，可以根据元素hash值直接定位，时间复杂度为O(1)。对Set类型数据的操作，除了常规添加、删除、查找元素外，还可以用以下指令对set进行操作：
   - sismember指定判断该key对应的set数据结构中，是否存在某个元素，如果存在返回1，否则返回0；
   - sdiff指令来对多个set集合执行差集；
   - sinter指令对多个集合执行交集；
   - sunion指令对多个集合执行并集；
   - srandmember指令返回一个或多个随机元素。
4. Sorted Set：Redis中的sorted set有序集合也成为zset，有序集合同set集合类型，也是String类型元素的集合，且所有元素不允许重复。但有序集合中，每个元素都会关联一个double类型的score分数值。有序集合通过这个score值进行由小到大的排序。有序集合中，元素不允许冲虚，但score分数值却允许重复。有序集合除了常规的添加、删除、查找元素外，还可以通过以下指令对Sorted Set进行操作。
   - zscan指令：按序获取有序集合中的元素；
   - zscore指令：获取元素的score值；
   - zrange指令：通过指定score返回指定score范围内的元素；
   - 在某个元素的score值发生变更时，还可以通过zincrby指令对该元素的score值进行加减；
   - 通过zinterstore、zunionstore指令对多个有序集合进行取交集和并集，然后将新的有序集合存到一个新的key中，如果有重复元素，重复元素的score进行相加，然后作为新集合中该元素的score值。
5. Hash：Redis中的Hash实际上是field和value的一个映射表。Hash数据结构的特点是在单个key对应的Hash结构内部，可以记录多个键值对，即field和value对，value可以是任何字符串。而且这些键值对查询和修改很高效。所以可以用hash来存储具有多个元素的复杂对象，然后分别修改或获取这些元素。Hash结构中的一些重要指令，包括：hmset、hmget、hexisis、hgetall、hincrby等。

   - hmset指令批量插入多个field、value映射；
   - hmget指令获取多个field对应的value值；
   - hexists指令判断某个field是否存在；
   - 如果field对应的value是整数，还可以用hincrby来对该value进行修改。
6. Bitmap：Redis中的Bitmap位图是一串连续的二进制数字，底层实际是基于String进行封装存储的，按bit位进行指令操作的。Bitmap中每一个bit位所在的位置就是offset偏移量，可以用setbit、bitfield对bitmap中每个bit进行置0或置1操作，也可以用bitcount来统计Bitmap中的被置1的bit数，还可以用bitop来对多个bitmap进行求与、或、异或等操作。
7. GEO：Redis的GEO地理位置本质上是基于Sorted Set封装实现的。在存储分类key下的地理位置信息时，需要对该分类key构建一个Sorted Set作为内部存储结构，用于存储一系列位置点。在存储某个位置点时，首先利用GeoHash算法，将该位置二维的经纬度，映射编码成一维的52位整数值，将位置名称、经纬度编码score作为键值对，存储到分类key对应的Sorted Set中。需要计算某个位置点A附件的人时，首先以指定位置A位中心点，以距离作为半径，算出GEO哈希8个方位的范围，然后依次轮询方位范围内的所有位置点，只要这些位置点到中心位置A的距离在要求距离范围内，就是目标位置点。

   - 使用geoadd，将位置名称与对应的地理位置信息添加到指定的位置分类key中；
   - 使用geopos方便地查询某个名称所在的位置信息；
   - 使用georadius获取指定位置附近，不超过指定距离的所有元素；
   - 使用geodist来获取指定的两个位置之间的距离。

8. HyperLogLog：是一种概率数据结构，用于估计集合的基数。作为一种概率数据结构，HyperLogLog以很可靠的准确度来换取非常有效的空间利用率。Redis HyperLogLog实现最多使用12KB来提供一个标准误差为0.81%的基数。统计不重复的元素通常需要与你想计数的元素数量成正比的内存空间，因为你需要记住之前出现过的元素而且还要避免重复计数。HyperLogLog的Redis实现是一种内存换精度的算法，返回带有标准误差的估计度量，这种标准误差小于1%。这种算法不再需要使用与计算的项目数量成正比的内存量，而是使用一个固定的内存大小。
9. Streams：是Redis里的消息队列的实现，这种数据结构主要由游标，消费组，消费者，组中pending元素，ack确认回执。
   - XADD：加入一个新的元素；
   - XREAD：从一个给定位置开始读取一个或多个元素；
   - XRANGE：读取一个范围里的元素；
   - XGROUP：管理消费者组，创建、删除等；
   - XREADGROUP：通过一个消费者组读取Streams里的元素；
   - XACK：回执已经读取的元素；
10. Bitfield：Redis图域可以直接通过偏移量来操作二进制数据。

##### 4.2 Redis的持久化

Redis的持久化有两种机制保证，Redis的默认持久化使用RDB(Redis DataBase)：指点某个时间点将内存中的数据集保存到磁盘中，也就是进行数据快照(snapshot)，当需要使用磁盘文件恢复数据时将磁盘文件中的数据全部写回Redis即可。

1. RBD文件是一个时间点的快照文件，该文件十分紧凑，非常适合用来传输到异地数据服务器上做灾难备份文件；
2. RBD可以最大限度的提高Redis的性能，Redis的服务主进程只需fock一个子进程来做持久化IO操作，对Redis服务进程的影响是执行fock操作，可能有毫秒到1秒的影响；
3. 与AOF相比RDB可以使用大数据集重启Redis;
4. RBD既然是时间点的数据集快照，那么就存在数据丢失的风险。

AOF(Append Only File)：将Redis执行过的所有写指令记录下来(读操作不记录)，只许追加文件但是不可以改写文件，redis启动之初会读取该文件重新构建数据，换言之，redis重启的话就根据日志文件的内容将写指令从前到后执行一次以完成数据的恢复工作，AOF默认是不开启的。Client作为命令的来源，会有多个源头以及源源不断的请求命令，在这些命令到达Redis Server以后并不是直接写入AOF文件，会将这些命令先放入AOF缓存中进行保存。这里的AOF缓冲区实际上是内存中的一片区域，存在的目的是当这些命令达到一定量以后再写入磁盘，避免频繁的磁盘IO操作。AOF缓冲会根据AOF缓冲区**同步文件的三种写回策略**将命令写入磁盘上的AOF文件。随着写入AOF内容的增加为避免文件膨胀，会根据规则进行命令的合并(**又称AOF重写**)，从而起到AOF文件压缩的目的。当Redis Server服务器重启的时候会队AOF文件载入数据。

![AOF_persistence_process](/Users/luowei/Documents/HBuilderProjects/MyDOCS/image/AOF_persistence_process.jpg)

AOF的三种写回策略：

- **aLways**：同步写回，每个写命令执行完立刻同步地将日志写会磁盘；
- **everysec**：每秒写回，每个写命令执行完，只是先把日志写到AOF文件的内存缓冲区，每隔1秒把缓冲区中的内容写入到磁盘；
- **no**：操作系统控制的写回，每个写命令执行完，只是先把日志写到AOF文件的内存缓冲区，由操作系统决定何时将缓冲区内容写回磁盘；

AOF从7.0开始有了很大的变化首先是不再与RDB共用同一个目录，其次由一个文件变成了三个文件。**MP-AOF实现** **方案概述** 顾名思义，MP-AOF就是将原来的单个AOF文件拆分成多个AOF文件。在MP-AOF中，我们将AOF分为三种类型, 分别为:

- **BASE: 表示基础AOF**，它一般由子进程通过重写产生，该文件最多只有一个。
- **INCR:表示增量AOF**，它一般会在AOFRW开始执行时被创建，该文件可能存在多个。
- **HISTORY**:表示历史AOF，它由BASE和INCR AOF变化而来，每次AOFRW成功完成时，本次AOFRW之前对应的BASE和INCR AOF都将变为HISTORY，HISTORY类型的AOF会被Redis自动删除。

为了管理这些AOF文件，Redis引入了一个manifest (清单)文件来跟踪、管理这些AOF。同时，为了便于AOF备份和拷贝，Redis将所有的AOF文件和manifest文件放入一个单独的文件目录中，目录名由appenddirname配置(Redis 7.0新增配置项)决定。

##### 4.3 Redis事务

Redis事务是一组命令的集合，可以一次执行多个命令，保证了所有命令的按顺序、串行化执行，进一步保证了这组命令的原子性。在Redis中，事务的执行是将一组命令放在队列里面，这样就可以一次性、顺序性、排他性地执行一系列命令。Redis事务的特性：

1. Redis里的事务保证事务里的操作会被连续独占地执行，Redis命令的执行是单线程架构，在执行事务内的所有指令前不不可能再去执行其他客户端的请求；
2. Redis没有像关系型数据库的隔离级别，因为在数据提交任何命令前都不会被实际执行，也就不存在事务内的查询能看到更新，而事务外的执行看不到这种问题；
3. Redis的事务不保证原子性，也就是不保证所有指令同时成功或者同时失败，只有决定是否开始执行所有指令的能力，没有执行到一半进行回滚的能力；
4. Redis会保证事务里的命令的串行执行，不会被其他的客户端命令插入；

Redis事务的命令有MULTI，EXEC，DISCARDS，WATCH，UNWATCH这5个主要命令组成：

- **MULTI**：开启一个事务；
- **EXEC**：执行事务；
- **DISCARDS**：取消事务；
- **WATCH**：监控一个键，当事务执行前有其他命令修改了这个键就**DISCASRDS**这个事务；
- **UNWATCH**：取消监控；

##### 4,4 Redis管道

Redis是一种基于客户端和服务器，请求、响应协议的TCP服务，一个请求会遵从以下步骤：

1. 客户端向服务器发送命令分四步(发送命令 --> 命令排队 --> 命令执行 --> 返回结果)，并监听Socket返回，通常以阻塞模式等待服务器响应；
2. 服务器处理命令，并返回结果给客户端；

基于以上的协议特点，每个命令处理都需要RTT(Round TIme Trip)，这样如果需要发送大量命令给服务器处理，每个命令都需要等待一个RTT的时间，这样不但增加了客户端的等待时间，同时加大了服务器处理的负担，大量的磁盘IO和进程上下文(用户态到内核态)转换消耗了大量的资源浪费。为了解决这个问题可以使用Redis pipeline来实现批量打包多条命令，使用先进先出队列来将多个命令一次性发送到服务器端，服务器在一次提交中按序执行所有命令，大大减少了多次命令提交所需的RTT时间。

##### 4.5 Redis复制

Redis的主从复制是指slave从master上自动的同步数据，当master有数据更新时，slave将从master同步更新，master主要以写为主，slave则以读为主。主要用于Redis缓存数据库的读写分离，灾难恢复，数据备份和水平扩容。如何配置Redis的主从复制：

1. master上是需要做密码验证的，需要配置requirepass参数，这样master就需要密码登入；
2. slave上需要配置masterauth来校验master的密码，否则master会拒绝slave的同步请求；

主从复制的处理流程：slave的启动连接master成功后会发送一条sync命令，当slave首次连接master，一次完全的同步将被自动执行，slave的自身数据将在同步过程中被master完全覆盖。master在收到sync请求后会启动RDB的保存，同时搜集所有接收到修改数据集的命令并缓存起来，master在RDB快照执行完成之后，将RDB和缓存命令发送给slave完成一次同步，slave收到文件后加载到内存完成数据库初始化。在主从复制之间，master默认每隔10s发送ping命令到slave保持心跳，之后master继续缓存增量的修改数据库的命令发送给slave保持主从数据同步，master通过检查backlog里面的offset来标识上传同步的游标，slave也会保存一个masterID和offset，master只会发送offset之后的数据给slave。Redis复制的痛点在于master如果宕机，slave是无法自动充电master，这样导致整个Reids无法写入。

##### 4.6 Redis哨兵

Redis哨兵将监控Redis的master是否故障，如果master发生故障将根据投票数来从所有slave中选取一个来作为新的master对外服务。哨兵需要运行在独立的服务器上，哨兵只是监控Redis的master服务是否正常，没有任何读写功能，相对于master和slave配置需求较低主要依赖网络，在master下线时，哨兵需要通过投票选出新的master。

Redis哨兵的运行流程和选举原理，SDOWN是单个sentinel自己主观上检测到关于master的状态，从sentinel角度来看，如果发送了PING心跳后，在一定的时间范围内没有收到合法的响应就达到了SDOWN的条件。在sentinel的配置文件中配置了down-after-miliseconds参数设置了主观下线的时间长度，ODOWN是指多个sentinel达成一致意见，都认为master下线，这样达到了客观下线的条件。quorum这个参数是进行客观下线的一个依据，法定人数/法定票数，意思是至少有quorum个sentinel认为这个master有故障才会对这个master进行下线以及故障转移。因为有的时候，某个sentinel节点可能因为自身网络原因导致无法连接master，而此时master并没有出现故障，所以这就需要多个sentinel都一直认为该master有问题才可以进行下一步投票操作。当主节点被判断客观下线以后，各个哨兵节点会进行协商，先选举出一个领导者哨兵节点并由该领导者节点也即被选举出的leader进行failover。

当master下线从所有的slave中选举新的master流程：先比较slave的priority，然后再比较复制偏移量位置offset，最后比较slave的Run ID。当slave被sentinel集群的leader选举成为master后对其执行slaveof on one将其变成master，同时向其他的slave发送命令使其他的slave变成新的master的slave，当原来的老master上线后，leader会向其发送命令使其变成新master的slave。

##### 4.7 Redis集群

由于数据量过大，单个master复制集难以承担，因此需要对多个复制集进行集群，形成水平扩展每个复制集只负责存储整个数据集的一部分，这就是Redis的集群，其作用是提供在多个Redis节点间共享数据的程序集。Redis集群支持多个master，每个master有可以挂载多个slave。由于cluster自带sentinel的故障转移机制，内置了高可用的支持，无需再去使用哨兵功能，客户端与Redis的节点连接，不再需要连接集群中所有的节点，只需要任意连接集群中的一个可用节点即可。

- Redis集群的槽位(slot)，Redis集群没有使用一致性hash，而是引入了哈希槽的概念，Redis集群有16384个哈希槽，每个key通过CRC16校验后对16384去模来决定放置哪个槽，集群的每个节点负责一部分hash槽。HASH_SLOT = CRC16(key) mod 16384
- Redis集群的分片，使用Redis集群时我们会将存储的数据分散到多台redis机器上，这就称为分片。简言之，集群中的每个Redis实例都被认为是整个数据的一个分片。为了找到给定key分片，我们对key进行CRC16(key)算法处理并通过对总分片数量取模。然后，使用确定性哈希函数，这意味着给定的key将多次始终映射到同一个分片，我们可以推断将来读取特定key的位置。





 

