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

`kubectl label po my-pod app=hello`：临时创建 label；

`kubectl label po my-pod app=hello2 --overwrite`：修改已经存在的标签；

`kubectl get po -A -l app=hello`：查找label为app=hello的Pod；

`kubectl get po --show-labels`：查看所有Pod的label；



2. ##### Pod深入理解

一个简单的Pod的yaml文件示例如下：

```yaml
apiVersion: v1 # api 文档版本
kind: Pod  # 资源对象类型，也可以配置为像Deployment、StatefulSet这一类的对象
metadata: # Pod 相关的元数据，用于描述 Pod 的数据
  name: nginx-po # Pod 的名称
  labels: # 定义 Pod 的标签
    type: app # 自定义 label 标签，名字为 type，值为 app
    test: 1.0.0 # 自定义 label 标签，描述 Pod 版本号
  namespace: 'default' # 命名空间的配置
spec: # 期望 Pod 按照这里面的描述进行创建
  containers: # 对于 Pod 中的容器描述
  - name: nginx # 容器的名称
    image: nginx:1.25.3 # 指定容器的镜像
    imagePullPolicy: IfNotPresent # 镜像拉取策略，指定如果本地有就用本地的，如果没有就拉取远程的
    startupProbe:
      httpGet:
        path: /test
        port: 80
      timeoutSeconds: 5 # 超时时间
      periodSeconds: 10 # 监测间隔时间
      successThreshold: 1 # 检查 1 次成功就表示成功
      failureThreshold: 3 # 监测失败 2 次就表示失败
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
    resources:
      requests: # 最少需要多少资源
        cpu: 100m # 限制 cpu 最少使用 0.1 个核心
        memory: 128Mi # 限制内存最少使用 128兆
      limits: # 最多可以用多少资源
        cpu: 200m # 限制 cpu 最多使用 0.2 个核心
        memory: 256Mi # 限制 最多使用 256兆
  restartPolicy: OnFailure # 重启策略，只有失败的情况才会重启
```



Pod的探针机制是指容器内应用的监测机制，根据不同的探针来判断容器里应用的当前状态，Pod的探针支持三种检测方式：ExecAction(在容器内部执行一个命令，如果返回值为 0，则任务容器时健康的)、TCPSocketAction(通过 tcp 连接监测容器内端口是否开放，如果开放则证明该容器健康)、HTTPGetAction(生产环境用的较多的方式，发送 HTTP 请求到容器内的应用程序，如果接口返回的状态码在 200~400 之间，则认为容器健康)。Pod支持三种探针：

1. StartupProbe：当配置了 startupProbe 后，会先禁用其他探针，直到 startupProbe 成功后，其他探针才会继续。由于有时候不能准确预估应用一定是多长时间启动成功，因此配置另外两种方式不方便配置初始化时长来检测，而配置了 statupProbe 后，只有在应用启动成功了，才会执行另外两种探针，可以更加方便的结合使用另外两种探针使用。
2. LivenessProbe：用于探测容器中的应用是否运行，如果探测失败，kubelet 会根据配置的重启策略进行重启，若没有配置，默认就认为容器启动成功，不会执行重启策略。该探针会在Pod启动后一直运行，知道整个生命周期结束。
3. ReadinessProbe：用于探测容器内的程序是否健康，它的返回值如果返回 success，那么就认为该容器已经完全启动，并且该容器是可以接收外部流量的。该探针会在Pod启动后一直运行，知道整个生命周期结束。

Pod的生命周期，当Kubernetes API Server收到create请求后就开始了一个Pod的生命周期，前期是一些准备Pod运行阶段，包括一些image下载，环境配置的准备，pause底层容器的创建。当准备阶段完成后，就正式进入Pod的启动阶段，可以为pod配置一个或多个init container来初始化Pod，之后就是postStart钩子函数运行阶段，但是需要注意的是command命令和postStart钩子函数不存在先后顺序，所以一般初始化工作都使用init container来完成，当postStart执行结束后就开始了前面讲的StartupProbe、LivenessProbe和ReadinessProbe探针的运行，之后就是Pod容器的运行阶段。最后在Pod生命周期结束之前还有一个preStop的钩子函数来执行一些清理工作，需要注意的是执行时间必须小于terminationGracePeriodSeconds，该配置是Pod变为删除中的状态后，会给 pod 一个宽限期，让 pod 去执行一些清理或销毁操作，可以根据具体的清理工作来设置该配置的值。

3. ##### Deployment深入理解

