# Kubernetes学习

Kubernetes是一个开源的，用于管理云平台中多个主机上的容器化的应用，Kubernetes的目标是让部署容器化的应用简单且高效，Kubernetes提供了应用部署、规划、更新，维护的一种机制。Kubernetes具有的特点：自我修复、弹性伸缩、自动部署和回滚、服务发现和负载均衡、机密和配置管理、存储编排，批处理。企业级容器调度平台：Apache Mesos、Docker Swarm、Google Kubernetes。目前的趋势是Kubernetes一同天下。Apache Mesos发布的最早，早期没有针对容器来进行开发，主要还是针对节点即物理服务器或虚拟机来进行调度，但是也支持容器调度；Docker Swarm是Docker官方开发的容器调度平台，但是没有得到广泛的支持，后期各大云平台都不再提供对Docker Swarm的支持；最后就是一家独大的Kubernetes，K8S是目前最主流的企业级调度平台，各大云平台都支持K8S。



### Kubernetes结构和组件

Kubernetes源自于Goodgle内部的容器调度平台Borg，Borg的平台架构是由主从节点组成，主节点主要接受外部请求，管理Borg集群的配置信息等功能，而Kubernetes的架构继承自Borg，也分为主、从节点，在K8S的主节点主要承担管理调度功能，从节点主要是运行各个pod来启动容器，从节点没有管理功能，但是主节点可以通过配置运行pod，官方建议最小启动一主一从，官网的结构图如下：

![kubernetes-cluster-architecture](../image/kubernetes-cluster-architecture.svg)

在Kubernetes中API server是一个处理所有Kubernetes中操作的关键组件，通过API server才能真正地调用某个应用。比如K8S的命令都是调用API server去执行相关命令，也可以使用可视化界面去调用API server执行相关命令。Kubernetes主要使用kubectl命令行工具和dashboard可视化界面来调用K8S的API，其实就是访问的kube-api-server。

1. ##### 控制面板组件

   - kube-api-server：基于RESTful API开放的K8S接口服务，是所有外部调用的入口；
   - kube-controller-manager：管理各个类型的控制器，每个控制器都是一个单独的进程，但是为了降低复杂性，它们都被编译到同一个可执行文件，并在同一个进程中运行，控制器主要包括：节点控制器，任务控制器，端点分片控制器，服务账号控制器等，这些控制器针对K8S中的各种资源进行管理；
   - cloud-controller-manager：云控制管理器，主要对第三方云平台提供K8S管理功能；
   - kube-scheduler：K8S调度器负责将pod基于一定的算法，将其调度到更合适的节点(服务器)上；
   - etcd：可以把etcd看成一个键值对的分布式数据库，提供了基于Raft算法实现自主的集群高可用，最新版本支持持久化存储。

2. ##### 节点组件

   - kubelet：负责Pod 生命周期的管理包含CPU、存储、网络等；
   - kube-proxy：网络代理，负责Service的服务发现、负载均衡等；
   - container-runtime：容器的运行时环境：docker、containerd、CRI-O；
   - pod：真正运行容器的地方，一个pod中最少运行一个容器。

3. ##### 附加组件

   - kube-dns：为整个集群提供DNS服务；
   - Ingress Controller：为服务提供外网入口；
   - Prometheus：提供资源监控；
   - Dashboard：可视化控制台；
   - Federation：提供跨可用区的集群；
   - Fluentd-elasticsearch：提供收集、存储与查询。



### Kubernetes中的概念和专业术语

1. 服务的分类：有状态会对本地环境产生依赖，例如需要存储数据到本地磁盘(Redis)与无状态不会对本地环境产生任何依赖，例如不会存储数据到本地磁盘(Nginx);

2. 资源和对象：在K8S里面一切皆资源，对象就是基于资源创建出来的实例，是持久化实体，比如某个具体的pod、某个具体的node；

3. 对象的规约和状态：spec是必须的，它描述了对象的期望状态(Desired State)，对象状态是对象的实际状态，该属性由K8S自己维护，K8S会通过一些列控制器对对象进行管理，让对象的状态尽可能与期望状态重合；

4. 元数据型资源(所有的资源都可以访问元数据的数据)：
   - Horizontal Pod Autoscaler(HPA)：Pod自动扩容，可以根据定义的指标自动对Pod进行扩容/缩容；
   - PodTemplate：是关于Pod定义，但是被包含在其他的K8S对象中(例如 Deployment、StatefulSet、DaemonSet等控制器)。控制器通过Pod Template信息来创建Pod；
   - LimitRange：可以对集群内的request和limits的配置做一个全局的统一的限制，相当于批量设置了某一个范围内的Pod的资源使用限制；
   
