# SpringCloud学习手册



### 1. Spring Cloud Consul 服务发现和配置中心

##### 服务注册与发现

 CAP理论的核心是：一个分布式系统不可能同时很好的满足一致性，可用性和分区容错性这三个需求，最多只能同时较好的满足两个。因此，根据 CAP 原理将 NoSQL 数据库分成了满足 CA 原则、满足 CP 原则和满足 AP 原则三大类：

CA - 单点集群，满足一致性，可用性的系统，通常在可扩展性上不太强大。

CP - 满足一致性，分区容错性的系统，通常性能不是特别高。

AP - 满足可用性，分区容错性的系统，通常可能对一致性要求低一些，但是满足高可用。

![graphic](../image/spring_cloud_cap.png)

市面上主流的分布式架构都会选择AP或者CP架构，如果一个分布式系统没有分区容错性那其实和单体应用没有太大的区别：

AP架构：以老的服务发现Eureka为例，当网络分区出现后，为了保证可用性，系统B可以返回旧值，保证系统的可用性。当数据出现不一致时，虽然A, B上的注册信息不完全相同，但每个Eureka节点依然能够正常对外提供服务，这会出现查询服务信息时如果请求A查不到，但请求B就能查到。如此保证了可用性但牺牲了一致性结论：违背了一致性C的要求，只满足可用性和分区容错，即AP。

CP架构：当网络分区出现后，为了保证一致性，**就必须拒接请求**，否则无法保证一致性，Consul 遵循CAP原理中的CP原则，保证了强一致性和分区容错性，且使用的是Raft算法，比zookeeper使用的Paxos算法更加简单。虽然保证了强一致性，但是可用性就相应下降了，例如服务注册的时间会稍长一些，因为 Consul 的 raft 协议要求必须过半数的节点都写入成功才认为注册成功 ；在leader挂掉了之后，重新选举出leader之前会导致Consul 服务不可用。结论：违背了可用性A的要求，只满足一致性和分区容错，即CP。



##### 配置中心

微服务意味着要将单体应用中的业务拆分成一个个子服务，每个服务的粒度相对较小，因此系统中会出现大量的服务。由于每个服务都需要必要的配置信息才能运行，所以一套集中式的、动态的配置管理设施是必不可少的。比如某些配置文件中的内容大部分都是相同的，只有个别的配置项不同。就拿数据库配置来说吧，如果每个微服务使用的技术栈都是相同的，则每个微服务中关于数据库的配置几乎都是相同的，有时候主机迁移了，我希望一次修改，处处生效。



applicaiton.yml是用户级的资源配置项，bootstrap.yml是系统级的，优先级更加高，Spring Cloud会创建一个“Bootstrap Context”，作为Spring应用的`Application Context`的父上下文。初始化的时候，`Bootstrap Context`负责从外部源加载配置属性并解析配置。这两个上下文共享一个从外部获取的`Environment`。`Bootstrap`属性有高优先级，默认情况下，它们不会被本地配置覆盖。 `Bootstrap context`和`Application Context`有着不同的约定，所以新增了一个`bootstrap.yml`文件，保证`Bootstrap Context`和`Application Context`配置的分离。 application.yml文件改为bootstrap.yml,这是很关键的或者两者共存，因为bootstrap.yml是比application.yml先加载的。bootstrap.yml优先级高于application.yml。



### 2. Spring Cloud LoadBalance 客户端负载均衡

**LB负载均衡(Load Balance)是什么**

简单的说就是将用户的请求平摊的分配到多个服务上，从而达到系统的HA（高可用），常见的负载均衡有软件Nginx，LVS，硬件 F5等。

**spring-cloud-starter-loadbalancer组件是什么**

Spring Cloud LoadBalancer是由SpringCloud官方提供的一个开源的、简单易用的**客户端负载均衡器**，它包含在SpringCloud-commons中用它来替换了以前的Ribbon组件。相比较于Ribbon，SpringCloud LoadBalancer不仅能够支持RestTemplate，还支持WebClient（WeClient是Spring Web Flux中提供的功能，可以实现响应式异步请求）。

