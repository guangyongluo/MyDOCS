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

###### 基本常规命令
```
#查看当前用户可以操作的数据库
show database;
#查看当前数据库的所有表
show tables;
#查看表结构
desc ***
#查看当前使用的数据库
select database();
```

###### 创建用户、赋予权限和创建角色
所有用户信息及权限都存在mysql.user表中。可以直接通过修改mysql.user表来创建用户并赋予权限。一般不直接操作mysql.user表，使
用mysql提供的内置命令来创建及管理MySQL用户，可以使用GRANT、REVOKE、SET PASSWORD或RENAME USER等用户管理语句简介修改mysql.
user表，并立即再次将所有修改的信息加载到内存，而直接修改mysql.user表不会影响权限检查，除非你重新启动服务器或指示其重新加
载表。可以通过FLUSH PRIVILEGES语句来重新加载表。常用的命令如下：
```
#创建用户
create user if not exists '***'@'***' identified with mysql_native_password by '***';
#删除用户
drop user '***'@'***';
#赋予权限给用户
grant select on ***.*** to '***'@'***';
#撤销权限
revoke delete on ***.*** from '***'@'***';
```
MySQL的角色是个一个权限的集合。创建一个角色后赋予权限给角色后指定用户角色就不再需要为用户配置单一的权限了,命令如下；
```
#创建角色
create role '***';
#为角色赋权限
grant select on ***.*** to '***';
#为用户指定角色
grant '***' to '***'@'***';
```

###### 查询数据并保存文件
将输出结果保存到文件中，所需要的是FILE权限。FILE是一个全局权限，它不仅仅针对某个数据库，但是可以通过限制用户读权限来控制FILE
权限导出数据的范围。首先，应该设置secure_file_priv并重启数据库。通过使用命令`show global variables like '%secure%';`来查
看当前数据库的设置。一般Linux默认设置为`/var/lib/mysql-files`。使用如下命令导出数据文件和从数据文件中导入数据到MySQL数据库
```
#导出数据文件
select * into outfile ***.csv fields terminated by ',' optionally enclosed by '"' lines terminated by '\n'
from *
where *;
#从文件中加载数据
load data infile xxx.csv into table *** fields terminated by ',' optionally enclosed by '"' lines terminated by '\n';
```
> 谈谈插入数据到数据库中两个重要的关键字的含义（replace\ignore）:如果导入的行不存在，则直接插入新行。
> replace:如果该行已经存在，则使用新数据更新以前的数据，使用主键来判定行是否存在；
> ignore:如果该行已经存在，则使用新数据被忽略，使用主键来判定行是否存在；

###### 配置MySQL
MySQL三种配置方法：
* 配置文件:MySQL有一个配置文件，可以指定数据位置、MySQL使用的内存大小等各种参数
* 启动脚本:可以直接将参数传递给mysqld进程。启动脚本仅在调用服务器时才有效。
* 使用set命令:这个命令只能修改动态变量，改动将在下次重启后失效。
默认的MySQL配置文件在/etc/my.cnf或者/etc/mysql/my.cnf，这个文件主要由以下几个部分组成：
* [mysqld]:该部分由mysql命令行客户端读取；
* [client]:该部分由所有连接的客户端读取(包括mysql, cli)；
* [mysqldump]:该部分由mysql服务器读取；
* [mysql_safe]:该部分由名为mysqldump的备份工具读取；
* [server]:该部分由mysqld_safe进程读取(MySQL服务器启动脚本)。
MySQL有两种类型的参数
* 静态参数:重启MySQL服务器后才能生效。
* 动态参数:可以在不重启MySQL服务器的情况下更改及时生效。
使用全局变量和回话变量，你可以通过连接到MySQL并执行set命令来设置参数
* 全局变量:适用于所有新的连接，只有在初始化连接时，将复制所有全局变量作为初始参数给这个连接的会话，也就是说设置全局变量对新开启的会话有效；
设置全局变量的方法如下:
```
#使用set设置全局变量
set global ***='***';
set @@global.***='***';
#Mysql8还新增了一个方法设置全局变量然后持久化,该设置当数据库重启后使用该命令设置的全局变量将保存在mysqld-auto.cnf文件中用于新建连接初始化
set persist ***=***;
#参看全局变量
show global variables like '%***%';
```
* 会话变量:仅适用于当前连接,设置会话变量的方法如下:
```
#使用set设置会话变量，设置会话变量只会影响当前会话
set session ***='***';
set @@session.***='***';
#参看会话变量
show variables like '%***%';
```
MySQL配置参数
* datadir:设置数据目录，由MySQL服务器管理的数据存储在名为数据目录的目录下。
* innodb_buffer_pool_size:决定InnoDB存储引擎可以使用多少内存空间来缓存内存中的数据和索引。
* innodb_buffer_pool_instances:可以将InnoDB缓冲池划分为不同的区域，以便在不同线程读取和写入缓存页面时减少挣用，从而提高并发性。
* innodb_log_file_size:重做日志空间的大小，用于数据库崩溃时重放已提交的事务。

