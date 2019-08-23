### Redis学习手册

Redis简介：Redis是一个速度非常快的非关系数据库(non-relational database)，它可以储存键(key)与5种不同类型的值(value)之间的映射(mapping)，可以将存储在内存
的键值对数据持久化到硬盘，可以使用复制特性来扩展读性能，还可以使用客户端分片来扩展写性能。既然是内存数据库，那么人们会问当服务器被关闭时，数据将如何保持呢？
Redis拥有两种不同形式的持久化方法，它们都可以用小而紧凑的格式将存储在内存中的数据写入硬盘：第一种持久化方法为时间点转储(point-in-time)，转存操作即可以在"指
定时间内有指定数量的写操作执行"这一条件被满足时执行，又可以通过调用两条转储到硬盘(dump-to-disk)命令中的任意一条来执行；第二种持久化方法将所有修改了数据库的
命令都写入一个只追加(append-only)文件里，用户可以根据数据的重要程度，将只追加写入设置为从不同步(sync)、每秒同步一次或者每次写入一个命令就同步一次。另外，尽
管Redis的性能很好，Redis也实现了主从复制特性：执行复制的从服务器会连接上主服务器，接收主服务器发送的整个数据库的初始副本(copy)；之后主服务器执行的写命令，都
会被发送给所有连接着的从服务器取执行，从而实时的更新从服务器的数据集。

###### Redis使用场景
每当我们登入互联网服务时，这些服务都会使用cookie来记录我们身份信息。cookie由少量数据组成，网站会要求我们的浏览器存储这些数据，并在每次服务发送请求时将这些数
据传回给服务器。对于用来登入的cookie，有两种常见的方法可以将登入信息存储在cookie里面：一种签名cookie，另一种是令牌token cookie。
* 签名cookie通常会存储用户名，可能还有用户ID、用户最后一次成功登入的时间，以及网站觉得有用的其他任何信息。除了用户相关信息外，签名cookie还包含一个签名，服务
器可以用户这个签名来验证浏览器发送的信息是否未经改动。
* 令牌cookie会在cookie里面存储一串随机字节作为令牌，服务器可以根据令牌在数据库中查找令牌的拥有者。随着时间的推移，旧令牌会被新令牌取代。
* 缓存一些经常浏览的静态页面
* 对于一些生产系统中的临时的并且大量访问的数据直接使用Redis存储(比如：电商网站的活动折扣页面上的商品信息购物信息)
* 生产系统中大量访问的临时数据，例如电商网站用户的浏览商品信息，这部分信息对于数据分析很有帮助。


###### Redis安装
1. 下载Redis源码包 redis-5.0.5.tar.gzi
2. 解压源码包 `tar -zxvf redis-5.0.5.tar.gz`
3. 进入解压开的redis源码包主目录 `cd redis-5.0.5`
4. 编译redis源码 `make MALLOC=libc`
5. 编译安装redis `cd redis-5.0.5/ make MALLOC=libc install`

###### Redis数据类型和70个常用命令
1. 字符串

|命令|用例和描述|
|:--------:|:----------------:|
|INCR|INCR key-name:将键存储值加上1|
|DECR|DECR key-name:将键存储值减去1|
|INCRBY|INCRBY key-name amount:将键存储值加上整数amount|
|DECRBY|DECRBY key-name amount:将键存储值减去整数amount|
|INCRBYFLOAT|INCRBYFLOAT key-name amount:将键存储值加上浮点数amount|
|APPEND|APPEND key-name value:将值value追加到给定键key-name当前存储的值的末尾|
|GETRANGE|GETRANGE key-name start end:获取一个由偏移量start至偏移量end范围内所有字符组成的子串，包括start和end在内|
|SETRANGE|SETRANGE key-name offset end:将从start偏移量开始的子串设置为给定值|
|GITBIT|GITBIT key-name offset:将字符串看作是二进制位串，并将位串中的偏移量为offset的|
|SETBIT|SETBIT key-name offset value:将字符串看作是二进制位串，并将位串中偏移量为offset的二进制位的值设置为value|
|BITCOUNT|BITCOUNT key-name [start end]:统计二进制位串里面值为1的二进制位的数量，如果给定了可选的start偏移量和end偏移量，那么只对偏移量指定范围内的二进制位进行统计|
|BITOP|BITOP operation dest-key key-name [key-name ...]:对一个或多个二进制位串执行包括并(AND)、或(OR)、非(NOT)在内的任意一种按位运算操作(bitwise operation)，并将计算得出的结果保存在dest-key键里面|

