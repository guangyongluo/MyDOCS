### docker学习手册

##### 1. MacOS和window安装docker方式说明

1. mac中Docker Engine不是安装在macOS里的，而是安装在一个虚拟机中，使用如下方式登入。所有的外部volume挂载点都在这个虚拟机中。
```
stty -echo -icanon && nc -U ~/Library/Containers/com.docker.docker/Data/debug-shell.sock && stty sane # ls -al /var/lib/docker/overlay2/
```

2. window中的Docker Engine安装在一个wsl的Linux子系统中，可以在文件浏览器中输入`\\$wsl`查看，其中有两个linux子系统一个是docker-desktop，Windows的Docker Engine就安装在这个linux子系统中，另一个子系统是docker-desktop-data，docker中的镜像、volumes都是存储这个子系统中。可以使用wsl的命令进入docker-desktop但其实里面没什么，我想这个子系统提供了docker运行的系统内核吧。

##### 2. docker的基本命令
```
docker [image] pull NAME[:TAG] #pull命令直接从Docker Hub镜像源来下载镜像
docker images #列出本地镜像
docker [image] inspect #inspect命令查看详细信息
docker history #查看镜像历史信息
docker image rm #使用标签或ID删除镜像
docker image prune #使用Docker一段时间后，系统中可能会遗留一些临时镜像文件，以及一些没有被使用的镜像，prune命令可以进行清理
docker [image] save #导出镜像到本地文件，可以用参数-o|--output string设置本地镜像的文件名
docker [image] load #load将导出的tar文件再次导入到本地镜像库中。 -i |--input string从指定文件中读取镜像内容。
docker [image] push NAME[:TAG] user/NAME[:TAG] #上传镜像到Docker Hub官方仓库。
docker [container] create #创建一个新的容器
docker [container] start #启动一个新的容器
docker [container] run #创建并启动一个容器 例如： docker run -it ubuntu:18.04 /bin/bash 其中，-t选项让Docker分配一个伪终端(pseudo-tty)并绑定到容器的标准输入上，-i则让容器的标准输入保持打开。 更多的时候，需要让Docker容器在后台以守护态(Daemonized)形式运行。此时，可以通过添加-d参数来实现。
docker [container] logs #查看容器输出
docker [container] pause #暂停容器
docker [container] unpause #恢复容器到运行状态
docker [container] stop #终止容器
docker [container] restart #重启容器
docker [container] exec #在运行中容器内直接执行任意命令，比较重要的参数有:
    -d, --detach: #在容器中后台执行命令；
    --detach-keys="": #指定将容器切回后台的按钮；
    -e, --env=[]: #指定环境变量列表；
    -i, --interactive=true|false: #打开标准输入接受用户输入命令，默认值为false;
    --privileged=true|false: #是否给执行命令以最高权限，默认值为false;
    -t, --tty=true|false: #分配伪终端，默认值为false；
    -u, --user="": #执行命令的用户名或ID
docker [container] rm #删除容器
    -f, --force=false: #是否强行终止并删除一个运行中的容器
docker [container] export [-o|--output[=""]] CONTAINER #导出一个已经创建的容器到一个文件;
docker [container] import #导入一个export的镜像文件,这里的文件被称为容器快照，它将丢弃所有历史记录和元数据信息(即仅保存容器当时的快照状态);
docker container inspect CONTAINER #查看容器具体的信息
docker [container] top CONTAINER #查看容器内进程
docker [container] stats CONTAINER #查看统计信息
docker [container] cp CONTAINER:SRC_PATH DEST_PATH #cp命令支持在容器和主机之间复制文件
docker [container] diff CONTAINER #查看容器内系统的变更
docker container port CONTAINER #查看容器的端口映射情况
docker [container] update [options] CONTAINER #update命令可以更新容器的一些运行时配置，支持的选项包括：
    -blkio-weight uint16: #更新块IO限制，10~1000，默认值为0，代表无限制；
    -cpu-period int: #限制CPU调度器CFS(Completely Fair Scheduler)使用时间，单位为微妙，最小1000；
    -cpu-quota int: #限制CPU调度器CFS配额，单位为微妙，最小1000；
    -cpu-rt-period int: #限制CPU调度器的实时周期，单位为微妙；
    -cpu-rt-runtime int: #限制CPU调度器的实时运行时，单位为微妙；
    -c, -cpu-shares int: #限制CPU个数；
    -cpus decimal: #限制CPU个数；
    -cpuset-cpus string: #允许使用的CPU核数，如0-3，0，1；
    -cpuset-mems string: #允许使用的内存块，如0-3，0，1；
    -kernel-memory bytes: #限制使用的内核内存；
    -m, -memory bytes: #限制使用的内存；
    -memory-reservation bytes: #内存软限制；
    -memory-swap bytes: #内存加上缓存区的限制，-1表示对缓冲区无限制；
    -restart string: #容器退出后的重启策略。
```

