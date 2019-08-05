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

###### MySQL事务
事务的ACID：事务具有四个特性：原子性(Atomicity)、一致性(Consistency)、隔离性(Isolation)和持续性(Durability)。这四个特性简称为ACID特性。
1. 原子性：事务是数据库的逻辑工作单位，事务中包含的各操作要么做，要么都不做；
2. 一致性：事务执行的结果必须使数据库从一个一致性状态变到另一个一致性状态。因此当数据库只包含成功事务提交的结果时，就是数据库处于一致性状态。如果数据库
系统运行中发生故障，有些事务尚未完成就被迫中断，这些未完成事务对数据库所做的修改有一部分写入物理数据库，这时数据库就处于一种不正确的状态或者说不一致的状态
3. 隔离性：一个事务的执行不能干扰其他的事务，即一个事务内部的操作及使用的数据对其他并发事务时隔离的，并发执行的各个事务之间不能相互干扰。
4. 持续性：指一个事务一旦提交，它对数据库中的数据的改变就应该是永久性的，接下来的其他操作或故障不应该对其执行结果有任何影响。

###### MySQL四种隔离级别
read uncommitted: 这个级别基本不用，其允许事务读取未提交的数据；
read committed: 当前事务只能读取另一个事务提交的数据，这也称为不可重复读；
repeatable read: 一个事务通过第一条语句只能看到相同的数据，即使另一个事务已提交数据。在同一个事务中，读取通过第一次读取建立快照时一致的；
serializable: 通过把选定的所有行锁起来，序列化可以提供最高级别的隔离。序列化等待被锁的行，并且总是读取最新提交的数据。

###### MySQL主从复制工作流程细节
1. MySQL支持单项、异步复制，复制过程中一个服务器充当主服务器，而一个或多个其他服务器充当从服务器。MySQL复制基于主服务器在二进制日志中跟踪所有对数据库的更
改。因此，要进行复制，必须在主服务器上启用二进制日志。每个从服务器接收主服务器上已经记录到其二进制日志的保存更新。当一个从服务器连接主服务器时，它通知主服
务器定位到从服务器在日志中读取的最后一次成功更新位置。从服务器接收从那时起发生的任何更新，并在本机上执行相同的更新。然后封锁并等待主服务器通知新的更新。从
服务器执行备份不会干扰主服务器，在备份过程中主服务器可以继续处理更新。
2. MySQL使用3个线程来执行复制功能，其中两个线程(SQL线程和IO线程)在从服务器上，另一个线程(IO线程)在主服务器上。当发出start slave时，从服务器创建一个IO线
程，以连接服务器并让它发送记录在其二进制日志中的语句。主服务器创建一个线程将二进制日志中的内容发送到从服务器。该线程可以即为主服务器上show processlist的输
出中的binlog dump线程。从服务器IO线程读取主服务器binlog dump线程发送的内容并将数据拷贝到从服务器目录中的本地文件中，即中续日志。第三个线程SQL线程由从服务
器创建，用于读取中续日志并执行日志中包含的更新。在从服务器上，读取和执行更新语句被分成两个独立的任务。当从服务器启动时，其IO线程可以很快地从主服务器索取所有
二进制日志内容，即使SQL线程执行更新的渊源滞后。

操作过程如下:
1. 在主库上，启用二进制日志记录并设置server_id;
```
# vi /etc/mycnf
[mysqld]
log_bin=/path/serverl
server_id=***
```
2. 在主库上，创建一个复制用户;
```
grant replication slave on *.* to '***'@'%' identified by 'password';
```
3. 在从库上，设置唯一的server_id选项;
4. 在从库上，通过远程连接从主库进行备份;
```
#mysqldump :
mysqldump -h <master_host> -u backup_user --password=<pass> --all-databases --routines --events --single_transaction --master-data > dump.sql
mysql -u <user> -p -f < dump.sql
########
#mydumper :
mydumper -h <master_host> -u backup_user --password=<password> --user-savepoints --trx-consistensy-only --kill-long-queries --outputdir /tmp
myloader --directory=/tmp --user=<user> --password=<password> --queries=per-transaction=5000 --threads=8 --overwrite-tables
```
5. 在从库上，待备份完成后恢复此备份;
```
change master to master_host='<master_host>', master_user='binlog_user', master_password='binlog_user_password', master_log_file='log_file_name'
, master_log_pos=<position>
```
6. 查看复制的状态。

###### 管理表空间
* 系统表空间(共享表空间):InnoDB系统表空间包含InnoDB数据字典(与InnoDB相关的对象的元数据)，它是doublewrite buffer、change buffer和UNDO日志的存储区域。系
统表空间还包含在系统表空间中创建的表以及所有用户创建的表的索引数据。系统表空间被认为是共享的表空间，因为它由多个表共享。系统表空间用一个或多个数据文件表示
，默认情况下，将在MySQL数据目录中创建一个名为ibdata1的系统数据文件。系统数据文件的大小和数量由innodb_data_file_path启动项控制。
* 独立表空间:每个独立表空间都是一个单表表空间，它是在自己的数据文件中创建的，而不是在系统表空间中创建的。当启用innodb_file_per_table选项时，将在独立表空间
中创建表；否则将在系统表空间中创建InnoDB表。每个独立表空间由一个.ibd数据文件表示，该文件默认是在数据库目录中创建的。独立表空间支持DYNAMIC和COMPRESSED的行
格式，这些格式支持可变长度的数据和压缩的跨页存储等特性。
* 通用表空间:通用表空间使用语法create tablespace创建的共享InnoDB表空间。通用表空间可以在MySQL数据目录之外创建，可以容纳多张表，并支持所有行格式的表。
* UNDO表空间:UNDO(撤销)日志是与单个事务关联的UNDO日志记录的集合。