负载均衡算法：rest接口第几次请求数 % 服务器集群总数量 = 实际调用服务器位置下标 ，每次服务重启动后rest接口计数从1开始。

`List<ServiceInstance> instances = discoveryClient.getInstances("cloud-payment-service");`

如： List [0] instances = 127.0.0.1:8002

　　List [1] instances = 127.0.0.1:8001

 8001+ 8002 组合成为集群，它们共计2台机器，集群总数为2， 按照轮询算法原理：当总请求数为1时： 1 % 2 =1 对应下标位置为1 ，则获得服务地址为127.0.0.1:8001。

Spring Cloud LoadBalance默认支持两种负载均衡策略：轮询、随机，如果你需要定制化负载均衡算法可以继承ReactorServiceInstanceLoadBalancer然后重写choose方法。



### 3. Spring Cloud OpenFeign

Feign是一个**声明性web服务客户端**。它使编写web服务客户端变得更容易。使用Feign创建一个接口并对其进行注释。它具有可插入的注释支持，包括Feign注释和JAX-RS注释。Feign还支持可插拔编码器和解码器。Spring Cloud添加了对Spring MVC注释的支持，以及对使用Spring Web中默认使用的HttpMessageConverter的支持。Spring Cloud集成了Eureka、Spring Cloud CircuitBreaker以及Spring Cloud LoadBalancer，以便在使用Feign时提供负载平衡的http客户端。

##### OpenFeign能干什么

前面在使用**SpringCloud LoadBalancer**+RestTemplate时，利用RestTemplate对http请求的封装处理形成了一套模版化的调用方法。但是在实际开发中，由于对服务依赖的调用可能不止一处，往往一个接口会被多处调用，所以通常都会针对每个微服务自行封装一些客户端类来包装这些依赖服务的调用。所以，OpenFeign在此基础上做了进一步封装，由他来帮助我们定义和实现依赖服务接口的定义。在OpenFeign的实现下，我们只需创建一个接口并使用注解的方式来配置它(在一个微服务接口上面标注一个**@FeignClient**注解即可)，即可完成对服务提供方的接口绑定，统一对外暴露可以被调用的接口方法，大大简化和降低了调用客户端的开发量，也即由服务提供者给出调用接口清单，消费者直接通过OpenFeign调用即可。

OpenFeign同时还集成SpringCloud LoadBalancer，可以在使用OpenFeign时提供Http客户端的负载均衡，也可以集成阿里巴巴Sentinel来提供熔断、降级等功能。而与SpringCloud LoadBalancer不同的是，通过OpenFeign只需要定义服务绑定接口且以声明式的方法，优雅而简单的实现了服务调用。



##### OpenFeign高级配置

在Spring Cloud微服务架构中，大部分公司都是利用OpenFeign进行服务间的调用，而比较简单的业务使用默认配置是不会有多大问题的，但是如果是业务比较复杂，服务要进行比较繁杂的业务计算，那后台很有可能会出现Read Timeout这个异常，因此定制化配置超时时间就有必要了。默认OpenFeign客户端等待60秒钟，但是服务端处理超过规定时间会导致Feign客户端返回报错。为了避免这样的情况，有时候我们需要设置Feign客户端的超时控制，默认60秒太长或者业务时间太短都不好。

 yml文件中开启配置：

1. connectTimeout    连接超时时间

2. readTimeout       请求处理超时时间

```yaml
spring:
  application:
    name: cloud_consumer_openfeign_order
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        prefer-ip-address: true #优先使用服务ip进行注册
        service-name: ${spring.application.name}
    openfeign:
      client:
        config:
#          default:
#            #连接超时时间
#            connectTimeout: 3000
#            #读取超时时间
#            readTimeout: 3000
          cloud-payment-service:
            #连接超时时间
            connectTimeout: 20000
            #读取超时时间
            readTimeout: 20000
      httpclient:
        hc5:
          enabled: true
      compression:
        request:
          enabled: true
          min-request-size: 2048 #最小触发压缩的大小
          mime-types: text/xml,application/xml,application/json #触发压缩数据类型
        response:
          enabled: true
```

OpenFeign的重试机制，默认情况下OpenFeign是关闭重试机制的，如果需要开启重试的话需要使用配置Bean来配置重试机制：

