### 使用CentOS安装镜像设置本地源

###### 1.将CentOS安装镜像挂载到本地路径（两种方式）

首先建立挂载点 `mkdir /mnt/centos_dvd`

①. 挂载光盘 `mount -t iso9660 /dev/cdrom /mnt/centos_dvd`  
②. 使用loop挂载本地镜像文件 `mount -o loop /tmp/CentOS-7-x86_64-DVD-1611.iso /mnt/centos_dvd`

###### 2.修改yum配置文件

进入repository定义目录 `cd /etc/yum.repo.d`  
 
修改CentOS-Media.repo在baseurl中添加/mnt/centos_dvd（即光盘挂载点）并将enabled=0改为1。

###### 3.禁用默认的yum网络源

将yum网络源配置文件改名为CentOS-Base.repo.bak，否则会先在网络源中寻找适合的包，改名之后直接从本地源读取。


###### 4.清理缓存并生成新的缓存

清除缓存：`yum clean all`  
生成缓存：`yum makecache`