5. 集群级资源(集群中的所有资源都可以共享使用)：
   - Namespace：指级群内的逻辑分区；
   - Node：Node本质上不是Kubernetes来创建的，Kubernetes只是管理Node上的资源；
   - ClusterRole：用于集群资源上的角色管理；
   - ClusterRoleBinding：将角色绑定到集群资源对象；
   
6. 命名空间级资源(命名空间范围内可以使用)：
   - Pod：容器组是Kubernetes中最小的可部署单元，一个Pod(容器组)包含了一个应用程序容器(某些情况下是多个容器)、存储资源、一个唯一的网络IP地址、以及一些确定容器该如何运行的选项。Pod容器组代替了Kubernetes中一个独立的应用程序运行实例，该实例可能由单个容器或者几个紧耦合在一起的容器组成。一般来说一个Pod只运行一个容器。因此，可以认为Pod容器组是该容器的Wrapper，Kubernetes通过Pod管理容器，而不是直接管理容器；
   - Replicas：一个Pod可以被复制成多份，每一个复制都称为一个副本，这些副本除了一些描述性的信息不一样以外，其它信息都是一样的，譬如Pod内部容器、容器数量、容器里面运行的应用等；
   - Replication controller：RC是Kubernetes系统中的核心概念之一，简单来说，RC可以保证在任意时间运行Pod的副本数量，能够保证Pod总是可用的。如果实际Pod数量比指定的多那就结束掉多余的，如果实际数量比指定的少就启动一些Pod，当Pod失败、被删除或者挂掉后，RC都会去自动创建新的Pod来保证副本数量，所以即使只有一个Pod，我们也应该使用RC来管理我们的Pod。可以说，通过ReplicationController，Kubernetes实现了Pod的高可用；
   - ReplicaSet：帮助我们动态更新Pod的副本数，可以通过selector来选择对哪些Pod生效，只支持扩容和缩容Pod；
   - Deployment：针对RS的更高层次的封装，提供了更丰富的部署相关的功能，自动创建RS和Pod，然后通过滚动升级然后回滚，可以实现平滑的扩容和缩容，暂停和恢复；
   - StatefulSet：专门针对于有状态服务进行部署。主要特定有稳定的持久化存储，稳定的网络状态，有序部署有序拓展，有序收缩有序删除。组成部分主要有 1. Headless Service: 是K8S的DNS服务，它将服务名和IP进行映射和解析；在statefulSet中每个pod的DNS格式为：statefulsetname.{0, n-1}.servicename.namespace.svc.cluster.local，statefulesetname就是statefulSet的名字，后面接着{0, n-1}是statefulSet中pod的顺序，servciename是Headless Service的名字，namespace是pod所在的命名空间，cluster.local是服务的Domain。2. VolumeChaimTemplate：用于创建持久化卷的模板；
   - DeamonSet：为每个匹配的Node上都运行一个守护进程，常用来部署一些集群日志、日志或其他系统管理应用；
   - Job：一次性任务，执行完后销毁pod，而且不会重新启动新容器；
   - Cronjob：定时任务，在job基础之上增加的定时运行，间隔运行功能；
   - Service：K8S内部跨节点和pod与pod之间的通信；
   - Ingress：K8S把内部暴露给外部访问的服务；
   - Volume：存储卷，用来共享pod中的数据，可以持久化pod中的数据；
   - CSI(Container Storage Interface)：是由Mesos、Swarm、Kubernetes和开源社区制定的一个统一的行业接口规范，旨在将任何存储系统暴露给容器应用；
   - ConfigMap：键值对的配置信息，可以将pod的配置信息存放在configMap中，修改configMap中的配置参数就可以修改Pod中的配置参数；
   - Secret：其作用跟configMap一样，只是多了加密功能；
   - DownwardAPI：提供了两种方式将Pod的信息注入到容器内部，1.环境变量，可以将Pod的信息和容器的信息直接注入到容器内部；2.volume挂载：将Pod的信息生成文件，直接挂载到容器中去；
   - Role：用于定义namespace上的角色管理；
   - RoleBinding：将角色绑定到namespace对象上；
   - Spec：是“规约”，它是必须要的，它描述了资源对象的一种期望状态；
   - Status：表示资源对象的实际状态，该属性由K8S自己维护，K8S通过一些列控制器尽可能的控制资源对象进行管理，使其尽可能的达到期望状态。
   
   

### Kubernetes实战

1. ##### 常用的kubectl命令