```java
    @Bean
    public Retryer myRetryer()
    {
//        return Retryer.NEVER_RETRY; //Feign默认配置是不走重试策略的

        //最大请求次数为3(1+2)，初始间隔时间为100ms，重试间最大间隔时间为1s
        return new Retryer.Default(100,1,3);
    }
```

OpenFeign替换默认的HTTPClient为Apache HTTPClient5需要添加依赖和yml文件指定httpclient的版本：

```xml
<!-- httpclient5-->
<dependency>
    <groupId>org.apache.httpcomponents.client5</groupId>
    <artifactId>httpclient5</artifactId>
    <version>5.3</version>
</dependency>
<!-- feign-hc5-->
<dependency>
    <groupId>io.github.openfeign</groupId>
    <artifactId>feign-hc5</artifactId>
    <version>13.1</version>
</dependency>
```

**对请求和响应进行GZIP压缩**

Spring Cloud OpenFeign支持对请求和响应进行GZIP压缩，以减少通信过程中的性能损耗。通过下面的两个参数设置，就能开启请求与相应的压缩功能：

spring.cloud.openfeign.compression.request.enabled=true

spring.cloud.openfeign.compression.response.enabled=true

**细粒度化设置**

对请求压缩做一些更细致的设置，比如下面的配置内容指定压缩的请求数据类型并设置了请求压缩的大小下限，只有超过这个大小的请求才会进行压缩：

spring.cloud.openfeign.compression.request.enabled=true

spring.cloud.openfeign.compression.request.mime-types=text/xml,application/xml,application/json #触发压缩数据类型

spring.cloud.openfeign.compression.request.min-request-size=2048 #最小触发压缩的大小

Feign 提供了日志打印功能，我们可以通过配置来调整日志级别，从而了解 Feign 中 Http 请求的细节，说白了就是对Feign接口的调用情况进行监控和输出，OpenFeign的日志分为4个级别：

- NONE：默认的，不显示任何日志；

- BASIC：仅记录请求方法、URL、响应状态码及执行时间；

- HEADERS：除了 BASIC 中定义的信息之外，还有请求和响应的头信息；

- FULL：除了 HEADERS 中定义的信息之外，还有请求和响应的正文及元数据。

首先需要开启OpenFeign的日志，这里使用配置Bean的方式开启：

```java
    @Bean
    Logger.Level feignLoggerLevel() {
        return Logger.Level.FULL;
    }
```

然后需要在yml文件中开启OpenFeign客户端的日志：

```yml
# feign日志以什么级别监控哪个接口
logging:
  level:
    com:
      vilin:
        cloud:
          apis:
            PayFeignApi: debug 
```

### 4. Spring Cloud Circuit Breaker

CircuitBreaker的目的是保护分布式系统免受故障和异常，提高系统的可用性和健壮性。当一个组件或服务出现故障时，CircuitBreaker会迅速切换到开放OPEN状态(保险丝跳闸断电)，阻止请求发送到该组件或服务从而避免更多的请求发送到该组件或服务。这可以减少对该组件或服务的负载，防止该组件或服务进一步崩溃，并使整个系统能够继续正常运行。同时，CircuitBreaker还可以提高系统的可用性和健壮性，因为它可以在分布式系统的各个组件之间自动切换，从而避免单点故障的问题。Circuit Breaker只是一套规范和接口，具体实现是Resilience4J。

Resilience4J是一个专门为函数式编程设计的轻量级容错库。Resilience4J提供高阶函数，以通过断路器、速率限制器、重试或隔板增强任何功能接口、lambda表达式或方法引用。

##### 断路器

断路器通过有限状态机实现，有三个普通状态：关闭、开启、半开，还有两个特殊状态：禁用、强制开启。

![circuit_breaker](..\image\circuit_breaker.jpg)

断路器使用滑动窗口来存储和统计调用的结果。你可以选择基于调用数量的滑动窗口或者基于时间的滑动窗口。基于访问数量的滑动窗口统计了最近N次调用的返回结果。居于时间的滑动窗口统计了最近N秒的调用返回结果。

##### 基于访问数量的滑动窗口