2. 列表

|命令|用例和描述|
|:--------:|:----------------:|
|RPUSH|RPUSH key-name value [value ...]:将一个或多个值推入列表的右端|
|LPUSH|LPUSH key-name value [value ...]:将一个或多个值推入列表的左端|
|RPOP|RPOP key-name:移除并返回列表最右端的元素|
|LPOP|LPOP key-name:移除并返回列表最左端的元素|
|LINDEX|LINDEX key-name offset:返回列表中偏移量为offset的元素|
|LRANGE|LRANGE key-name start end:返回列表从start偏移量到end偏移量范围内的所有元素，其中偏移量为start和偏移量为end的元素也会包含在被返回的元素之内|
|LTRIM|LTRIM key-name start end:对列表进行修剪，只保留从start偏移量到end偏移量范围内的元素，其中偏移量为start和偏移量为end的元素也会被保留|
|BLPOP|BLPOP key-name [key-name ...] timeout:从第一个非空列表中弹出位于最左端的元素，或者在timeout秒之内阻塞并等待可弹出的元素出现|
|BRPOP|BRPOP key-name [key-name ...] timeout:从第一个非空列表中弹出位于最右端的元素，或者在timeout秒之内阻塞并等待可弹出的元素出现|
|BPOPLPUSH|BPOPLPUSH source-key dest-key:从source-key列表中弹出位于最右端的元素，然后将这个元素推入dest-key列表的最左端，并向用户反回这个元素|
|BRPOPLPUSH|BPOPLPUSH source-key dest-key timeout:从source-key列表中弹出位于最右端的元素，然后将这个元素推入dest-key列表的最左端，并向用户反回这个元素；如果source-key为空，那么在timeout秒之内阻塞并等待可弹出的元素出现|

3. 集合

|命令|用例和描述|
|:--------:|:----------------:|
|SADD|SADD key-name item [item ...]:将一个或多个元素添加到集合里面，并返回被添加元素当中原本并不存在与集合里面的元素数量|
|SREM|SREM key-name item [item ...]:从集合里面移除一个或多个元素，并返回被移除元素的数量|
|SISMEMBER|SISMEMBER key-name item:检查元素item是否存在于集合key-name里|
|SCARD|SCARD key-name:返回集合包含的元素的数量|
|SMEMBERS|SMEMBERS key-name:返回集合包含的所有元素|
|SRANDMEMBER|SRANDMEMBER key-name [count]:从集合里面随机的返回一个或多个元素。当count为正数时，命令返回的随机元素不会重复；当count为负数时，命令返回的随机元素可能会出现重复|
|SPOP|SPOP key-name:随机地移除集合中的一个元素，并返回被移除的元素|
|SMOVE|SMOVE source-key dest-key item:如果集合source-key包含元素item，那么从集合source-key里面移除元素item，并将元素item添加到集合dest-key中；如果item被成功移除，那么命令返回1，否则返回0|
|SDIFF|SDIFF key-name [key-name ...]:返回那些存在第一个集合、但不存在与其他集合中的元素(数学上的差集运算)|
|SDIFFSTORE|SDIFFSTORE dest-name key-name [key-name ...]:将那些存在第一个集合但并不存在于其他集合中的元素(数学上的差集运算)存储到dest-key键里面|
|SINTER|SINTER key-name [key-name ...]:返回那些同时存在于所有集合中的元素(数学上的交集运算)|
|SINTERSTORE|SINTERSTORE dest-key key-name [key-name ...]:将那些同时存在于所有集合的元素(数学上的交集元素)存储到dest-key键里面|
|SUNION|SUNION key-name [key-name ...]:返回那些至少存在一个集合中的元素(数学上的并集运算)|
|SUNIONSTORE|SUNIONSTORE dest-name key-name [key-name ...]:将那些至少存在于一个集合中的元素(数学上的并集运算)存储到dest-key键里面|

