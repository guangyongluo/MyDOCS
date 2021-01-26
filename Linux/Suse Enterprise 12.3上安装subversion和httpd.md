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