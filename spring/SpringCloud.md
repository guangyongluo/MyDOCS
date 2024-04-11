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

