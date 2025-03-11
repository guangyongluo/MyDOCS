### Envoy学习手册

##### Envoy是什么？

  IT行业正在向微服务架构和云原生解决方案发展。由于使用不同的技术开发了成百上千的微服务，这些系统可能变得复杂，难以调试。

作为一个应用开发者，你考虑的是业务逻辑——购买产品或生成发票。然而，任何这样的业务逻辑都会导致不同服务之间的多个服务调用。每个服务可能都有它的超时、重试逻辑和其他可能需要调整或微调的网络特定代码。

如果在任何时候最初的请求失败了，就很难通过多个服务来追踪，准确地指出失败发生的地方，了解请求为什么失败。是网络不可靠吗？是否需要调整重试或超时？或者是业务逻辑问题或错误？

服务可能使用不一致的跟踪和记录机制，使这种调试的复杂性增加。这些问题使你很难确定问题发生在哪里，以及如何解决。如果你是一个应用程序开发人员，而调试网络问题不属于你的核心技能，那就更加增大了查找问题的难度。

将网络问题从应用程序堆栈中抽离出来，由另一个组件来处理网络部分，让调试网络问题变得更容易。这就是 Envoy 所做的事情。

在每个服务实例旁边都有一个 Envoy 实例在运行。这种类型的部署也被称为 **Sidecar 部署**。Envoy 的另一种模式是**边缘代理**，用于构建 API 网关。

Envoy 和应用程序形成一个原子实体，但仍然是独立的进程。应用程序处理业务逻辑，而 Envoy 则处理网络问题。

在发生故障的情况下，分离关注点可以更容易确定故障是来自应用程序还是网络。

为了帮助网络调试，Envoy 提供了以下高级功能。

1. ###### 进程外架构：

Envoy 是一个独立的进程，旨在与每个应用程序一起运行 —— 也就是我们前面提到的 Sidecar 部署模式。集中配置的 Envoy 集合形成了一个透明的服务网格。

路由和其他网络功能的责任被推给了 Envoy。应用程序向一个虚拟地址（localhost）而不是真实地址（如公共 IP 地址或主机名）发送请求，不知道网络拓扑结构。应用程序不再承担路由的责任，因为该任务被委托给一个外部进程。

与其让应用程序管理其网络配置，不如在 Envoy 层面上独立于应用程序管理网络配置。在一个组织中，这可以使应用程序开发人员解放出来，专注于应用程序的业务逻辑。

Envoy 适用于任何编程语言。你可以用 Go、Java、C++ 或其他任何语言编写你的应用程序，而 Envoy 可以在它们之间架起桥梁。无论应用程序的编程语言或它们运行的操作系统是什么，负责服务网格的任务总是一致的，就是对进出应用程序的网络流量做精细化管理。

Envoy 还可以在整个基础设施中透明地进行部署和升级。这与为每个单独的应用程序部署库升级相比，后者可能是非常痛苦和耗时的。

进程外架构是有益的，因为它使我们在不同的编程语言 / 应用堆栈中保持一致，我们可以免费获得独立的应用生命周期和所有的 Envoy 网络功能，而不必在每个应用中单独解决这些问题。

2. ###### L3/L4过滤器结构

Envoy 是一个 L3/L4 网络代理，根据 IP 地址和 TCP 或 UDP 端口进行决策。它具有一个可插拔的过滤器链，可以编写你的过滤器来执行不同的 TCP/UDP 任务。

**过滤器链（Filter Chain）** 的想法借鉴了 Linux shell，即一个操作的输出被输送到另一个操作中。例如：

```sh
 ls -l | grep "Envoy*.cc" | wc -l
```

Envoy 可以通过堆叠所需的过滤器来构建逻辑和行为，形成一个过滤器链。许多过滤器已经存在，并支持诸如原始 TCP 代理、UDP 代理、HTTP 代理、TLS 客户端认证等任务。Envoy 也是可扩展的，我们可以编写我们的过滤器。

3. ###### L7 过滤器结构

Envoy 支持一个额外的 HTTP L7 过滤器层。我们可以在 HTTP 连接管理子系统中插入 HTTP 过滤器，执行不同的任务，如缓冲、速率限制、路由 / 转发等。

4. ###### 一流的 HTTP/2 支持

Envoy 同时支持 HTTP/1.1 和 HTTP/2，并且可以作为一个透明的 HTTP/1.1 到 HTTP/2 的双向代理进行操作。这意味着任何 HTTP/1.1 和 HTTP/2 客户端和目标服务器的组合都可以被桥接起来。即使你的传统应用没有通过 HTTP/2 进行通信，如果你把它们部署在 Envoy 代理旁边，它们最终也会通过 HTTP/2 进行通信。

推荐在所有的服务间配置的 Envoy 使用 HTTP/2，以创建一个持久连接的网格，请求和响应可以在上面复用。

5. ###### HTTP 路由

当以 HTTP 模式操作并使用 REST 时，Envoy 支持路由子系统，能够根据路径、权限、内容类型和运行时间值来路由和重定向请求。在将 Envoy 作为构建 API 网关的前台 / 边缘代理时，这一功能非常有用，在构建服务网格（sidecar 部署模式）时，也可以利用这一功能。

6. ###### 支持gRPC 

Envoy 支持作为 gRPC 请求和响应的路由和负载均衡底层所需的所有 HTTP/2 功能。

> gRPC 是一个开源的远程过程调用（RPC）系统，它使用 HTTP/2 进行传输，并将协议缓冲区作为接口描述语言（IDL），它提供的功能包括认证、双向流和流量控制、阻塞 / 非阻塞绑定，以及取消和超时。

7. ###### 服务发现和动态配置

我们可以使用静态配置文件来配置 Envoy，这些文件描述了服务间通信方式。

对于静态配置 Envoy 无法满足的高级场景，Envoy 支持动态配置，在运行时自动重新加载配置。一组名为 xDS 的发现服务可以用来通过网络动态配置 Envoy，并为 Envoy 提供关于主机、集群 HTTP 路由、监听套接字和加密信息。

8. ###### 健康检查

负载均衡器有一个特点，那就是只将流量路由到健康和可用的上游服务。Envoy 支持健康检查子系统，对上游服务集群进行主动健康检查。然后，Envoy 使用服务发现和健康检查信息的组合来确定健康的负载均衡目标。Envoy 还可以通过异常点检测子系统支持被动健康检查。

9. ###### 高级负载均衡

Envoy 支持自动重试、断路、全局速率限制（使用外部速率限制服务）、影子请求（或流量镜像）、异常点检测和请求对冲。

