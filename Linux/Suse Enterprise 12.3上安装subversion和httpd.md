### SUSE12 + Apache + svn服务器 安装过程

##### 安装包
* httpd-2.4.25.tar.gz : apache http安装包
* zlib-1.2.11.tar.gz
* apr-util-1.5.4.tar.gz
* apr-1.5.2.tar.gz
* subversion-1.9.5.tar.gz ： apache subversion安装包
* pcre-8.40.tar.gz

##### 安装过程和安装参数

1. gcc和gcc+
```
mkdir /mnt/iso
mount -o loop /home/download/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso /mnt/iso
zypper ar /mnt/iso suse12sp3iso
zypper install gcc-c++
zypper install gcc
```


2. zlib
```
cd /home/download/
tar -xzvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install
```

3. apr
```
cd /home/download/
tar -xzvf apr-1.5.2.tar.gz
cd apr-1.5.2
./configure --prefix=/usr/local/apr
make
make install
```

4. apr-util
```
cd /home/download/
tar -xzvf apr-util-1.5.4.tar.gz
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make
make install
```

5. pcre
```
cd /home/download/
tar -xzvf pcre-8.40.tar.gz
cd pcre-8.40/
./configure
make
make install
```

6. apache httpd
```
cd /home/download/
tar -xzvf httpd-2.4.25.tar.gz
cd httpd-2.4.25
./configure --prefix=/opt/apache --enable-modules=all --enable-mods-shared=all --enable-proxy --enable-proxy-connect --enable-proxy-ftp --enable-proxy-http --enable-proxy-ajp --enable-proxy-balancer --enable-rewrite --enable-status --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-pcre=/opt/pcre --enable-dav --enable-so --enable-maintainer-mode
make
make install
```
这一长串的参数，都是吐血试出来的，网上各种找啊。SUSE12的资料基本没有，参考各种LINUX版本的资料试出来的。

7. svn
```
cd /home/download/  
tar -xzvf subversion-1.9.5.tar.gz  
unzip sqlite-amalgamation-3071501.zip  
mv sqlite-amalgamation-3071501/ subversion-1.9.5/sqlite-amalgamation  
cd subversion-1.9.5  
./configure --prefix=/usr/local/subversion --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-apxs=/opt/apache/bin/apxs --with-zlib --enable-maintainer-mode  
make  
make install 
```

##### 配置apache
`vim /opt/apache/conf/httpd.conf`
在httpd.conf文件的末尾加上：
```
<location /svn> utl的访问路径
DAV svn
SVNParentPath /home/svnbase/ SVN的父文件目录
AuthType Basic
AuthName "Hello welcome to XXXX svn"
AuthUserFile /home/svnbase/.passwd  http认证文件
AuthzSVNAccessFile /home/svnbase/auth.conf  svn授权文件
Require valid-user
</location>
```

找到LoadModule加上：
```
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so
```

拷贝so文件，到/opt/apache/modules/目录下，确认有没有`mod_dav_svn.so`和`mod_authz_svn.so`这两个文件。
如果没有，用`find / -name mod_dav_svn.so`去找，找到后拷贝到/opt/apache/modules/目录下  

生成http认证文件`/opt/apache/bin/htpasswd -bc /home/svnbase/.passwd user1 pwd11`；编辑权限文件`vim /home/svnbase/auth.conf`
```
[groups]
Admin=user1
[/]
user1 = rw
```

##### 启动apache服务
```
/opt/apache/bin/apachectl start
/opt/apache/bin/apachectl stop
/opt/apache/bin/apachectl restart
```

##### SVN的备份机制
1. svnadmin hotcopy: 此方法只能进行全量备份，不能进行增量备份，优点是备份较快，灾难恢复也很快，如果备份机
上已经搭建了SVN服务，只需要一些简单的配置即可切换到备机上。缺点是备份时间比较长，耗费的备份硬盘空间比较大。备
份命令为：
`svnadmin hotcopy 目标SVN版本库路径 热拷贝版本库路径`
这个命令会制作一个版本库的完整热拷贝，包括所有的钩子、配置文件，当然还有数据库文件。

2. svnadmin dump: 该方法为subversion官网推荐方式，优点是比较灵活，既可以进行全量备份又可以进行增量备份，
并提供了版本恢复机制。缺点是如果版本库过大，如版本数增加到数万、数十万条时，则dump的过程很慢，备份耗时，恢复时
更耗时，不利于块速进行灾难恢复，此方法建议在版本库较小的情况下采用。
* 全量备份： `svnadmin dump 版本库路径 > 备份版本库存放的路径`
* 增量备份： `svnadmin dump -r 上次备份的版本号：到本次备份到的版本号 --incremental > 导出的版本库存放路径`

3. svnsync方式备份: svnsync是Subversion的一个远程版本库镜像工具，它允许把一个版本库的内容录入到另一个。
在任何镜像场景中，有两个版本库：源版本库，镜像(或“sink”)版本库。源版本库就是svnsync获取修订版本的库，镜像
版本库就是源版本库修订版本的目标，两个版本库可以是在本地或远程，它们只是通过URL跟踪。此方法同样只能进行全量
备份，它实际上是制作了两个镜像库，当一个坏了的时候可以迅速切换到另一个，它必须是1.4版本以上才支持此功能。优点是
当制作成两个镜像库的时候可以起到双机实时备份的作用。

##### SVN镜像库的配置过程
1. 增加主备版本库配置文件，新建master版本库`svnadmin create master`。在主机~/repo/bbip/hooks/目录下
增加配置文件`cp pre-revprop-change.templ pre-revprop-change`，添加配置文件运行权限
`chmod a+x pre-revprop-change`。修改pre-revprop-change 文件内容：将最后一行内容修改为`exit 0`。

2. 主备版本库同步初始化：`svnsync init svn://备份版本库地址/master/ svn://主版本库地址/master/`
3. 主备版本库同步：`svnsync sync svn://备份版本库地址/master/`
4. 自动同步配置：在主版本库工程hooks目录下增加配置文件实现自动同步`cp post-commit.templ post-commit`
修改post-commit文件，增加
```
export LANG="en_US.UTF-8"
( /usr/local/subversion/bin/svnsync sync svn://备份版本库地址/master --source-username 主库用户名 --source-password 主库用户密码  --sync-username 目标库用户名  --sync-password 目标库用户密码  --no-auth-cache & ) 
exit 0
```
将以前文件里的三行注销：
```
#REPOS="$1"
#REV="$2"
#mailer.py commit "$REPOS" "$REV" /path/to/mailer.conf
```