Deployment是对Pod的高级抽象，是对ReplicaSet更高层次的封装，提供了滚动更新、回滚、扩容缩容和暂停与恢复等功能，我们先来看看一个Deployment的yaml文件：

```yaml
apiVersion: apps/v1 # deployment api 版本
kind: Deployment # 资源类型为 deployment
metadata: # 元信息
  labels: # 标签
    app: nginx-deploy # 具体的 key: value 配置形式
  name: nginx-deploy # deployment 的名字
  namespace: default # 所在的命名空间
spec:
  replicas: 1 # 期望副本数
  revisionHistoryLimit: 10 # 进行滚动更新后，保留的历史版本数
  selector: # 选择器，用于找到匹配的 RS
    matchLabels: # 按照标签匹配
      app: nginx-deploy # 匹配的标签key/value
  strategy: # 更新策略
    rollingUpdate: # 滚动更新配置
      maxSurge: 25% # 进行滚动更新时，更新的个数最多可以超过期望副本数的个数/比例
      maxUnavailable: 25% # 进行滚动更新时，最大不可用比例更新比例，表示在所有副本数中，最多可以有多少个不更新成功
    type: RollingUpdate # 更新类型，采用滚动更新
  template: # pod 模板
    metadata: # pod 的元信息
      labels: # pod 的标签
        app: nginx-deploy
    spec: # pod 期望信息
      containers: # pod 的容器
      - image: nginx:1.9.1 # 镜像
        imagePullPolicy: IfNotPresent # 拉取策略
        name: nginx # 容器名称
      restartPolicy: Always # 重启策略
      terminationGracePeriodSeconds: 30 # 删除操作最多宽限多长时间

```

只有修改了 deployment 配置文件中的 template 中的属性后，才会触发更新操作。使用`kubectl set image deployment/nginx-deploy nginx=nginx:1.25.3`可以修改单个属性或者通过 `kubectl edit deployment/nginx-deploy`对整个yaml配置文件进行修改。查看滚动更新的结果可以使用命令`kubectl rollout status deploy nginx-deploy`，最后使用`kubectl describe deploy <deployment_name>`展示发生的事件列表也可以看到滚动更新过程，通过 `kubectl get deployments `获取部署信息，UP-TO-DATE 表示已经有多少副本达到了配置中要求的数目，通过 `kubectl get rs`可以看到增加了一个新的ReplicaSet，通过 `kubectl get pods`可以看到所有pod关联的ReplicaSet变成了新的。

有时候你可能想回退一个Deployment，当Deployment不稳定时，比如一直crash looping。默认情况下，kubernetes会在系统中保存前两次的Deployment的rollout历史记录，以便你可以随时会退(你可以修改revision history limit来更改保存的revision数)。我们来看一个案例：更新 deployment 时参数不小心写错，如使用`kubectl set image deployment/nginx-deploy nginx=nginx:1.91`将nginx:1.9.1写成了nginx:1.91，监控滚动升级状态，由于镜像名称错误，下载镜像失败，因此更新过程会卡住。使用`kubectl rollout status deployments nginx-deploy`来查看rollout的状态，使用`kubectl get rs`来查看ReplicaSet，会发现有问题的ReplicaSet。使用`kubectl get pods`获取 pods 信息，我们可以看到关联到新的ReplicaSet的pod，状态处于 ImagePullBackOff 状态为了修复这个问题，我们需要找到需要回退的revision进行回退，使用`kubectl rollout history deployment/nginx-deploy`可以获取revison的列表使用`kubectl rollout history deployment/nginx-deploy --revision=2`可以查看详细信息，确认要回退的版本后，可以通过`kubectl rollout undo deployment/nginx-deploy`可以回退到上一个版本，也可以使用`kubectl rollout undo deployment/nginx-deploy --to-revision=2`回退到指定的revision，再次通过`kubectl get deployment`和`kubectl describe deployment`可以看到，我们的版本已经回退到对应的 revison 上了，可以通过设置 .spec.revisonHistoryLimit 来指定 deployment 保留多少 revison，如果设置为 0，则不允许 deployment 回退了。

通过`kube scale`命令可以进行自动扩容/缩容，以及通过`kube edit`编辑replcas属性也可以实现扩容/缩容，扩容与缩容只是直接创建副本数，没有更新pod template因此不会创建新的ReplicaSet。

