### MySQL8学习手册

最近开始深入学习MySQL8的相关知识，从MySQL8的安装开始聊起，MySQL跟新到8已经很久了，MySQL8现在也是社区版本库中的默认安装版
本。MySQL一直分为商业版和社区版两个版本。其实最大的区别就是付费购买订阅后在遇见问题时Oracle官方会帮助你解决问题，本人在
Oracle的工作经验告诉我一般没什么大的问题，一些极端的问题比如软件底层的bug看你付钱的多少决定了这个问题解决的快慢，有可能
会因为工程师的能力问题随着时间的推移不了了之。

###### MySQL8安装(Version：MySQL 8.0.16、OS：SUSE Enterprise 12.3、CentOS 7.5)
1. 在SUSE 12.3上本人由于工作的原因可以找到SUSE原厂的工程师，所以在遇到依赖问题时有点办法，安装商业版所需要的rpm包为：
* mysql-commercial-server-8.0.16-2.1.sles12.x86_64.rpm
* mysql-commercial-client-8.0.16-2.1.sles12.x86_64.rpm
* mysql-commercial-common-8.0.16-2.1.sles12.x86_64.rpm
* mysql-commercial-libs-8.0.16-2.1.sles12.x86_64.rpm

在安装mysql时会遇见一个依赖问题：
```
error: Failed dependencies:
	pkgconfig(openssl) is needed by mysql-community-devel-8.0.11-1.el7.x86_64

```
2. 需要安装依赖包(从SuSE原厂工程师或得)
* libstdc++6-32bit-8.2.1+r264010-1.3.3.x86_64.rpm
* libstdc++6-8.2.1+r264010-1.3.3.x86_64.rpm

安装完上述rpm包后就是常规操作了，这个版本mysql无需初始化数据库直接查看初始化生成密码的日志文件使用该日志文件里的密码登入。
`cat /var/log/mysqld.log | grep -i "temporary password"`

3. 修改root密码：(不要使用root登入)
```
#登入mysql
mysql -uroot -p
#切换到mysql库
use mysql;
#修改root用户的登入密码
alter user 'root'@'localhost' identifier by 'new password';
```

4. 修改远程登入
```
#查看root用户可登入的主机
select host from user where user='root';
#修改root用户可登入的主机使用%通配符即所有主机都可登入
update user set host = '%' where user ='root'
#查看修改结果
select host from user where user='root';
```

5. CentOS上安装社区版的mysql8，使用Oracle官方提供的Repository安装文件，直接从Oracle官方Repository安装，需要下载
mysql80-community-release-el7-3.noarch.rpm文件安装mysql的Repository。过程非常简单，可以查看Oracle官方文档，下面记录一些
重要的命令：
```
#可以使用科大提供的CentOS镜像站点http://mirrors.ustc.edu.cn/，将CentOS的源修改成科大提供的源
#使用yum更新本机软件依赖
yum update
#安装Oracle官方提供的Mysql Repository
rpm -Uvh mysql80-community-release-el7-3.noarch.rpm
#使用yum安装社区版MySQL8
yum install mysql-community-server
```

###### 默认安装目录已经修改目录配置
以上两种安装方法默认的安装目录都是/var/lib/mysql

###### 常用命令
```
#查看当前用户可以操作的数据库
show database;
#查看当前数据库的所有表
show tables;
#查看表结构
desc ***

```