##### 3. Docker数据管理
容器中的管理数据主要有两种方式：
* 数据卷(Data Volumes): 容器内数据直接映射到本地主机环境；
* 数据卷容器(Data Volumes Containers): 使用特定容器维护数据卷

数据卷(Data Volumes)是一个可供容器使用的特殊目录，它将主机操作系统目录直接映射进容器，类似于Linux中的mount行为。数据卷可以提供很多有用的特性:
* 数据卷可以在容器之间共享和重用，容器间传递数据将变得高效与方便；
* 对数据卷内数据的修改会立即生效，无论是容器内操作还是本地操作；
* 对数据卷的更新不会影响镜像，解耦应用与数据；
* 卷会一直存在，直到没有容器使用，可以安全地卸载它。
Docker提供了volume子命令来管理数据卷，docker volume create | inspect | ls | prune | rm 等

##### 4. Docker端口映射与容器互联
Docker除了通过网络访问外，还提供了两个很方便的功能来满足服务器访问的基本需求：一个是允许映射容器内应用的服务端口到本地宿主主机；另一个是互联网实现多个容器间通过容器名来快速访问。当容器中运行一些网络应用，要让外部访问这些应用时，可以通过-P或-p参数来指定端口映射。当使用-P标记时，Docker会随机映射一个49000~49900的端口到内部容器开放的网络端口，可以使用docker ps看到。  
容器互联(linking)是一种让多个容器中的应用进行快速交互的方式。它会在源和接收容器之间创建连接关系，接收容器可以通过容器名快速访问到源容器，而不用指定具体的IP地址。首先，需要使用--name参数来自定义一个容器的名称，这样做即可以帮助记忆容器的用途还可以在容器重启后IP地址发生变化也可以使用自定义名字访问容器。**在执行docker [container] run的时候如果添加--rm标记，则容器在终止后会立刻删除。

##### 5. Dockerfile指令说明
* ARG <name>[=<default value>] #定义创建镜像过程中使用的变量，当镜像编译成功后，ARG指定的变量将不再存在；
* FROM <image>:<tag> [AS <name>] #指定所创建镜像的基础镜像；
* LABEL <key>=<value> <key>=<value> #为生成的镜像添加元数据标签信息；
* EXPOSE <port> <port> #声明镜像内服务监听的端口，注意该指令只是起声明作用，并不会自动完成端口映射；
* ENV <key>=<value> #指定环境变量，在镜像生成过程中会被后续RUN指令使用；


```
docker run -d --name elasticsearch_6.8.18 -p 9200:9200 -p 9300:9300 -v elasticsearch_6.8.18_data:/usr/share/elasticsearch/data -v elasticsearch_6.8.18_config:/usr/share/elasticsearch/config -v elasticsearch_6.8.18_plugins:/usr/share/elasticsearch/plugins elasticsearch:6.8.18
```thethethethethe