4. 散列

|命令|用例和描述|
|:--------:|:----------------:|
|HMGET|HMGET key-name key [key ...]:将那些存在于第一个集合但并不存在与其他集合中的元素(数学上的差集运算)存储到dest-key键里面|
|HMSET|HMSET key-name key value [key value ...]:为散列里面的一个或多个键设置值|
|HDEL|HDEL key-name key [key ...]:删除散列里面的一个或多个键值对，返回成功找到并删除的键值对数量|
|HLEN|HLEN key-name:返回散列包含的键值对数量|
|HEXISTS|HEXISTS key-name key:检查给定键是否存在于散列中|
|HKEYS|HKEYS key-name:获取散列包含的所有键|
|HVALS|HVALS key-name:获得散列包含的所有值|
|HGETALL|HGETALL key-name:获得散列包含的所有键值对|
|HINCRBY|HINCRBY key-name key increment:将键key存储的值加上整数increment|
|HINCRBYFLOAT|HINCRBYFLOAT key-name key increment:将键key存储的值加上浮点数increment|

5. 有序集合

|命令|用例和描述|
|:--------:|:----------------:|
|ZADD|ZADD key-name score member [score member ...]:将带有给定分数的成员添加到有序集合里面|
|ZREM|ZREM key-name member [member ...]:从有序集合里面移除给定的成员，并返回给移除成员的数量|
|ZCARD|ZCARD key-name:返回有序集合包含的成员数量|
|ZINCRBY|ZINCRBY key-name increment member:将member成员的分值加上increment|
|ZCOUNT|ZCOUNT key-name min max:返回分值介于min和max之间的成员数量|
|ZRANK|ZRANK key-name member:返回成员member在有序集合中的排名|
|ZSCORE|ZSCORE key-name member:返回成员member的分值|
|ZRANGE|ZRANGE key-name start stop [WITHSCORES]:返回有序集合中排名介于start和stop之间的成员，如果给定了可选的withscores选项，那么命令将成员的分值也一并返回|
|ZREVRANK|ZREVRANK key-name member:返回有序集合里成员menber的排名，成员按照分值从大到小排列|
|ZREVRANGE|ZREVRANGE key-name start stop [WITHSCORES]:返回有序集合给定排名范围内的成员，成员按照分值从大到小排列|
|ZRANGEBYSCORE|ZRANGEBYSCORE key-name min max [WITHSCORES] [LIMIT offset count]:返回有序集合中，分值介于min和max之间的所有成员|
|ZREVRANGEBYSCORE|ZREVRANGEBYSCORE key-name max min [WITHSCORES] [LIMIT offset count]:返回有序集合中，分值介于min和max之间的所有成员，并按照分值从大到小的顺序来返回它们|
|ZREMRANGEBYRANK|ZREMRANGEBYRANK key-name start stop:移除有序集合中排名介于start和stop之间的所有成员|
|ZREMRANGEBYSCORE|ZREMRANGEBYSCORE key-name min max:移除有序集合中分值介于start和stop之间的所有成员|
|ZINTERSTORE|ZINTERSTORE dest-key key-count key [key ...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX]:对给定的有序集合执行类似于集合的交集云算|
|ZUNIONSTORE|ZUNIONSTORE dest-key key-count key [key ...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX]:对给定的有序集合执行类似于集合的并集云算|

6. 发布与订阅