10. ###### 前端 / 边缘代理支持

Envoy 的特点使其非常适合作为边缘代理运行。这些功能包括 TLS 终端、HTTP/1.1、HTTP/2 和 HTTP/3 支持，以及 HTTP L7 路由。

11. ###### TLS 终止

应用程序和代理的解耦使网格部署模型中所有服务之间的 TLS 终止（双向 TLS）成为可能。

12. ###### 可观察性

为了便于观察，Envoy 会生成日志、指标和追踪。Envoy 目前支持 statsd（和兼容的提供者）作为所有子系统的统计。得益于可扩展性，我们也可以在需要时插入不同的统计提供商。

13. ###### HTTP/3

Envoy支持 HTTP/3 的上行和下行，并在 HTTP/1.1、HTTP/2 和 HTTP/3 之间进行双向转义。

##### Envoy 的构建模块

Envoy 配置的根被称为引导配置。它包含了一些字段，我们可以在这里提供静态或动态的资源和高级别的 Envoy 配置（例如，Envoy 实例名称、运行时配置、启用管理界面等等）。

下图显示了通过这些概念的请求流。

![envoy_request_flow](C:\Users\LENOVO\Documents\MyDOCS\image\envoy_request_flow.png)

这一切都从**监听器**开始。Envoy 暴露的监听器是命名的网络位置，可以是一个 IP 地址和一个端口，也可以是一个 Unix 域套接字路径。Envoy 通过监听器接收连接和请求。考虑一下下面的 Envoy 配置。

```yaml
 static_resources:
   listeners:
   - name: listener_0
     address:
       socket_address:
         address: 0.0.0.0
         port_value: 10000
     filter_chains: [{}]
```

通过上面的 Envoy 配置，我们在  `0.0.0.0` 地址的 `10000` 端口上声明了一个名为 `listener_0` 的监听器。这意味着 Envoy 正在监听 `0.0.0.0:10000` 的传入请求。

每个监听器都有不同的配置项需要配置。然而，唯一必须的设置是地址。上述配置是有效的，你可以用它来运行 Envoy—— 尽管它没有用，因为所有的连接都会被关闭。

我们让 `filter_chains` 字段为空，因为在接收数据包后不需要额外的操作。

为了进入下一个构件（路由），我们需要创建一个或多个网络过滤器链（`filter_chains`），至少要有一个过滤器。

网络过滤器通常对数据包的有效载荷进行操作，查看有效载荷并对其进行解析。例如，Postgres 网络过滤器解析数据包的主体，检查数据库操作的种类或其携带的结果。

Envoy 定义了三类过滤器：监听器过滤器、网络过滤器和 HTTP 过滤器。监听器过滤器在收到数据包后立即启动，通常对数据包的头信息进行操作。监听器过滤器包括代理监听器过滤器（提取 PROXY 协议头），或 TLS 检查器监听器过滤器（检查流量是否为 TLS，如果是，则从 TLS 握手中提取数据）。

每个通过监听器进来的请求可以流经多个过滤器。我们还可以写一个配置，根据传入的请求或连接属性选择不同的过滤器链。

![](C:\Users\LENOVO\Documents\MyDOCS\image\multiple_filter_chain.png)

一个特殊的、内置的网络过滤器被称为 **HTTP 连接管理器**过滤器（HTTP Connection Manager Filter）或 **HCM**。HCM 过滤器能够将原始字节转换为 HTTP 级别的消息。它可以处理访问日志，生成请求 ID，操作头信息，管理路由表，并收集统计数据。

就像我们可以为每个监听器定义多个网络过滤器（其中一个是 HCM）一样，Envoy 也支持在 HCM 过滤器中定义多个 HTTP 级过滤器。我们可以在名为 `http_filters` 的字段下定义这些 HTTP 过滤器。

![](C:\Users\LENOVO\Documents\MyDOCS\image\multiple_http_filters.png)

HTTP 过滤器链中的最后一个过滤器必须是路由器过滤器（`envoy.filters.HTTP.router`）。路由器过滤器负责执行路由任务。这最终把我们带到了第二个构件 —— **路由**。

我们在 HCM 过滤器的 `route_config` 字段下定义路由配置。在路由配置中，我们可以通过查看元数据（URI、Header 等）来匹配传入的请求，并在此基础上，定义流量的发送位置。

路由配置中的顶级元素是虚拟主机。每个虚拟主机都有一个名字，在发布统计数据时使用（不用于路由），还有一组被路由到它的域。

让我们来看下面的路由配置和域的集合。

```yaml
 route_config:
   name: my_route_config
   virtual_hosts:
   - name: tetrate_hosts
     domains: ["tetrate.io"]
     routes:
     ...
   - name: test_hosts
     domains: ["test.tetrate.io", "qa.tetrate.io"]
     routes:
     ...
```

如果传入请求的目的地是 `tetrate.io`（即 `Host/Authority` 标头被设置为其中一个值），则 `tetrate_hosts` 虚拟主机中定义的路由将得到处理。

同样，如果 `Host/Authority` 标头包含 `test.tetrate.io` 或 `qa.tetrate.io`，`test_hosts` 虚拟主机下的路由将被处理。使用这种设计，我们可以用一个监听器（`0.0.0.0:10000`）来处理多个顶级域。

如果你在数组中指定多个域，搜索顺序如下：

1. 精确的域名（例如：`tetrate.io`）。
2. 后缀域名通配符（如 `*.tetrate.io）`。
3. 前缀域名通配符（例如：`tetrate.*`）。
4. 匹配任何域的特殊通配符（`*`）。

在 Envoy 匹配域名后，是时候处理所选虚拟主机中的 `routes` 字段了。这是我们指定如何匹配一个请求，以及接下来如何处理该请求（例如，重定向、转发、重写、发送直接响应等）的地方。

我们来看看一个例子。

```yaml
 static_resources:
   listeners:
   - name: listener_0
     address:
       socket_address:
         address: 0.0.0.0
         port_value: 10000
     filter_chains:
     - filters:
       - name: envoy.filters.network.http_connection_manager
         typed_config:
           "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
           stat_prefix: hello_world_service
           http_filters:
           - name: envoy.filters.http.router
           route_config:
             name: my_first_route
             virtual_hosts:
             - name: direct_response_service
               domains: ["*"]
               routes:
               - match:
                   prefix: "/"
                 direct_response:
                   status: 200
                   body:
                     inline_string: "yay"
```

配置前半部分与我们之前看到的一样。我们已经添加了 HCM 过滤器、统计前缀（`hello_world_service`）、单个 HTTP 过滤器（路由器）和路由配置。