由于每次对pod template中的信息发生修改后，都会触发更新deployment操作，那么此时如果频繁修改信息，就会产生多次更新，而实际上只需要执行最后一次更新即可，当出现此类情况时我们就可以暂停deployment的rollout。使用`kubectl rollout pause deployment <name> `就可以实现暂停，直到你下次恢复后才会继续进行滚动更新，尝试对容器进行修改，然后查看是否发生更新操作了
使用`kubectl set image deploy <name> nginx=nginx:1.17.9`命名修改image属性，然后使用`kubectl get po`来查看Pod。通过以上操作可以看到实际并没有发生修改，此时我们再次进行修改一些属性，使用`kubectl set resources deploy <deploy_name> -c <container_name> --limits=cpu=200m,memory=128Mi --requests=cpu100m,memory=64Mi`限制 nginx 容器的最大cpu为0.2核，最大内存为128M，最小内存为64M，最小cpu为0.1核，通过格式化输出`kubectl get deploy <name> -o yaml`，可以看到配置确实发生了修改，再使用`kubectl get po`可以看到 pod 没有被更新。那么此时我们再恢复 rollout，通过命令`kubectl rollout deploy <name>`，恢复后，我们再次查看ReplicaSet和Pod信息，我们可以看到就开始进行滚动更新操作了。

4. ##### 深入理解StatefulSet

对于有状态的服务我们需要保存服务的状态信息，比如网络、数据等信息，所以K8S给我们提供了一个StatefulSet的部署方式，可以在Pod删除、更新、重启后还能还原之前的状态信息。我们先来看一看StatefulSet的yaml文件：

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet # StatefulSet资源
metadata:
  name: web
spec:
  serviceName: "nginx" # 使用service来管理DNS
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.9.1
        ports:
        - containerPort: 80 # 容器内部暴露的端口
          name: web # 该端口配置的名字
        volumeMounts: # 加载数据卷
        - name: www #加载数据卷的名字
          mountPath: /usr/share/nginx/html #加载到容器内的路劲
  volumeClaimTemplates: # 数据卷模板
  - metadata: # 数据卷的描述
      name: www # 数据卷的名字
      annotations: # 数据卷的注解信息
        volume.alpha.kubernetes.io/storage-class: anything
    spec: # 数据卷的规约配置
      accessModes: [ "ReadWriteOnce" ] # 数据卷的访问模式
      resources:
        requests:
          storage: 1Gi # 数据卷的最小容量

```

StatefulSet中没有ReplicaSet的概念，它直接对Pod进行更新、扩容和缩容。可以使用上面的yaml文件来进行StatefulSet的操作，使用`kubectl create -f web.yaml`来创建StatefulSet。使用`kubectl get service nginx`和`kubectl get statefulset web`来查看 service 和 statefulset => sts，使用`kubectl get pvc`来查看 PVC 信息，使用`kubectl get pods -l app=nginx`来查看创建的 pod，StatefulSet中创建的pod是有序的，如果想查看具体的DNS信息可以运行一个pod，使用`kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh`基础镜像为busybox工具包，利用里面的nslookup可以看到dns信息，进入容器后运行`nslookup web-0.nginx`来查看DNS的路由信息。

StatefulSet的扩容和缩容命令：`kubectl scale statefulset web --replicas=5`或者`kubectl patch statefulset web -p '{"spec":{"replicas":3}}'`

StatefulSet 也可以采用滚动更新策略，同样是修改pod template属性后会触发更新，但是由于pod是有序的，在StatefulSet中更新时是基于pod的顺序倒序更新的。利用滚动更新中的partition属性，可以实现简易的灰度发布的效果。例如我们有 5 个pod，如果当partition 设置为3，那么此时滚动更新时，只会更新那些序号>= 3的pod利用该机制，我们可以通过控制partition的值，来决定只更新其中一部分pod，确认没有问题后再主键增大更新的pod数量，最终实现全部pod更新。StatefulSet还支持OnDelete更新策略，只有在pod被删除时会进行更新操作。

由于StatefulSet创建时会涉及到多个资源，所以删除StatefulSet时也需要将创建的资源一并删除，首先StatefulSet和Pod可以级联删除，但是Headless Service和Volume需要指定删除，默认StatefulSet和Pod是级联删除的使用删除命令`kubectl delete statefulset web`删除 statefulset 时会同时删除 pods，如果不想级联删除可以使用--cascade=false参数指定。StatefulSet删除后PVC还会保留着，数据不再使用的话也需要删除，使用`kubectl delete pvc www-web-0 www-web-1`来删除对应的PVC。

5. ##### 深入理解DaemonSet

DaemonSet与之前讨论的Deployment和StatefulSet都不一样，DaemonSet是针对Node来创建Pod的，也就是说DaemonSet选择器会找个匹配的Node来为每个Node创建Pod。其主要用于日志收集，服务监控等应用。我们来看看一个简单的日志收集的DaemonSet的yaml文件：

```yaml
apiVersion: apps/v1
kind: DaemonSet # 创建DaemonSet资源
metadata:
  name: fluentd # DaemonSet的名字