|命令|用例和描述|
|:--------:|:----------------:|
|SUBSCRIBE|SUBSCRIBE channel [channel ...]:订阅给定的一个和多个频道|
|UNSUBSCRIBE|UNSUBSCRIBE [channel [channel ...]]:退订给定的一个或多个频道，如果执行时没有给定任何频道，那么退订所有频道|
|PUBLISH|PUBLISH channel message:向给定频道发送消息|
|PSUBSCRIBE|PSUBSCRIBE pattern [pattern ...]:订阅与给定模式相匹配的所有频道|
|PUNSUBSCRIBE|PUNSUBSCRIBE [pattern [pattern ...]]:退订给定的模式，如果执行时没有给定任何模式，那么退订所有模式|

7. 排序

|命令|用例和描述|
|:--------:|:----------------:|
|SORT|SORT source-key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]] [ASC|DESC] [ALPHA] [STORE dest-key]:根据给定的选项，对输入列表、集合或者有序集合进行排序，然后返回或者存储排序结果|

8. 键的过期时间

|命令|用例和描述|
|:--------:|:----------------:|
|PERSIST|PERSIST key-name:移除键的过期时间|
|TTL|TTL key-name:查看给定键距离过期还有多少秒|
|EXPIRE|EXPIRE key-name seconds:让给定键在指定的秒数之后过期|
|EXPIREAT|EXPIREAT key-name timestamp:将给定键的过期时间设置为给定的UNIX时间戳|
|PTTL|PTTL key-name:查看给定键距离过期时间还有多少毫秒|
|PEXPIRE|PEXPIRE key-name milliseconds:让给定键在指定的毫秒数之后过期|
|PEXPIREAT|PEXPIREAT key-name timestamp-milliseconds:讲一个毫秒级精度的UNIX时间戳设置为给定键的过期时间|

###### 数据安全和性能
Redis提供两种不同的持久化方法来将数据存储到硬盘里面，一种方法叫快照(snapshotting)，它可以将存在某一时刻的所有数据都写入硬盘。另一种方法叫只追加文件(append-only
 file, AOF)，它会在执行写命令时，将被执行的写命令复制到硬盘里面。Redis可以通过创建快照来获得存储在内存里面的数据在某个时间点上的副本。在创建快照之后，用户可以对
 快照进行备份，可以将快照复制到其他服务器从而创建具有相同数据的服务器副本，还可以将快照留在原地以便重启服务器时使用。创建快照的办法有一下几种：
 * 客户端可以通过向Redis发送BGSAVE命令来创建一个快照。
 * 客户端可以通过向Redis发送SAVE命令来创建一个快照，接到SAVE命令的Redis服务器在快照创建完毕之前将不再响应任何其他命令。
 * 如果用户设置了SAVE配置选项，比如`save 60 10000`，那么从Redis最近一次创建快照之后开始算起，当“60秒内有10000次写入”这个条件被满足时，Redis就会自动触发BGSAVE
 命令。如果用户设置了多个save配置选项，那么当任意一个save配置选项所设置的条件被满足时，Redis就会触发一次BGSAVE命令。
 * 当Redis通过SHUTDOWN命令接受到关闭服务器的请求时，或者接受到标准TERM信号时，会执行一个SAVE命令，阻塞所有客户端，不再执行客户端发送的任何命令，并在SAVE命令执行
完毕之后关闭服务器。
 * 当一个Redis服务器连接另一个Redis服务器，并向对方发送SYNC命令来开启一次复制操作的时候，如果主服务器目前没有在执行BGSAVE操作，或者主服务器并非刚刚执行完BGSAVE
操作，那么主服务器就会执行BGSAVE命令。
在只使用快照持久化来保存数据时，一定要记住：如果系统真的发生崩溃，用户将丢失最近一次生成快照之后更改的所有数据。因此，快照持久化只适用于那些即使丢失一部分数据也不
会造成问题的应用程序，而不能接受这种数据损失的应用程序则可以考虑使用AOF持久化。简单来讲，AOF持久化会将被执行的写命令写到AOF文件的结尾，以此来记录数据发生的变化。
因此，Redis只要从头到尾重新执行一次AOF文件包含的所有写命令，就可以恢复AOF文件所记录的数据集。可以通过配置`appendonly yes`来开启AOF持久化功能。同步频率见下表：  