基于访问数量的滑动窗口是通过一个有N个元素的循环数组实现。

如果滑动窗口的大小等于10，那么循环数组总是有10个统计值。滑动窗口增量更新总的统计值，随着新的调用结果被记录在环形数组中，总的统计值也随之进行更新。当环形数组满了，时间最久的元素将被驱逐，将从总的统计值中减去该元素的统计值，并该元素所在的桶进行重置。

检索快照（总的统计值）的时间复杂度为O(1)，因为快照已经预先统计好了，并且和滑动窗口大小无关。关于此方法实现的空间需求（内存消耗）为O(n)。

##### 基于时间的滑动窗口

基于时间的滑动窗口是通过有N个桶的环形数组实现。

如果滑动窗口的大小为10秒，这个环形数组总是有10个桶，每个桶统计了在这一秒发生的所有调用的结果（部分统计结果），数组中的第一个桶存储了当前这一秒内的所有调用的结果，其他的桶存储了之前每秒调用的结果。

滑动窗口不会单独存储所有的调用结果，而是对每个桶内的统计结果和总的统计值进行增量的更新，当新的调用结果被记录时，总的统计值会进行增量更新。

检索快照（总的统计值）的时间复杂度为O(1)，因为快照已经预先统计好了，并且和滑动窗口大小无关。关于此方法实现的空间需求（内存消耗）约等于O(n)。由于每次调用结果（元组）不会被单独存储，只是对N个桶进行单独统计和一次总分的统计。

每个桶在进行部分统计时存在三个整型，为了计算，失败调用数，慢调用数，总调用数。还有一个long类型变量，存储所有调用的响应时间。

##### 失败率和慢调用率阈值

当失败率大于或等于配置的阈值时，断路器的状态将从关闭变为开启，例如，当超过50%的调用失败时，断路器开启。

默认是把所有的异常看作是失败，你可以自己定义一个异常的列表，这些异常会被视为错误，其他的异常会被视为调用成功，除非是可以被忽略的异常。异常是可以被忽略的，这样它们既不算成功也不是算失败。

当慢调用的百分比大于等于配置的阈值时，断路器的状态将从关闭变为开启，例如，当超过50%的调用响应时间超过5秒时，断路器开启，这有助于在外部系统实际上没有响应之前减少它的负载。

只有在记录了最小调用次数的情况下，才能计算失败率和慢调用率。例如，如果所需调用的最小数目为10，则必须至少记录10个调用，然后才能计算失败率。如果只记录了9个调用，即使所有9个调用都失败，断路器也不会开启。

断路器在开启时，将会使用`CallNotPermittedException`来拒绝请求。在一段时间之后，断路器的状态将从开启变为半开，并且允许一定数量的调用通过，来判断后端的服务是否还是不可用或已变为可用，在所有允许通过断路器的调用完成之前，其余的调用还是被`CallNotPermittedException`拒绝。如果失败率或慢调用率大于等于配置的阈值，断路器状态将继续回到开启，如果失败率和慢调用率低于配置的阈值，断路器状态变为关闭。

断路器还支持两种特殊的状态，禁用（总是允许访问）和强制开启（总是拒绝访问）。在这两种状态下，不会产生断路器事件（除了状态转换），也不会记录任何指标。退出这些状态的唯一方法是触发状态转换或重置断路器。

断路器是线程安全的:

- 断路器的状态是原子引用。
- 断路器使用原子操作以无副作用的功能来更新状态。
- 从滑动窗口中记录调用结果和读取快照是同步的。

这意味着原子性得到了保证，在某一时刻，只允许一个线程对断路器的状态进行更改，和对滑动窗口进行操作。

但是断路器不会同步方法调用，这意味着方法调用不是核心的部分。否则，短路器将会带来大量的性能损失和瓶颈，耗时的方法调用会对整体性能/吞吐量带来巨大的负面影响。

如果有20个并发线程想要执行某个函数，并且断路器的状态为关闭，所有的线程都被允许进行方法调用，即使假设滑动窗口的大小是15，也不意味滑动窗口只允许15个调用并发的执行。如果你想要限制并发线程的数量，需要使用隔离机制，将隔离机制和断路器组合使用。
