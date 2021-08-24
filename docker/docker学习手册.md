### docker学习手册

###### 1. MacOS和window安装docker方式说明

1. mac中Docker Engine不是安装在macOS里的，而是安装在一个虚拟机中，使用如下方式登入。所有的外部volume挂载点都在这个虚拟机中。
```
stty -echo -icanon && nc -U ~/Library/Containers/com.docker.docker/Data/debug-shell.sock && stty sane # ls -al /var/lib/docker/overlay2/
```

2. window中的Docker Engine安装在一个wsl的Linux子系统中，可以在文件浏览器中输入`\\$wsl`查看，其中有两个linux子系统一个是docker-desktop，Windows的Docker Engine就安装在这个linux子系统中，另一个子系统是docker-desktop-data，docker中的镜像、volumes都是存储这个子系统中。可以使用wsl的命令进入docker-desktop但其实里面没什么，我想这个子系统提供了docker运行的系统内核吧。

##### 2. docker的基本命令
```
docker [container] create #创建一个新的容器
docker [container] start #启动一个新的容器
docker [container] run #创建并启动一个容器 例如： docker run -it ubuntu:18.04 /bin/bash 其中，-t选项让Docker分配一个伪终端(pseudo-tty)并绑定到容器的标准输入上，-i则让容器的标准输入保持打开。 更多的时候，需要让Docker容器在后台以守护态(Daemonized)形式运行。此时，可以通过添加-d参数来实现。
docker [container] logs #查看容器输出
docker [container] pause #暂停容器
docker [container] unpause #恢复容器到运行状态
docker [container] stop #终止容器
docker [container] restart #重启容器
docker [container] exec 在运行中容器内直接执行任意命令
>> * -d, --detach: 在容器中后台执行命令；
>> * --detach-keys="": 指定将容器切回后台的按钮；
>> * -e, --env=[]: 指定环境变量列表；
>> * -i, --interactive=true|false: 打开标准输入接受用户输入命令，默认值为false;
>> * --privileged=true|false: 是否给执行命令以最高权限，默认值为false;
>> * -t, --tty=true|false: 分配伪终端，默认值为false；
>> * -u, --user="": 执行命令的用户名或ID
```

###### 2. 启动elasticsearch 6.8.18的命令
```
docker run -d --name elasticsearch_6.8.18 -p 9200:9200 -p 9300:9300 -v elasticsearch_6.8.18_data:/usr/share/elasticsearch/data -v elasticsearch_6.8.18_config:/usr/share/elasticsearch/config -v elasticsearch_6.8.18_plugins:/usr/share/elasticsearch/plugins elasticsearch:6.8.18
```thethethethethe