|选项|同步频率|  
|:--------:|:----------------:|  
|always|每个Redis写命令都要同步写入硬盘，这样做会严重降低Redis的速度|  
|everysec|每秒执行一次同步，显式地将多个写入命令同步到硬盘|  
|no|让操作系统来决定应该何时进行同步|  

###### 复制
对于有扩展平台以适应更高负载经验的工程师和管理员来说，复制(replication)是不可或缺的。复制可以让其他服务器拥有一个不断地更新的数据副本。从而使得拥有数据副本的服务
器可以用于处理客户端发送的读请求。关系数据库通常会使用一个主服务器(master)向多个从服务器(slave)发送更新，并使用从服务器来处理所有读请求。Redis也采用了同样的方法
来实现自己的复制特性，并将其用作扩展性能的一种手段。Redis复制的基本同步策略当从服务器接受到了服务器发送的数据初始副本(initial copy of the data)之后，客户端每次
向主服务器进行写入时，从服务器都会实时地得到更新。在部署好主从服务器之后，客户端就可以向任意一个从服务器发送读请求了。而不必像之前一样，总是把每个读请求都发送给主
服务器(客户端通常会随机地选择使用哪个从服务器，从而将负载平均分配到各个从服务器上)。

Redis复制启动过程

|步骤|主服务器操作|从服务器操作|
|:--------:|:----------------:|:----------------:|
|1|等待命令进入|连接(或者重连接)主服务器，发送SYNC命令|
|2|开始执行BGSAVE，并使用缓冲区记录BGSAVE之后执行的所有命令|根据配置选项来决定是继续使用现有的数据(如果有的话)来处理客户端的命令请求，还是发送请求的客户端返回错误|
|3|BGSAVE执行完毕，向从服务器发送快照文件，并在发送期间继续使用缓冲区记录被执行的写命令|丢弃所有旧数据(如果有的话)，开始载入主服务器发来的快照文件|
|4|快照文件发送完毕，开始向从服务器发送存储在缓存区里面的写命令|完成快照文件的解释操作，像往常一样开始接受命令请求|
|5|缓冲区存储的写命令发送完毕；从现在开始，没执行一个写命令，就向从服务器发送相同的写命令|执行主服务器发来的所有存储在缓存区里面的写命令；并从现在开始，接受并执行主服务器传来的每个写命令|

###### Redis事务
Redis通过MULTI、DISCARD、EXEC和WATCH四个命令来实现事务功能，事务提供了一种“将多命令打包，然后一次性、按顺序地执行”的机制，并且事务在执行的期间不会主动中断————服务器
在执行完事务中的所有命令之后，才会继续处理其他客户端的其他命令。一个事务从开始执行会经历三个阶段：1.开始事务；2.命令入队；3.执行事务  

`MULTI`命令的执行标记着事务的开始，这个命令唯一做的就是， 将客户端的 REDIS_MULTI 选项打开， 让客户端从非事务状态切换到事务状态。当客户端处于非事务状态下时，所有
发送给服务器端的命令都会立即被服务器执行。但是当客户端进入事务状态之后，服务器在收到来自客户端的命令时，不会立即执行命令，而是将这些命令全部放进一个事务队列里，然
后返回`QUEUED`，表示命令已入队。以下图1展示了Redis事务的行为：
![图1-1][Redis_transaction01]

事务队列是一个数组，每个数组项是都包含三个属性:1.要执行的命令；2.命令的参数；3.参数的个数，举个例子来说明事务队列，如果客户端执行以下命令：
```
redis> MULTI
OK

redis> SET book-name "Mastering C++ in 21 days"
QUEUED

redis> GET book-name
QUEUED

redis> SADD tag "C++" "Programming" "Mastering Series"
QUEUED

redis> SMEMBERS tag
QUEUED
```
那么程序将为客户端创建以下事务队列：