###### MySQL的锁
* 内部锁: MySQL在自身服务器内部执行内部锁，以管理多个会话对表内容的挣用
1. 行级锁: 行级锁是细粒度的。只有被访问的行会被锁定。这允许通过多个会话同事进行写访问，使其使用与多用户、高并发和OLTP的应用。只有InnoDB支持行级锁。
2. 表级锁: MySQL对MyISAM、MEMORY和MERGE表使用表级锁，一次只允许一个会话更新这些表。这种锁定级别使得这些存储引擎更适用于只读的或以读取操作为主的或
单用户的应用程序。
* 外部锁: 可以使用LOCK TABLE和UNLOCK TABLES语句来控制锁定
1. READ: 当一个表被锁定为READ时，多个会话可以从表中读取数据而不需要获取锁。此外，多个会话可以在同一个表上获得锁，这就是为什么READ锁也被称为共享锁
。当READ锁被保持时，没有会话可以将数据写入表格中(包括持有该锁的会话)。如果有任何写入尝试，该操作将处于等待状态，直到READ锁被释放。
2. WRITE: 当一个表被锁定为WRITE时，除持有该锁的会话之外，其他任何会话都不能读取或向表中写入数据。除非现有锁被释放，否则其他任何会话都不能获得任何
锁。这就是为什么WRITE锁被称为排他锁。如果有任何读取、写入尝试，该操作将处于等待状态，直到WRITE锁被释放。

###### MySQL二进制日志
二进制日志包含数据库的所有更改记录，包含数据和结构两方面。二进制日志不记录SELECT或SHOW等不修改数据的操作。运行带有二进制日志的服务器会带来轻微的性
能影响。二进制日志能保证数据库出故障时数据是安全的。只要安全的事件或事物会被记录或回读。

* 复制: 使用二进制日志，可以把对服务器所有的更改以流形式方式传输到另一台服务器上，从(slave)服务器充当镜像副本，也可以用于分配负载。接受写入的服务器
称为主(master)服务器。
* 时间点恢复: 假设你在星期日的00:00进行了备份，而数据库在星期日的08:00出现故障。使用备份可以恢复到周日00:00的状态;而使用二进制日志可以恢复到周日
08:00的状态。

启用二进制日志功能：
```
#修改my.cnf配置文件
vi /etc/my.cnf
log_bin = /pah/serverl
server_id = 100
#如果有错误请查看错误日志log-error启动日志
#重启MySQL服务
systemctl restart mysql
#查看二进制日志配置信息
show variables like 'log_bin%';
#显示所有的二进制日志
show master logs;
#显示当前二进制位置
show master status;
#当前会话禁用二进制日志
set sql_log_bin = 0;
#当前会话开启二进制日志
set sql_log_bin = 1;
```

###### 二进制日志的格式
二进制日志可以写成下面三种格式:
1. STATEMENT: 记录实际的SQL语句;
2. ROW: 记录每行所做的更改;
3. MIXED: 当需要时，MySQL会从STATEMENT切换到ROW