`kubectl create`：  创建资源对象命令，-f选项后可以跟yaml文件创建yaml文件描述的资源对象，也可跟文件目录创建文件下的所有资源对象，还可以跟url使用http请求来返回yaml文件创建资源对象；

`kubectl get`：查找资源对象，后面可以跟pods、services各种资源对象；

`kubectl describe`：描述K8S中的各种资源对象，该命令可以返回资源对象的详细描述；

`kubectl edit`：可以编辑K8S资源的yaml文件；

`kubectl delete pod,service baz foo `：删除K8S中的资源对象

`kubectl logs my-pod`：输出某个Pod对象的log

`kubectl run -i --tty busybox --image=busybox -- sh`：交互式 shell 的方式运行 pod；

`kubectl attach my-pod -i`：连接到运行中的容器；

`kubectl port-forward my-pod 5000:6000 `：转发 pod 中的 6000 端口到本地的 5000 端口；

`kubectl exec my-pod -- ls /`：在已存在的容器中执行命令（只有一个容器的情况下）；

`kubectl cordon my-node `：标记 my-node 不可调度；

`kubectl uncordon my-node`：标记 my-node 可调度；

`kubectl drain my-node `：清空 my-node 以待维护；

`kubectl top node my-node `：显示 my-node 的指标度量；

`kubectl cluster-info `：显示 master 和服务的地址；



一个简单的Pod的yaml文件示例如下：

```yaml
apiVersion: v1 # api 文档版本
kind: Pod  # 资源对象类型，也可以配置为像Deployment、StatefulSet这一类的对象
metadata: # Pod 相关的元数据，用于描述 Pod 的数据
  name: nginx-demo # Pod 的名称
  labels: # 定义 Pod 的标签
    type: app # 自定义 label 标签，名字为 type，值为 app
    test: 1.0.0 # 自定义 label 标签，描述 Pod 版本号
  namespace: 'default' # 命名空间的配置
spec: # 期望 Pod 按照这里面的描述进行创建
  containers: # 对于 Pod 中的容器描述
  - name: nginx # 容器的名称
    image: nginx:1.7.9 # 指定容器的镜像
    imagePullPolicy: IfNotPresent # 镜像拉取策略，指定如果本地有就用本地的，如果没有就拉取远程的
    command: # 指定容器启动时执行的命令
    - nginx
    - -g
    - 'daemon off;' # nginx -g 'daemon off;'
    workingDir: /usr/share/nginx/html # 定义容器启动后的工作目录
    ports:
    - name: http # 端口名称
      containerPort: 80 # 描述容器内要暴露什么端口
      protocol: TCP # 描述该端口是基于哪种协议通信的
    env: # 环境变量
    - name: JVM_OPTS # 环境变量名称
      value: '-Xms128m -Xmx128m' # 环境变量的值
    reousrces:
      requests: # 最少需要多少资源
        cpu: 100m # 限制 cpu 最少使用 0.1 个核心
        memory: 128Mi # 限制内存最少使用 128兆
      limits: # 最多可以用多少资源
        cpu: 200m # 限制 cpu 最多使用 0.2 个核心
        memory: 256Mi # 限制 最多使用 256兆
  restartPolicy: OnFailure # 重启策略，只有失败的情况才会重启
```



2. ##### Pod深入理解

Pod的探针机制是指容器内应用的监测机制，根据不同的探针来判断容器里应用的当前状态，Pod的探针支持三种检测方式：ExecAction(在容器内部执行一个命令，如果返回值为 0，则任务容器时健康的)、TCPSocketAction(通过 tcp 连接监测容器内端口是否开放，如果开放则证明该容器健康)、HTTPGetAction(生产环境用的较多的方式，发送 HTTP 请求到容器内的应用程序，如果接口返回的状态码在 200~400 之间，则认为容器健康)。Pod支持三种探针：

1. StartupProbe：当配置了 startupProbe 后，会先禁用其他探针，直到 startupProbe 成功后，其他探针才会继续。由于有时候不能准确预估应用一定是多长时间启动成功，因此配置另外两种方式不方便配置初始化时长来检测，而配置了 statupProbe 后，只有在应用启动成功了，才会执行另外两种探针，可以更加方便的结合使用另外两种探针使用。
2. LivenessProbe：用于探测容器中的应用是否运行，如果探测失败，kubelet 会根据配置的重启策略进行重启，若没有配置，默认就认为容器启动成功，不会执行重启策略。
3. ReadinessProbe：用于探测容器内的程序是否健康，它的返回值如果返回 success，那么就认为该容器已经完全启动，并且该容器是可以接收外部流量的。