|数组索引|要执行的命令(cmd)|命令的参数(argv)|参数的个数(argc)|
|:--------:|:----------------:|:----------------:|:--------:|
|0|SET|["book-name","Mastering C++ in 21 days"]|2|
|1|GET|["book-name"]|1|
|2|SADD|["tag","C++","Programming","Mastering Series"]|4|
|3|SMEMBERS|["tag"]|1|

前面说到，当客户端进入事务状态之后，客户端发送的命令就会被放进事务队列里。但其实并不是所有的命令都会被放进事务队列，其中的例外就是EXEC、DISCARD、MULTI和、WATCH这
四个命令————当这四个命令从客户端发送到服务器时，它们会像客户端处于非事务状态一样，直接被服务器执行，服务器执行行为如图2所示：
![图1-2][Redis_transaction02]

如果客户端正处于事务状态，那么当EXEC命令执行时，服务器根据客户端所保存的事务队列，以先进先出（FIFO）的方式执行事务队列中的命令：最先入队的命令最先执行，而最后入队
的命令最后执行。执行事务中的命令所得的结果会以FIFO的顺序保存到一个回复队列中。比如说，对于上面给出的事务队列，程序将为队列中的命令创建如下回复队列：

|数组索引|恢复类型|恢复内容|
|:--------:|:----------------:|:----------------:|
|0|status code reply|ok|
|1|bulk reply|"Mastering C++ in 21 days"|
|2|integer reply|3|
|3|multi-bulk reply|["Mastering Series", "C++", "Programming"]|

当事务队列里的所有命令被执行完之后，EXEC命令会将回复队列作为自己的执行结果返回给客户端，客户端从事务状态返回到非事务状态，至此，事务执行完毕。无论在事务状态下，还是
在非事务状态下，Redis命令都由同一个函数执行，所以它们共享很多服务器的一般设置，比如AOF的配置、RDB的配置，以及内存限制，等等。不过事务中的命令和普通命令在执行上还是
有一点区别的，其中最重要的两点是：

1. 非事务状态下的命令以单个命令为单位执行，前一个命令和后一个命令的客户端不一定是同一个；而事务状态则是以一个事务为单位，执行事务队列中的所有命令：除非当前事务执行完
毕，否则服务器不会中断事务，也不会执行其他客户端的其他命令。
2. 在非事务状态下，执行命令所得的结果会立即被返回给客户端；而事务则是将所有命令的结果集合到回复队列，再作为 EXEC 命令的结果返回给客户端。

DISCARD命令用于取消一个事务，它清空客户端的整个事务队列，然后将客户端从事务状态调整回非事务状态，最后返回字符串OK给客户端，说明事务已被取消。Redis 的事务是不可嵌套的，
当客户端已经处于事务状态，而客户端又再向服务器发送MULTI时，服务器只是简单地向客户端发送一个错误，然后继续等待其他命令的入队。MULTI命令的发送不会造成整个事务失败，也不
会修改事务队列中已有的数据。WATCH只能在客户端进入事务状态之前执行，在事务状态下发送WATCH命令会引发一个错误，但它不会造成整个事务失败，也不会修改事务队列中已有的数据（
和前面处理 MULTI 的情况一样）。  

WATCH只能在客户端进入事务状态之前执行，在事务状态下发送WATCH命令会引发一个错误，但它不会造成整个事务失败，也不会修改事务队列中已有的数据（和前面处理MULTI的情况一样）。
在传统的关系式数据库中，常常用 ACID 性质来检验事务功能的安全性。Redis 事务保证了其中的一致性（C）和隔离性（I），但并不保证原子性（A）和持久性（D）。

[Redis_transaction01]: ../image/redis_transaction01.png "图1-1"
[Redis_transaction02]: ../image/redis_transaction02.png "图1-2"