在虚拟主机内，我们要匹配任何域名。在 `routes` 下，我们匹配前缀（`/`），然后我们可以发送一个响应。

当涉及到匹配请求时，我们有多种选择。

| 路由匹配          | 描述                                     | 示例                                                         |
| ----------------- | ---------------------------------------- | ------------------------------------------------------------ |
| `prefix`          | 前缀必须与`:path` 头的开头相符。         | `/hello` 与 `hello.com/hello`、`hello.com/helloworld` 和 `hello.com/hello/v1` 匹配。 |
| `path`            | 路径必须与`:path` 头完全匹配。           | `/hello`匹配 `hello.com/hello`，但不匹配 `hello.com/helloworld`或 `hello.com/hello/v1` |
| `safe_regex`      | 所提供的正则表达式必须与`:path` 头匹配。 | `/\{3}` 匹配任何以 `/` 开头的三位数。例如，与 `hello.com/123` 匹配，但不能匹配 `hello.com/hello` 或 `hello.com/54321。` |
| `connect_matcher` | 匹配器只匹配 CONNECT 请求。              |                                                              |

一旦 Envoy 将请求与路由相匹配，我们就可以对其进行路由、重定向或返回一个直接响应。在这个例子中，我们通过 `direct_response` 配置字段使用**直接响应**。

你可以把上述配置保存到 `envoy-direct-response.yaml` 中。