spec:
  selector:
    matchLables:
      app: logging
  template:
    metadata:
      labels: # label的配置
        app: logging
        id: fluentd
      name: fluentd # Pod的名字
    spec:
      containers:
      - name: fluentd-es # 容器的名字
        image: agilestacks/fluentd-elasticsearch:v1.3.0 # 指定容器的image
        env: # 环境变量
         - name: FLUENTD_ARGS
           value: -qq
        volumeMounts: # 加载数据卷，避免数据丢失
         - name: containers # 数据卷名字
           mountPath: /var/lib/docker/containers # 将数据卷挂载到的路径
         - name: varlog
           mountPath: /varlog
      volumes: # 定义数据卷的类型
         - hostPath: # 数据卷类型，主机路劲的模式，与Node主机共享目录
             path: /var/lib/docker/containers # Node中的共享目录
           name: containers # 定义数据卷的名称
         - hostPath:
             path: /var/log
           name: varlog

```

DaemonSet会忽略Node的unschedulable状态，有两种方式来指定Pod只运行在指定的Node节点上：

- nodeSelector：只调度到匹配指定label的Node上；
- nodeAffinity：功能更丰富的Node选择器，比如支持集合操作；
- podAffinity：调度到满足条件的Pod所在的Node上。

6. ##### HPA深入理解

通过观察Pod的CPU、内存使用率或自定义metrics进行自动的扩容或缩容pod的数量。通常用于Deployment，不适用于无法扩/缩容的对象，如DaemonSet。控制管理器每隔30s(可以通过–horizontal-pod-autoscaler-sync-period修改)查询metrics的资源使用情况。

实现CPU或内存的监控，首先有个前提条件是该对象必须配置了resources.requests.cpu或resources.requests.memory才可以，可以配置当CPU/memory 达到上述配置的百分比后进行扩容或缩容。创建一个 HPA：

1. 先准备好一个有做资源限制的deployment；
2. 执行命令`kubectl autoscale deploy nginx-deploy --cpu-percent=20 --min=2 --max=5`
3. 通过`kubectl get hpa`可以获取 HPA 信息

测试：找到对应服务的 service，编写循环测试脚本提升内存与CPU负载`while true; do wget -q -O- http://<ip:port> > /dev/null ; done`，可以通过多台机器执行上述命令，增加负载，当超过负载后可以查看Pod的扩容情况。使用`kubectl top pods`查看pods 资源使用情况，扩容测试完成后，再关闭循环执行的指令，让CPU占用率降下来，然后过5分钟后查看自动缩容情况。

7. ##### Service深入理解

Service主要负责Node内部容器之间的网络访问，其主要的原理是当新建Service后会使用selector来查询相关联的Pod，同时创建一个同名的endpoint来记录着所有selector选择器查询结果的Pod的IP地址，这个IP寻址是通过每个Node的Proxy来完成的，当配置完成后，Pod之间的访问将通过PodA => Service => Endpoint => Porxy => PodB来完成。一个简单的Service的yaml文件：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    app: nginx-svc
spec:
  ports:
  - name: http # service端口配置的名称
    protocol: TCP # 端口绑定的协议，支持 TCP、UDP、SCTP，默认为 TCP
    port: 80 # service自己的端口
    targetPort: 9527 # 目标pod的端口
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  selector: # 选中当前service匹配哪些pod，对哪些pod的东西流量进行代理
    app: nginx

```


使用`kubectl get svc` 查看Service信息，通过Service的cluster ip进行访问，使用`kubectl get po -o wide`查看Pod信息，通过Pod的IP进行访问，创建其他Pod通过Service Name进行访问(推荐)。测试可以使用busybox来访问service name使用`kubectl exec -it busybox -- sh`进入容器后使用`curl http://nginx-svc`来访问Pod服务。默认在当前 namespace 中访问，如果需要跨Namespace 访问Pod，则在Service Name 后面加上 .<namespace> 即可，可以使用`curl http://nginx-svc.default`来访问带Namespace的服务。

8. ##### Ingress深入理解