我们将使用一个名为 [func-e](https://func-e.io/) 的命令行工具。func-e 允许我们选择和使用不同的 Envoy 版本。

我们可以通过运行以下命令下载 func-e CLI。

```sh
 curl https://func-e.io/install.sh | sudo bash -s -- -b /usr/local/bin
```

现在我们用我们创建的配置运行 Envoy。

```sh
 func-e run -c envoy-direct-response.yaml
```

一旦 Envoy 启动，我们就可以向 `localhost:10000` 发送一个请求，以获得我们配置的直接响应。

```sh
 $ curl localhost:10000
 yay
```

同样，如果我们添加一个不同的主机头（例如 `-H "Host: hello.com"`）将得到相同的响应，因为 `hello.com` 主机与虚拟主机中定义的域相匹配。

在大多数情况下，从配置中直接发送响应是一个很好的功能，但我们会有一组端点或主机，我们将流量路由到这些端点或主机。在 Envoy 中做到这一点的方法是通过定义**集群**。

集群（Cluster）是一组接受流量的上游类似主机。这可以是你的服务所监听的主机或 IP 地址的列表。

例如，假设我们的 hello world 服务是在 `127.0.0.0:8000` 上监听。然后，我们可以用一个单一的端点创建一个集群，像这样。

```yaml
 clusters:
 - name: hello_world_service
   load_assignment:
     cluster_name: hello_world_service
     endpoints:
     - lb_endpoints:
       - endpoint:
           address:
             socket_address:
               address: 127.0.0.1
               port_value: 8000
```

集群的定义与监听器的定义在同一级别，使用 `clusters` 字段。我们在路由配置中引用集群时，以及在导出统计数据时，都会使用集群。该名称在所有集群中必须是唯一的。

在 `load_assignment` 字段下，我们可以定义要进行负载均衡的端点列表，以及负载均衡策略设置。

Envoy 支持多种负载均衡算法（round-robin、Maglev、least-request、random），这些算法是由静态引导配置、DNS、动态 xDS（CDS 和 EDS 服务）以及主动 / 被动健康检查共同配置的。如果我们没有通过 `lb_policy` 字段明确地设置负载均衡算法，它默认为 round-robin。

`endpoints` 字段定义了一组属于特定地域的端点。使用可选的 `locality` 字段，我们可以指定上游主机的运行位置，然后在负载均衡过程中使用（即，将请求代理到离调用者更近的端点）。

添加新的端点指示负载均衡器在一个以上的接收者之间分配流量。通常情况下，负载均衡器对所有端点一视同仁，但集群定义允许在端点内建立一个层次结构。

例如，端点可以有一个 **权重（weight）** 属性，这将指示负载均衡器与其他端点相比，向这些端点发送更多 / 更少的流量。

另一种层次结构类型是基于**地域性的（locality）**，通常用于定义故障转移架构。这种层次结构允许我们定义地理上比较接近的 "首选" 端点，以及在 "首选" 端点变得不健康的情况下应该使用的 "备份" 端点。

由于我们只有一个端点，所以我们还没有设置 locality。在 `lb_endpoints` 字段下，可以定义 Envoy 可以路由流量的实际端点。

我们可以在 Cluster 中配置以下可选功能：

- 主动健康检查（`health_checks`）
- 断路器 (`circuit_breakers`)
- 异常点检测（`outlier_detection`）
- 在处理上游的 HTTP 请求时有额外的协议选项
- 一组可选的网络过滤器，应用于所有出站连接等

和监听器的地址一样，端点地址可以是一个套接字地址，也可以是一个 Unix 域套接字。在我们的例子中，我们使用一个套接字地址，并在 `127.0.0.1:8000` 为我们的服务定义端点。一旦选择了端点，请求就会被代理到该端点的上游。

让我们看看我们定义的集群是如何与其他配置结合起来的。

```yaml
 static_resources:
   listeners:
   - name: listener_0
     address:
       socket_address:
         address: 0.0.0.0
         port_value: 10000
     filter_chains:
     - filters:
       - name: envoy.filters.network.http_connection_manager
         typed_config:
           "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
           stat_prefix: hello_world_service
           http_filters:
           - name: envoy.filters.http.router
           route_config:
             name: my_first_route
             virtual_hosts:
             - name: direct_response_service
               domains: ["*"]
               routes:
               - match:
                   prefix: "/"
                 route:
                   cluster: hello_world_service
   clusters:
   - name: hello_world_service
     connect_timeout: 5s
     load_assignment:
       cluster_name: hello_world_service
       endpoints:
       - lb_endpoints:
         - endpoint:
             address:
               socket_address:
                 address: 127.0.0.1
                 port_value: 8000
```

我们已经添加了集群配置，我们没有使用 `direct_response`，而是使用 `routes` 字段并指定集群名称。

为了尝试这种配置，让我们在 `8000` 端口启动一个 hello-world Docker 镜像。

```sh
 docker run -dit -p 8000:3000 gcr.io/tetratelabs/hello-world:1.0.0 
```

我们可以向 `127.0.0.1:8000` 发送一个请求，以检查我们是否得到 "Hello World" 的响应。

接下来，让我们把上述 Envoy 配置保存到 `envoy-clusters.yaml中`，并启动 Envoy 代理。

```sh
 func-e run -c envoy-cluster.yaml
```

当 Envoy 代理启动时，向 `0.0.0.0:10000` 发送一个请求，让 Envoy 代理请求到 hello world 端点。

```sh
 $ curl -v 0.0.0.0:10000
 ...
 > GET / HTTP/1.1
 > Host: localhost:10000
 > User-Agent: curl/7.64.0
 > Accept: */*
 >
 < HTTP/1.1 200 OK
 < date: Wed, 30 Jun 2021 23:53:47 GMT
 < content-length: 11
 < content-type: text/plain; charset=utf-8
 < x-envoy-upstream-service-time: 0
 < server: envoy
 <
 * Connection #0 to host localhost left intact
 Hello World
```

从冗长的输出中，我们会注意到由 Envoy 代理设置的响应头 `x-envoy-upstream-service-time` 和 `server: envoy`。

##### HTTP 连接管理器（HCM）介绍

HCM 是一个网络级的过滤器，将原始字节转译成 HTTP 级别的消息和事件（例如，收到的 Header，收到的 Body 数据等）。

HCM 过滤器还处理标准的 HTTP 功能。它支持访问记录、请求 ID 生成和跟踪、Header 操作、路由表管理和统计等功能。

从协议的角度来看，HCM 原生支持 HTTP/1.1、WebSockets、HTTP/2 和 HTTP/3。

Envoy 代理被设计成一个 HTTP/2 复用代理，这体现在描述 Envoy 组件的术语中。

###### **HTTP/2 术语**

在 HTTP/2 中，流是已建立的连接中的字节的双向流动。每个流可以携带一个或多个**消息（message）**。消息是一个完整的**帧（frame）**序列，映射到一个 HTTP 请求或响应消息。最后，帧是 HTTP/2 中最小的通信单位。每个帧都包含一个**帧头（frame header）**，它至少可以识别该帧所属的流。帧可以携带有关 HTTP Header、消息有效载荷等信息。

无论流来自哪个连接（HTTP/1.1、HTTP/2 或 HTTP/3），Envoy 都使用一个叫做 **编解码 API（codec PAI）** 的功能，将不同的线程协议翻译成流、请求、响应等协议无关模型。协议无关的模型意味着大多数 Envoy 代码不需要理解每个协议的具体内容。

##### HTTP 过滤器

在 HCM 中，Envoy 支持一系列的 HTTP 过滤器。与监听器级别的过滤器不同，这些过滤器对 HTTP 级别的消息进行操作，而不知道底层协议（HTTP/1.1、HTTP/2 等）或复用能力。

有三种类型的 HTTP 过滤器。

- 解码器（Decoder）：当 HCM 对请求流的部分进行解码时调用。
- 编码器（Encoder）：当 HCM 对响应流的部分进行编码时调用。
- 解码器 / 编码器（Decoder/Encoder）：在两个路径上调用，解码和编码

像网络过滤器一样，单个的 HTTP 过滤器可以停止或继续执行后续的过滤器，并在单个请求流的范围内相互分享状态。

##### 数据共享

在高层次上，我们可以把过滤器之间的数据共享分成**静态**和**动态**。静态包含 Envoy 加载配置时的任何不可变的数据集，它被分成三个部分。

###### **1. 元数据**

Envoy 的配置，如监听器、路由或集群，都包含一个`metadata`数据字段，存储键 / 值对。元数据允许我们存储特定过滤器的配置。这些值不能改变，并在所有请求 / 连接中共享。例如，元数据值在集群中使用子集选择器时被使用。

###### **2. 类型化的元数据**

类型化元数据不需要为每个流或请求将元数据转换为类型化的类对象，而是允许过滤器为特定的键注册一个一次性的转换逻辑。来自 xDS 的元数据在配置加载时被转换为类对象，过滤器可以在运行时请求类型化的版本，而不需要每次都转换。

###### **3.HTTP 每路过滤器配置** 

与适用于所有虚拟主机的全局配置相比，我们还可以指定每个虚拟主机或路由的配置。每个路由的配置被嵌入到路由表中，可以在 `typed_per_filter_config` 字段下指定。

另一种分享数据的方式是使用**动态状态**。动态状态会在每个连接或 HTTP 流中产生，并且它可以被产生它的过滤器改变。名为 `StreamInfo` 的对象提供了一种从 map 上存储和检索类型对象的方法。

##### HTTP 路由

前面提到的路由器过滤器（`envoy.filters.http.router`）就是实现 HTTP 转发的。路由器过滤器几乎被用于所有的 HTTP 代理方案中。路由器过滤器的主要工作是查看路由表，并对请求进行相应的路由（转发和重定向）。

路由器使用传入请求的信息（例如，`host` 或 `authority` 头），并通过虚拟主机和路由规则将其与上游集群相匹配。

所有配置的 HTTP 过滤器都使用包含路由表的路由配置（`route_config`）。尽管路由表的主要消费者将是路由器过滤器，但其他过滤器如果想根据请求的目的地做出任何决定，也可以访问它。

一组**虚拟主机**构成了路由配置。每个虚拟主机都有一个逻辑名称，一组可以根据请求头被路由到它的域，以及一组指定如何匹配请求并指出下一步要做什么的路由。

Envoy 还支持路由级别的优先级路由。每个优先级都有其连接池和断路设置。目前支持的两个优先级是 DEFAULT 和 HIGH。如果我们没有明确提供优先级，则默认为 DEFAULT。

这里有一个片段，显示了一个路由配置的例子。

```yaml
 route_config:
   name: my_route_config # 用于统计的名称，与路由无关
   virtual_hosts:
   - name: bar_vhost
     domains: ["bar.io"]
     routes:
       - match:
           prefix: "/"
         route:
           priority: HIGH
           cluster: bar_io
   - name: foo_vhost
     domains: ["foo.io"]
     routes:
       - match:
           prefix: "/"
         route:
           cluster: foo_io
       - match:
           prefix: "/api"
         route:
           cluster: foo_io_api
```

当一个 HTTP 请求进来时，虚拟主机、域名和路由匹配依次发生。

1. `host`或`authority`头被匹配到每个虚拟主机的`domains`字段中指定的值。例如，如果主机头被设置为 `foo.io`，则虚拟主机 `foo_vhost` 匹配。
2. 接下来会检查匹配的虚拟主机内`routs`下的条目。如果发现匹配，就不做进一步检查，而是选择一个集群。例如，如果我们匹配了 `foo.io` 虚拟主机，并且请求前缀是 `/api`，那么集群 `foo_io_api` 就被选中。
3. 如果提供多个虚拟集群，虚拟主机中的每个虚拟集群（`virtual_clusters`）都会被检查是否匹配。如果有匹配的，就使用一个虚拟集群，而不再进行进一步的虚拟集群检查。

> 虚拟集群是一种指定针对特定端点的重组词匹配规则的方式，并明确为匹配的请求生成统计信息。

虚拟主机的顺序以及每个主机内的路由顺序都很重要。考虑下面的路由配置。

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/api"
         route:
           cluster: hello_io_api
       - match:
           prefix: "/api/v1"
         route:
           cluster: hello_io_api_v1
```

如果我们发送以下请求，哪个路由 / 集群被选中？

```sh
 curl hello.io/api/v1
```

第一个设置集群 `hello_io_api的`路由被匹配。这是因为匹配是按照前缀匹配第一个虚拟集群就匹配到了。然而，我们可能错误地期望前缀为 `/api/v1` 的路由被匹配。为了解决这个问题，我们可以调换路由的顺序，或者使用不同的匹配规则。

##### 请求匹配

###### 1. 路径匹配

我们只谈了一个使用`前缀`字段匹配前缀的匹配规则。下面的表格解释了其他支持的匹配规则。

| 规则名称          | 描述                                                         |
| ----------------- | ------------------------------------------------------------ |
| `prefix`          | 前缀必须与`path`HTTP请求的path属性值的开头相匹配。例如，前缀 `/api` 将匹配路径 `/api` 和 `/api/v1`，而不是 `/`。 |
| `path`            | 路径必须与确切的`path`HTTP请求的path属性值相匹配（没有查询字符串）。例如，路径 `/api` 将匹配路径 `/api`，但不匹配 `/api/v1` 或 `/`。 |
| `safe_regex`      | 路径必须符合指定的正则表达式。例如，正则表达式 `^/products/\d+$` 将匹配路径 `/products/123` 或 `/products/321`，但不是 `/products/hello` 或 `/api/products/123`。 |
| `connect_matcher` | 匹配器只匹配 CONNECT 请求。                                  |

默认情况下，前缀和路径匹配是大小写敏感的。要使其不区分大小写，我们可以将 `case_sensitive` 设置为 `false`。注意，这个设置不适用于 `safe_regex` 匹配。

##### 2. Header 匹配

另一种匹配请求的方法是指定一组 Header。路由器根据路由配置中所有指定的 Header 检查请求 Header。如果所有指定的头信息都存在于请求中，并且设置了相同的值，则进行匹配。

多个匹配规则可以应用于Header。

###### **范围匹配**

`range_match` 检查请求 Header 的值是否在指定的以十进制为单位的整数范围内。该值可以包括一个可选的加号或减号，后面是数字。

为了使用范围匹配，我们指定范围的开始和结束。起始值是包含的，而终止值是不包含的（`[start, end)`）。

```yaml
 - match:
     prefix: "/"
     headers:
     - name: minor_version
       range_match:
         start: 1
         end: 11
```

上述范围匹配将匹配 `minor_version` 头的值，如果它被设置为 1 到 10 之间的任何数字。

###### **存在匹配**

`present_match` 检查传入的请求中是否存在一个特定的头。

```yaml
 - match:
     prefix: "/"
     headers:
     - name: debug
       present_match: true
```

如果我们设置了`debug`头，无论头的值是多少，上面的片段都会评估为`true`。如果我们把 `present_match` 的值设为 `false`，我们就可以检查是否有 Header。

###### **字符串匹配**

`string_match` 允许我们通过前缀或后缀，使用正则表达式或检查该值是否包含一个特定的字符串，来准确匹配头的值。

```yaml
 - match:
     prefix: "/"
     headers:
     # 头部`regex_match`匹配所提供的正则表达式
     - name: regex_match
       string_match:
         safe_regex_match:
           google_re2: {}
           regex: "^v\\d+$"
     # Header `exact_match`包含值`hello`。
     - name: exact_match
       string_match:
         exact:"hello"
     # 头部`prefix_match`以`api`开头。
     - name: prefix_match
       string_match:
         prefix:"api"
     # 头部`后缀_match`以`_1`结束
     - name: suffix_match
       string_match:
         suffix: "_1"
     # 头部`contains_match`包含值 "debug"
     - name: contains_match
       string_match:
         contains: "debug"
```

###### **反转匹配**

如果我们设置了 `invert_match`，匹配结果就会反转。

```yaml
 - match:
     prefix: "/"
     headers:
     - name: version
       range_match: 
         start: 1
         end: 6
       invert_match: true
```

上面的片段将检查 `version` 头中的值是否在 1 和 5 之间；然而，由于我们添加了 `invert_match` 字段，它反转了结果，检查头中的值是否超出了这个范围。

`invert_match` 可以被其他匹配器使用。例如：

```yaml
 - match:
     prefix: "/"
     headers:
     - name: env
       contains_match: "test"
       invert_match: true
```

上面的片段将检查 `env` 头的值是否包含字符串`test`。如果我们设置了 `env` 头，并且它不包括字符串`test`，那么整个匹配的评估结果为真。

##### 3. 查询参数匹配

使用 `query_parameters` 字段，我们可以指定路由应该匹配的 URL 查询的参数。过滤器将检查来自`path`头的查询字符串，并将其与所提供的参数进行比较。

如果有一个以上的查询参数被指定，它们必须与规则相匹配，才能评估为真。

请考虑以下例子。

```yaml
 - match:
     prefix: "/"
     query_parameters:
     - name: env
       present_match: true
```

如果有一个名为 `env` 的查询参数被设置，上面的片段将评估为真。它没有说任何关于该值的事情。它只是检查它是否存在。例如，使用上述匹配器，下面的请求将被评估为真。

```sh
 GET /hello?env=test
```

我们还可以使用字符串匹配器来检查查询参数的值。下表列出了字符串匹配的不同规则。

| 规则名称     | 描述                                     |
| ------------ | ---------------------------------------- |
| `exact`      | 必须与查询参数的精确值相匹配。           |
| `prefix`     | 前缀必须符合查询参数值的开头。           |
| `suffix`     | 后缀必须符合查询参数值的结尾。           |
| `safe_regex` | 查询参数值必须符合指定的正则表达式。     |
| `contains`   | 检查查询参数值是否包含一个特定的字符串。 |

除了上述规则外，我们还可以使用 `ignore_case` 字段来指示精确、前缀或后缀匹配是否应该区分大小写。如果设置为 "true"，匹配就不区分大小写。

下面是另一个使用前缀规则进行不区分大小写的查询参数匹配的例子。

```yaml
 - match:
     prefix: "/"
     query_parameters:
     - name: env
       string_match:
         prefix: "env_"
         ignore_case: true
```

如果有一个名为 `env` 的查询参数，其值以 `env_`开头，则上述内容将评估为真。例如，`env_staging` 和 `ENV_prod` 评估为真。

##### 4. gRPC 和 TLS 匹配器

我们可以在路由上配置另外两个匹配器：gRPC 路由匹配器（`grpc`）和 TLS 上下文匹配器（`tls_context`）。

gRPC 匹配器将只在 gRPC 请求上匹配。路由器检查内容类型头的 `application/grpc` 和其他 `application/grpc+` 值，以确定该请求是否是 gRPC 请求。

例如：

```yaml
 - match:
     prefix: "/"
     grpc: {}
```

> 注意 gRPC 匹配器没有任何选项。

如果请求是 gRPC 请求，上面的片段将匹配路由。

同样，如果指定了 TLS 匹配器，它将根据提供的选项来匹配 TLS 上下文。在 `tls_context` 字段中，我们可以定义两个布尔值——presented 和 validated。`presented`字段检查证书是否被出示。`validated`字段检查证书是否被验证。

例如：

```yaml
 - match:
     prefix: "/"
     tls_context:
       presented: true
       validated: true
```

如果一个证书既被出示又被验证，上述匹配评估为真。

##### 流量分割

Envoy 支持在同一虚拟主机内将流量分割到不同的路由。我们可以在两个或多个上游集群之间分割流量。

有两种不同的方法。第一种是使用运行时对象中指定的百分比，第二种是使用加权集群。

###### 使用运行时的百分比进行流量分割

使用运行时对象的百分比很适合于金丝雀发布或渐进式交付的场景。在这种情况下，我们想把流量从一个上游集群逐渐转移到另一个。

实现这一目标的方法是提供一个 `runtime_fraction` 配置。让我们用一个例子来解释使用运行时百分比的流量分割是如何进行的。

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
           runtime_fraction:
             default_value:
               numerator: 90
               denominator: HUNDRED
         route:
           cluster: hello_v1
       - match:
           prefix: "/"
         route:
           cluster: hello_v2
```

上述配置声明了两个版本的 hello 服务：`hello_v1` 和 `hello_v2`。

在第一个匹配中，我们通过指定分子（`90`）和分母（`HUNDRED`）来配置 `runtime_fraction` 字段。Envoy 使用分子和分母来计算最终的分数值。在这种情况下，最终值是 90%（`90/100 = 0.9 = 90%`）。

Envoy 在 `[0，分母]` 范围内生成一个随机数（例如，在我们的案例中是 [0，100]）。如果随机数小于分子值，路由器就会匹配该路由，并将流量发送到我们案例中的集群 `hello_v1`。

如果随机数大于分子值，Envoy 继续评估其余的匹配条件。由于我们有第二条路由的精确前缀匹配，所以它是匹配的，Envoy 会将流量发送到集群 `hello_v2`。一旦我们把分子值设为 0，所有随机数会大于分子值。因此，所有流量都会流向第二条路由。

我们也可以在运行时键中设置分子值。例如：

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
           runtime_fraction:
             default_value:
               numerator: 0
               denominator: HUNDRED
             runtime_key: routing.hello_io
         route:
           cluster: hello_v1
       - match:
           prefix: "/"
         route:
           cluster: hello_v2
 ...
 layered_runtime:
   layers:
   - name: static_layer
     static_layer:
       routing.hello_io: 90
```

在这个例子中，我们指定了一个名为 `routing.hello_io` 的运行时键。我们可以在配置中的分层运行时字段下设置该键的值——这也可以从文件或通过运行时发现服务（RTDS）动态读取和更新。为了简单起见，我们在配置文件中直接设置。

当 Envoy 这次进行匹配时，它将看到提供了`runtime_key`，并将使用该值而不是分子值。有了运行时键，我们就不必在配置中硬编码这个值了，我们可以让 Envoy 从一个单独的文件或 RTDS 中读取它。

当你有两个集群时，使用运行时百分比的方法效果很好。但是，当你想把流量分到两个以上的集群，或者你正在运行 A/B 测试或多变量测试方案时，它就会变得复杂。

###### 使用加权集群进行流量分割

当你在两个或多个版本的服务之间分割流量时，加权集群的方法是理想的。在这种方法中，我们为多个上游集群分配了不同的权重。而带运行时百分比的方法使用了许多路由，我们只需要为加权集群提供一条路由。

我们将在下一个模块中进一步讨论上游集群。为了解释用加权集群进行的流量分割，我们可以把上游集群看成是流量可以被发送到的终端的集合。

我们在路由内指定多个加权集群（`weighted_clusters`），而不是设置一个集群（`cluster）`。

继续前面的例子，我们可以这样重写配置，以代替使用加权集群。

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
         route:
           weighted_clusters:
             clusters:
               - name: hello_v1
                 weight: 90
               - name: hello_v2
                 weight: 10
```

在加权的集群下，我们也可以设置 `runtime_key_prefix`，它将从运行时键前缀配置中读取权重。注意，如果没有设置运行时键前缀值，Envoy 会使用每个集群配置的权重。

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
         route:
           weighted_clusters:
             runtime_key_prefix: routing.hello_io
             clusters:
               - name: hello_v1
                 weight: 90
               - name: hello_v2
                 weight: 10
 ...
 layered_runtime:
   layers:
   - name: static_layer
     static_layer:
       routing.hello_io.hello_v1: 90
       routing.hello_io.hello_v2: 10
```

权重代表 Envoy 发送给上游集群的流量的百分比。所有权重的总和必须是 100。然而，使用 `total_weight` 字段，我们可以控制所有权重之和必须等于的值。例如，下面的片段将 `total_weight` 设置为 15。

```yaml
 route_config:
   virtual_hosts:
   - name: hello_vhost
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
         route:
           weighted_clusters:
             runtime_key_prefix: routing.hello_io
             total_weight: 15
             clusters:
               - name: hello_v1
                 weight: 5
               - name: hello_v2
                 weight: 5
               - name: hello_v3
                 weight: 5
```

为了动态地控制权重，我们可以设置 `runtime_key_prefix`。路由器使用运行时密钥前缀值来构建与每个集群相关的运行时密钥。如果我们提供了运行时密钥前缀，路由器将检查 `runtime_key_prefix + "." + cluster_name` 的值，其中 `cluster_name` 表示集群数组中的条目（例如 `hello_v1`、`hello_v2`）。如果 Envoy 没有找到运行时密钥，它将使用配置中指定的值作为默认值。

##### Header 操作

HCM 支持在加权集群、路由、虚拟主机或全局配置层面操纵请求和响应头。

注意，我们不能直接从配置中修改所有的 Header（使用 Wasm 扩展的情况除外）。然后，我们可以修改 `:authority` header，例如下面的情况。

不可变的头是伪头（前缀为`:`，如`:scheme`）和`host`头。此外，诸如 `:path`和 `:authority` 这样的头信息可以通过 `prefix_rewrite`、`regex_rewrite` 和  `host_rewrite` 配置来间接修改。

Envoy 按照以下顺序对请求 / 响应应用这些头信息：

1. 加权的集群级头信息
2. 路由级 Header
3. 虚拟主机级 Header
4. 全局级 Header

这个顺序意味着 Envoy 可能会用更高层次（路由、虚拟主机或全局）配置的头来覆盖加权集群层次上设置的 Header。

在每一级，我们可以设置以下字段来添加或删除请求、响应头。

- `response_headers_to_add`：要添加到响应中的 Header 信息数组。
- `response_headers_to_remove`：要从响应中移除的 Header 信息数组。
- `request_headers_to_add`：要添加到请求中的 Header 信息数组。
- `request_headers_to_remove`：要从请求中删除的 Header 信息数组。

除了硬编码来设置请求、响应头的值之外，我们还可以使用变量来为请求、响应头添加动态值。变量名称以百分数符号（%）为分隔符。支持的变量名称包括 `%DOWNSTREAM_REMOTE_ADDRESS%`、`%UPSTREAM_REMOTE_ADDRESS%`、`%START_TIME%`、`%RESPONSE_FLAGS%` 和更多。你可以在[这里](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_conn_man/headers#custom-request-response-headers)找到完整的变量列表。

让我们看一个例子，它显示了如何在不同级别的请求 、响应中添加或删除头信息。

```yaml
 route_config:
   response_headers_to_add:
     - header: 
         key: "header_1"
         value: "some_value"
       # 如果为真（默认），它会将该值附加到现有值上。
       # 否则它将替换现有的值
       append: false
   response_headers_to_remove: "header_we_dont_need"
   virtual_hosts:
   - name: hello_vhost
     request_headers_to_add:
       - header: 
           key: "v_host_header"
           value: "from_v_host"
     domains: ["hello.io"]
     routes:
       - match:
           prefix: "/"
         route:
           cluster: hello
         response_headers_to_add:
           - header: 
               key: "route_header"
               value: "%DOWNSTREAM_REMOTE_ADDRESS%"
       - match:
           prefix: "/api"
         route:
           cluster: hello_api
         response_headers_to_add:
           - header: 
               key: "api_route_header"
               value: "api-value"
           - header:
               key: "header_1"
               value: "this_will_be_overwritten"
```

###### 标准 Header

Envoy 在收到请求（解码）和向上游集群发送请求（编码）时，会操作一组头信息。当使用裸露的 Envoy 配置将流量路由到单个集群时，在编码过程中会设置以下头信息。

```
 ':authority', 'localhost:10000'
 ':path', '/'
 ':method', 'GET'
 ':scheme', 'http'
 'user-agent', 'curl/7.64.0'
 'accept', '*/*'
 'x-forwarded-proto', 'http'
 'x-request-id', '14f0ac76-128d-4954-ad76-823c3544197e'
 'x-envoy-expected-rq-timeout-ms', '15000'
```

在编码（响应）时，会发送一组不同的头信息。

```
 ':status', '200'
 'x-powered-by', 'Express'
 'content-type', 'text/html; charset=utf-8'
 'content-length', '563'
 'etag', 'W/"233-b+4UpNDbOtHFiEpLMsDEDK7iTeI"'
 'date', 'Fri, 16 Jul 2021 21:59:52 GMT'
 'x-envoy-upstream-service-time', '2'
 'server', 'envoy'
```

下表解释了 Envoy 在解码或编码过程中设置的不同头信息。

| Header                           | 描述                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| `:scheme`                        | 设置并提供给过滤器，并转发到上游。(对于 HTTP/1，`:scheme` 头是由绝对 URL 或 `x-forwaded-proto` 头值设置的) 。 |
| `user-agent`                     | 通常由客户端设置，但在启用 `add_user_agent`时可以修改（仅当 Header 尚未设置时）。该值由 `--service-cluster`命令行选项决定。 |
| `x-forwarded-proto`              | 标准头，用于识别客户端用于连接到代理的协议。该值为 `http` 或 `https`。 |
| `x-request-id`                   | Envoy 用来唯一地识别一个请求，也用于访问记录和跟踪。         |
| `x-envoy-expected-rq-timeout-ms` | 指定路由器期望请求完成的时间，单位是毫秒。这是从 `x-envoy-upstream-rq-timeout-ms` 头值中读取的（假设设置了 `respect_expected_rq_timeout`）或从路由超时设置中读取（默认为 15 秒）。 |
| `x-envoy-upstream-service-time`  | 端点处理请求所花费的时间，以毫秒为单位，以及 Envoy 和上游主机之间的网络延迟。 |
| `server`                         | 设置为 `server_name` 字段中指定的值（默认为 `envoy`）。      |

根据不同的场景，Envoy 会设置或消费一系列其他头信息。当我们在课程的其余部分讨论这些场景和功能时，我们会引出不同的头信息。

###### Header 清理

Header 清理是一个出于安全原因添加、删除或修改请求 Header 的过程。有一些头信息，Envoy 有可能会进行清理。

| Header                                     | 描述                                                         |
| ------------------------------------------ | ------------------------------------------------------------ |
| `x-envoy-decorator-operation`              | 覆盖由追踪机制产生的任何本地定义的跨度名称。                 |
| `x-envoy-downstream-service-cluster`       | 包含调用者的服务集群（对于外部请求则删除）。由 `-service-cluster` 命令行选项决定，要求 `user_agent` 设置为 `true`。 |
| `x-envoy-downstream-service-node`          | 和前面的头一样，数值由 `--service--node`选项决定。           |
| `x-envoy-expected-rq-timeout-ms`           | 指定路由器期望请求完成的时间，单位是毫秒。这是从 `x-envoy-upstream-rq-timeout-ms` 头值中读取的（假设设置了 `respect_expected_rq_timeout`）或从路由超时设置中读取（默认为 15 秒）。 |
| `x-envoy-external-address`                 | 受信任的客户端地址（关于如何确定，详见下面的 XFF）。         |
| `x-envoy-force-trace`                      | 强制收集的追踪。                                             |
| `x-envoy-internal`                         | 如果请求是内部的，则设置为 "true"（关于如何确定的细节，见下面的 XFF）。 |
| `x-envoy-ip-tags`                          | 如果外部地址在 IP 标签中被定义，由 HTTP IP 标签过滤器设置。  |
| `x-envoy-max-retries`                      | 如果配置了重试策略，重试的最大次数。                         |
| `x-envoy-retry-grpc-on`                    | 对特定 gRPC 状态代码的失败请求进行重试。                     |
| `x-envoy-retry-on`                         | 指定重试策略。                                               |
| `x-envoy-upstream-alt-stat-name`           | Emist 上游响应代码 / 时间统计到一个双统计树。                |
| `x-envoy-upstream-rq-per-try-timeout-ms`   | 设置路由请求的每次尝试超时。                                 |
| `x-envoy-upstream-rq-timeout-alt-response` | 如果存在，在请求超时的情况下设置一个 204 响应代码（而不是 504）。 |
| `x-envoy-upstream-rq-timeout-ms`           | 覆盖路由配置超时。                                           |
| `x-forwarded-client-certif`                | 表示一个请求流经的所有客户端 / 代理中的部分证书信息。        |
| `x-forwarded-for`                          | 表示 IP 地址请求通过了。更多细节见下面的 XFF。               |
| `x-forwarded-proto`                        | 设置来源协议（`http` 或 `https）`。                          |
| `x-request-id`                             | Envoy 用来唯一地识别一个请求。也用于访问日志和追踪。         |

是否对某个特定的头进行清理，取决于请求来自哪里。Envoy 通过查看 `x-forwarded-for` 头（XFF）和 `internal_address_config` 设置来确定请求是外部还是内部。

## XFF

XFF 或 `x-forwaded-for` 头表示请求在从客户端到服务器的途中所经过的 IP 地址。下游和上游服务之间的代理在代理请求之前将最近的客户的 IP 地址附加到 XFF 列表中。

Envoy 不会自动将 IP 地址附加到 XFF 中。只有当 `use_remote_address`（默认为 false）被设置为 true，并且 `skip_xff_append` 被设置为 false 时，Envoy 才会追加该地址。

当 `use_remote_address` 被设置为 true 时，HCM 在确定来源是内部还是外部以及修改头信息时，会使用客户端连接的真实远程地址。这个值控制 Envoy 如何确定**可信的客户端地址**。

**可信的客户端地址**

可信的客户端地址是已知的第一个准确的源 IP 地址。向 Envoy 代理发出请求的下游节点的源 IP 地址被认为是正确的。

请注意，完整的 XFF 有时不能被信任，因为恶意的代理可以伪造它。然而，如果一个受信任的代理将最后一个地址放在 XFF 中，那么它就可以被信任。例如，如果我们看一下请求路径 `IP1 -> IP2 -> IP3 -> Envoy`，`IP3` 是 Envoy 会认为信任的节点。

Envoy 支持通过 `original_ip_detection_extensions` 字段设置的扩展，以帮助确定原始 IP 地址。目前，有两个扩展：`custom_header` 和 `xff`。

通过自定义头的扩展，我们可以提供一个包含原始下游远程地址的头名称。此外，我们还可以告诉 HCM 将检测到的地址视为可信地址。

通过 `xff` 扩展，我们可以指定从 `x-forwarded-for` 头的右侧开始的额外代理跳数来信任。如果我们将这个值设置为 `1` 还使用上面的例子，受信任的地址将是 `IP2` 和 `IP3`。

Envoy 使用可信的客户端地址来确定请求是内部还是外部。如果我们把 `use_remote_address` 设置为 `true`，那么如果请求不包含 XFF，并且直接下游节点与 Envoy 的连接有一个内部源地址，那么就认为是内部请求。Envoy 使用 [RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) 或 [RFC4193](https://datatracker.ietf.org/doc/html/rfc4193) 来确定内部源地址。

如果我们把 `use_remote_address` 设置为 `false`（默认值），只有当 XFF 包含上述两个 RFC 定义的单一内部源地址时，请求才是内部的。

让我们看一个简单的例子，把 `use_remote_address` 设为 `true`，`skip_xff_append` 设为 `false`。

```yaml
 ...
 - filters:
   - name: envoy.filters.network.http_connection_manager
     typed_config:
       "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
       use_remote_address: true
       skip_xff_append: false
       ...
```

如果我们从同一台机器向代理发送一个请求（即内部请求），发送到上游的头信息将是这样的。

```
 ':authority', 'localhost:10000'
 ':path', '/'
 ':method', 'GET'
 ':scheme', 'http'
 'user-agent', 'curl/7.64.0'
 'accept', '*/*'
 'x-forwarded-for', '10.128.0.17'
 'x-forwarded-proto', 'http'
 'x-envoy-internal', 'true'
 'x-request-id', '74513723-9bbd-4959-965a-861e2162555b'
 'x-envoy-expected-rq-timeout-ms', '15000'
```

这些 Header 中的大部分与我们在标准 Header 例子中看到的相同。然而，增加了两个头——`x-forwarded-for` 和 `x-envoy-internal`。`x-forwarded-for` 将包含内部 IP 地址，而 `x-envoy-internal` 头将被设置，因为我们用 XFF 来确定地址。我们不是通过解析 `x-forwarded-for` 头来确定请求是否是内部的，而是检查 `x-envoy-internal` 头的存在，以快速确定请求是内部还是外部的。

如果我们从该网络之外发送一个请求，即客户端和 Envoy 不在同一个节点上，以下头信息会被发送到 Envoy。

```
 ':authority', '35.224.50.133:10000'
 ':path', '/'
 ':method', 'GET'
 ':scheme', 'http'
 'user-agent', 'curl/7.64.1'
 'accept', '*/*'
 'x-forwarded-for', '50.35.69.235'
 'x-forwarded-proto', 'http'
 'x-envoy-external-address', '50.35.69.235'
 'x-request-id', 'dc93fd48-1233-4220-9146-eac52435cdf2'
 'x-envoy-expected-rq-timeout-ms', '15000'
```

注意 `:authority` 的值是一个实际的 IP 地址，而不只是 `localhost`。同样地，`x-forwarded-for` 头包含了被调用的 IP 地址。没有 `x-envoy-internal` 头，因为这个请求是外部的。然而，我们确实得到了一个新的头，叫做 `x-envoy-external-address`。Envoy 只为外部请求设置这个头。这个头可以在内部服务之间转发，并用于基于源客户端 IP 地址的分析。