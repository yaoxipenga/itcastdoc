# 任务背景

随着访问量不断提升, 单台mysql不断地逼近承载的负载极限。所以我们希望能用**==多台服务器==**来提供服务，这样不仅可以多台mysql数据库分担负载，而且也在一定程度上提供了冗余，可以在实现了自动备份的基础上进一步提供服务可用性。

这样多台mysql服务器架构==数据需要保持一致==,  所以我们可以选用mysql主从复制架构来实现。



![1558532693360](pictures/复制架构基础图.png)



# 任务要求

能够按需求搭建对应的主从复制架构



# 任务拆解

1, 了解集群概念与复制架构

2, 传统AB复制架构的搭建

3, 拓展其它复制架构做法与思路

3, 基于GTIDs的AB复制架构搭建

4, 半同步复制架构搭建



#学习目标

- [ ] 理解mysql的复制原理
- [ ] 了解常见的mysql复制架构
- [ ] 能够搭建传统AB复制架构
- [ ] 能够搭建基于GTIDS的AB复制架构
- [ ] 能够搭建半同步复制架构






#**一、集群介绍**

**集群(cluster)**: 指两台或多台机器共同提供一个服务或完成一个任务。通俗来说, 就是由单人工作变为团队协作。



**集群的主要类型**

- 高可用（High Availablity, 简称==HA==）    一个挂了另一个立刻顶上		
- 负载均衡（load balance, 简称==LB== )     一个大型工作，一个人顶不住，分给多个人顶  

还有高性能计算集群(这种我们不涉及), 存储集群, 缓存集群, 分布式集群, 集中式集群等。不管其它的集群叫法如何,都会包含**HA**与**LB**的思想在里面。



**常用的mysql集群架构**

- ==**MySQL Replication**==
- MySQL Cluster
- MySQL Group Replication （MGR）   5.7.17
- MariaDB Galera Cluster 
- ==MHA==,Keepalived,HeartBeat,RHCS,pacemaker,piranha,utrla monkey等HA软件帮助实现mysql高可用
- nginx, Lvs, Haproxy等帮助实现负载均衡
- mysqlproxy, mysqlrouter, amoeba, cobar, mycat等实现数据库代理等



# 二、MySQL复制与原理

**什么是MySQL复制**

mysql复制( mysql Replication): 

可以实现将数据从一台数据库服务器(master)复制到一台或多台数据库服务器(slave)



**MySQL复制原理**

master将数据库的改变写入**==二进制日志==**，slave同步这些二进制日志，并根据这些二进制日志进行**==数据重演操作==**，实现数据同步, 这种同步默认为**==单向==**, **==异步==**的.

![mysql复制原理](pictures/mysql复制原理.png)

**详细描述：**

1. slave端的IO线程发送请求给master端的binlog dump线程
2. master端binlog dump线程==获取二进制日志==信息(==文件名和位置信息==)发送给slave端的IO线程
3. salve端IO线程获取到的内容==依次==写到slave端relay log里，并把master端的bin-log文件名和位置记录到master.info里
4. salve端的SQL线程，检测到relay  log中内容更新，就会解析relay log里更新的内容，并==执行这些操作==，从而达到和master数据一致



**小结:**  

* salve的IO线程连接到master上获取复制位置,并将master的binlog依次写到slave的relay_log
* salve的SQL监视relay_log的变动,有变动就会执行它，达到和master数据一致





#三、MySQL复制架构

## AB复制（一主一从）

 ![M-S简图](pictures/M-S简图.png)

**一般情况下, master只接受写请求，slave只接受读请求实现读写分离。**



## 并联复制(一主多从)

 ![m-s-s并联复制](pictures/m-s-s并联复制.png)

**优点：**分担读压力

**缺点：**增加master的压力（传输二进制日志压力）

适合场景: 读多写少



## 级联复制

 ![m-s1-s2简图](pictures/m-s1-s2简图.png)

**优点：**分担读压力,也没有为master带来额外负载的压力

**缺点：**slave1 出现故障，后面的所有级联slave服务器都会同步失败

 就算没有出现故障,master复制到slave2的延时大大增加,会造成数据不一致。(不建议使用此架构)



## 双主复制

 ![m-m](pictures/m-m.png)

**特点：**

从命名来看，两台master好像都能接受读、写请求，但实际上，往往运作的过程中，同一时刻只有其中一台master会接受写请求，另外一台接受读请求。

(**这样做的目的是为了保证master挂掉时, slave也可以进行写操作,并且写的数据可以再复制回原来的master**)



**PS: mysql5.7版本有多主一从的复制方式**



# 四、AB复制搭建

问题1: AB复制两个mysql版本要一致吗?

答: 最好一致,甚至包括系统环境和其它环境全部都一致. 后面的devops思想也会讲到这个.  不同版本也不能绝对说不可以做集群，版本差别不大,一般也可以(但避免此情况产生)。



问题2: mysql数据库要暂新的吗?

答: 第一个实验要求是暂新的，但如果是运行了很久的数据库也可以做AB复制。





## 环境说明与准备

![1558532492460](pictures/mysqlAB复制架构图.png)

1. 两台服务器都关闭防火墙和selinux

```shell
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F

# setenforce 0
```

2. 确认主机名并绑定

```powershell
master上
# hostnamectl set-hostname --static vm1.cluster.com
slave上
# hostnamectl set-hostname --static vm2.cluster.com

两台都绑定主机名
# cat /etc/hosts
追加以下内容
10.1.1.11    vm1.cluster.com    master
10.1.1.12    vm2.cluster.com    slave
```

3, 同步系统时间

~~~powershell
# systemctl restart ntpd
# systemctl enable ntpd
~~~

说明:保证两台服务器系统时间一致即可(ntpd服务需要同步公网时间服务器,如果没有公网,手动改一下时间也可以)



## 搭建主从复制思路

1. master和slave安装相同版本mysql
2. master端必须开启==二进制日志==；slave端必须开启==relay log日志==, slave可不开二进制日志
3. master端和slave端的server-id号==必须不能一致==
4. slave端配置向master来同步数据
   - master端必须创建一个复制用户
   - 保证master和slave端==初始数据一致==
   - 配置主从复制（slave端）


## 主从搭建步骤

### 1, **修改主从配置文件**

master上的配置文件

~~~powershell
[root@vm1 ~]# vim /mysql56/etc/my.cnf
[mysqld]
port=3307
basedir=/mysql56/
datadir=/mysql56/data
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
log-error=/mysql56/data/mysql56.err
user=mysql
general_log
general_log_file=/mysql56/data/query.log
log-bin=binlog						master上二进制日志必须开
server-id=100						server-id为1到2**32次幂范围的1个整数
~~~

slave上的配置文件

```powershell
[root@vm2 ~]# vim /mysql56/etc/my.cnf
[mysqld]
port=3307
basedir=/mysql56/
datadir=/mysql56/data
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
log-error=/mysql56/data/mysql56.err
user=mysql
general_log
general_log_file=/mysql56/data/query.log

server-id=200						slave上的server-id和master上不一致
```

###  2, **两台都重启mysql服务**

两台都停止mysql服务(如果启动的话)

```powershell
# /mysql56/bin/mysqladmin shutdown -p
Enter password:
```

两台都**删除auto.cnf文件**

```powershell
# rm /mysql56/data/auto.cnf -rf
auto.cnf文件里保存的是每个数据库实例的UUID信息，代表数据库的唯一标识
```

两台都启动mysql服务 

```powershell
# /mysql56/bin/mysqld_safe --defaults-file='/mysql56/etc/my.cnf' &
```

### 3, **master上创建授权用户**

授于`replication slave`权限, 用户名`'slave'@'10.1.1.12'`后面的IP为slave的IP

```powershell
[root@vm1 ~]# /mysql56/bin/mysql -p
Enter password:

mysql> grant replication slave on *.* to 'slave'@'10.1.1.12' identified by '123';
mysql> flush privileges;
```

### 4, **查看master当前写的二进制文件名和位置**

```powershell
mysql> show master status;					只要打开了二进制日志这条命令就有输出结果
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000002 |      406 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
```

### 5, **slave上配置复制连接**

```powershell
[root@vm2 ~]# /mysql56/bin/mysql -p
Enter password:

mysql> change master to
    -> master_host='10.1.1.11',
    -> master_user='slave',
    -> master_password='123',
    -> master_port=3307,
    -> master_log_file='binlog.000002',
    -> master_log_pos=406;
```

| 参数              | 说明                    |
| --------------- | --------------------- |
| master_host     | master的IP             |
| master_user     | 复制的用户                 |
| master_password | 复制用户密码                |
| master_port     | master的端口号            |
| master_log_file | 指定复制开始的日志文件           |
| master_log_pos  | 指定复制开始的日志位置(position) |

### 6, **启动复制**

```powershell
mysql> start slave;
mysql> show slave status\G
				......
            Slave_IO_Running: Yes 	代表成功连接到master并且下载日志
            Slave_SQL_Running: Yes 	代表成功执行日志中的SQL语句
                ......
```

### 7, **测试验证**

在master上创建库,创建表,插入或修改数据。然后在slave上查看是否与master上的操作一致.

(==注意: 不要在slave上进行修改操作==,slave的修改操作现在是不能复制到master的,会造成数据不一致)



**小结:**

1. 主从复制必须保证两台数据库实例的==server-id不一致==
2. 主服务器==必须开启二进制日志==
3. 一主一从为**==单向==**复制架构, 只能master复制到slave, 不能slave复制到master,所以**==slave不要做写操作==**





## slave连接master时position的选择

在前面的步骤中, 我们选择的position是当前master正在写的position这样做需要2个条件:

1. 两台mysql数据一致
2. master不再有写操作(否则要锁表,做完复制后再解锁)

做AB复制可能有以下几种不同的场景:

* 业务未上线, 全新安装的两台新mysql

~~~powershell
使用上面的做法即可
~~~

* master已经跑了一年，一直都有开着二进制日志，并且日志无丢失

~~~powershell
方法1: 直接从一年前的起始position开始复制
方法2: 全备master,恢复到slave。然后从master备份结束的position开始复制
~~~

* master以前跑了半年没打开二进制日志，后半年打开了二进制日志

~~~powershell
全备master,恢复到slave。然后从master备份结束的position开始复制
~~~

* master已经跑了一年，但没有打开二进制日志

~~~powershell
1, 先打开二进制日志，重启mysql
2, 全备master,恢复到slave。然后从master备份结束的position开始复制
~~~



## 补充讨论

1, 如果把slave的mysql服务停掉, master继续写一段时间后, 然后再把slave的mysql服务启动

~~~powershell
结果: slave会自动连接,并会将master写的内容给复制过来.除非你在配置文件里加了skip-slave-start参数,那么启动后不会自动连接，需要手动连接
~~~

2, 如果把master的mysql服务停掉一段时间后, 然后再启动(**注意: 此时slave不能做写操作, 除非做双主架构,可以思考下为什么?**)

~~~powershell
结果: master启动后,会等待slave连接(一般为60秒的周期)
~~~

3, 如果复制出了问题(很容易模拟, 如在slave上创建一个库叫ccc, 再然后在master上也创建ccc库, 那么slave复制时会出现冲突，导致复制失败)

~~~powershell
解决思路: 在slave上stop slave,然后将两边数据调为一致后,重新在slave上change master to来连接,再start slave
~~~





# 五、基于GTIDs的AB复制架构(M-S)

## GTIDs简介

什么是GTIDs以及有什么特点？

GTIDs（Global transaction identifiers）全局事务标识符，是mysql 5.6新加入的一项技术

1. 当使用GTIDs时，每一个事务都可以被识别并且跟踪

2. 添加新的slave或者当发生故障需要将master身份或者角色迁移到slave上时，都无需考虑是哪一个二进制日志以及哪个position值，**极大简化了相关操作**

3. GTIDs是完全基于事务的，因此**不支持MYISAM存储引擎**

4. GTID由source_id和transaction_id组成： 

   1）source_id来自于server_uuid,可以在auto.cnf中看到

   2）transation_id是一个序列数字，自动生成.

通俗地说, **==基于GTIDs的复制架构不用再烦恼指定哪个连接position了,不支持MYISAM存储引擎==**。



## 搭建过程

我们在前面传统的AB复制基础上再搭建基于GTIDs的复制

### 1,主从修改配置文件支持GTIDs

**master配置文件修改**

```powershell
[root@vm1 ~]# vim /mysql56/etc/my.cnf
[mysqld]
port=3307
basedir=/mysql56/
datadir=/mysql56/data
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
log-error=/mysql56/data/mysql56.err
user=mysql
general_log
general_log_file=/mysql56/data/query.log
log-bin=binlog
server-id=100

gtid-mode=on					这一行开始后3句需要在master配置文件里增加
log-slave-updates=1				将relay-log里的记录同步到bin-log日志中	
enforce-gtid-consistency		 强制一致性
```

**slave配置文件修改**

~~~powershell
[root@vm2 ~]# vim /mysql56/etc/my.cnf
[mysqld]
port=3307
basedir=/mysql56/
datadir=/mysql56/data
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
log-error=/mysql56/data/mysql56.err
user=mysql
general_log
general_log_file=/mysql56/data/query.log
server-id=200

log-bin=slave-binlog		这一行开始后4句需要在slave配置文件里增加
gtid-mode=on
log-slave-updates=1
enforce-gtid-consistency
~~~

说明:
1, 开启GITDs需要在master和slave上都配置gtid-mode，log-bin，log-slave-updates，enforce-gtid-consistency（该参数在5.6.9之前是--disable-gtid-unsafe-statement）
3, 基于GTIDs复制**==从服务器必须开启二进制日志==**！



### 2, 重起主从数据库服务

```powershell
# /mysql56/bin/mysqladmin shutdown -p
Enter password:

# /mysql56/bin/mysqld_safe --defaults-file='/mysql56/etc/my.cnf' &
```

### 3, slave重新配置复制连接

```powershell
mysql> stop slave;

mysql> change master to
    -> master_host='10.1.1.11',
    -> master_user='slave',
    -> master_password='123',
    -> master_port=3307,
    -> master_auto_position=1;		不用指定从哪个二进制的哪个positon开始复制了
```

### 4, slave上启动复制

```powershell
mysql> start slave;

mysql> show slave status\G;
				......
            Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
                ......
```

### 5, 测试验证

自行验证，过程省略







# 六、其他复制架构的搭建思路

## 一主多从搭建思路

有几个slave,就把一主一从的架构重复几次



## 双主复制搭建思路

把一主一从**互换**角色再搭建一遍



## 级联复制搭建思路

中间的机器打开二进制日志和`log-slave-updates=1`参数

然后master-slave1做一次AB复制, slave1-slave2再做一次AB复制





#七、半同步复制

## 半同步复制介绍

上面的复制架构==默认都是异步==的，也就是主库将binlog日志发送给从库，这一动作就结束了，并==不会验证从库是否接受完毕==。这样可以提供==最佳的性能==，但是同时也带来了很高的风险。

当主服务器或者从服务器发生故障时，极有可能从服务器没有接到主服务器发过来的binglog日志，这样就会==导致主从数据不一致==，甚至导致数据丢失。

为了解决该问题，mysql5.5引入了==半同步复制模式。==



 ![半同步复制](pictures/半同步复制.png)

所谓的半同步复制就是master每commit一个事务(简单来说就是做一个改变数据的操作）,要确保slave接受完主服务器发送的binlog日志文件==并写入到自己的中继日志relay log里==，然后会给master信号，告诉对方已经接收完毕，这样master才能把事物成功==commit==。这样就保证了master-slave的==数据绝对的一致==（但是以牺牲==master的性能为代价==).如果slave挂了,master不可能永远等待slave的信号,默认等待10秒则转为异步。(等待时间也是可以调整的)。



## 半同步复制搭建过程

首先要搭建好一种复制(传统AB复制或基于GTIDs的AB复制), 这些复制默认都为异步的, 只需要安装相关插件并加简单的几步操作就可以转化为同步复制了。

### 1,安装插件

插件存放目录：``$basedir/lib/plugin/`

**master上**安装插件

```powershell
mysql> install plugin rpl_semi_sync_master soname 'semisync_master.so';
Query OK, 0 rows affected (0.00 sec)

查看是否安装成功
mysql> show global variables like 'rpl_semi_sync%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_semi_sync_master_enabled       | OFF   |是否启用master的半同步复制
| rpl_semi_sync_master_timeout       | 10000 |默认主等待从返回信息的超时间时间，10秒。动态可调
| rpl_semi_sync_master_trace_level   | 32    |用于开启半同步复制模式时的调试级别，默认是32 
| rpl_semi_sync_master_wait_no_slave | ON    |是否允许每个事物的提交都要等待slave的信号
+------------------------------------+-------+
```

**PS: 可以通过`mysql> uninstall plugin rpl_semi_sync_master;`来卸载插件**



**slave**上安装插件

```powershell
mysql> install plugin rpl_semi_sync_slave soname 'semisync_slave.so';

mysql> show global variables like 'rpl_semi_sync%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| rpl_semi_sync_slave_enabled     | OFF   |   slave是否启用半同步复制
| rpl_semi_sync_slave_trace_level | 32    |
+---------------------------------+-------+
```

### 2, 激活半同步复制

**master**上

```powershell
mysql>  set global rpl_semi_sync_master_enabled =on;

mysql>  show global variables like 'rpl_semi_sync%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_semi_sync_master_enabled       | ON    |	  现在为ON了
| rpl_semi_sync_master_timeout       | 10000 |
| rpl_semi_sync_master_trace_level   | 32    |
| rpl_semi_sync_master_wait_no_slave | ON    |
+------------------------------------+-------+


mysql> show global status like 'rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 1     |有一个从服务器启用半同步复制
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |master等slave的平均等待时间。单位毫秒
| Rpl_semi_sync_master_net_wait_time         | 0     |master总的等待时间。单位毫秒
| Rpl_semi_sync_master_net_waits             | 0     |master等待slave回复的总的等待次数
| Rpl_semi_sync_master_no_times              | 0     |master关闭半同步复制的次数
| Rpl_semi_sync_master_no_tx                 | 0     |表示从服务器确认的不成功提交的数量
| Rpl_semi_sync_master_status                | ON    |标记master现在是否是半同步复制状态
| Rpl_semi_sync_master_timefunc_failures     | 0     |master调用时间失败的次数	
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |master花在每个事务上的平均等待时间
| Rpl_semi_sync_master_tx_wait_time          | 0     |master花在事物上总的等待时间
| Rpl_semi_sync_master_tx_waits              | 0     |master事物等待次数
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |后来的先到了，而先来的还没有到的次数
| Rpl_semi_sync_master_wait_sessions         | 0     |多少个session因为slave回复而造成等待
| Rpl_semi_sync_master_yes_tx                | 0     |表示从服务器确认的成功提交数量
+--------------------------------------------+-------+
```

**slave**上

```powershell
mysql> set global rpl_semi_sync_slave_enabled=on;

mysql> show global variables like 'rpl_semi_sync%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Rpl_semi_sync_slave_status | ON    |
+----------------------------+-------+
```

### 3, 在slave上重启slave的IO线程

```powershell
mysql> stop slave IO_THREAD;
mysql> start slave IO_THREAD;
```

### 4, 测试验证

==原理：==

当slave从库的IO_Thread 线程将binlog日志接受完毕后，要给master一个确认，如果超过10s未收到slave的接收确认信号，那么就会自动转换为传统的异步复制模式。

1, master插入一条记录（没有表的话请先建一个测试表)，查看slave是否有成功返回

```powershell
mysql> insert into a values (1 );
Query OK, 1 row affected (0.01 sec)

mysql> show global status like 'rpl_semi_sync%_yes_tx'; 
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_yes_tx |  1    |
表示这次事物成功从slave返回一次确认信号
+-----------------------------+-------+
```

2. slave上模拟故障查看返回时间

   当slave挂掉后，master这边更改操作

```powershell
[root@vm2 ~]# /mysql56/bin/mysqladmin shutdown -p123
或者直接停止slave的IO_thread线程
mysql> stop slave io_thread;
```

当slave挂掉后，master这边继续插入操作

~~~powershell
[root@vm1 ~]# /mysql56/bin/mysql -p123

mysql> insert into a values (4);
Query OK, 1 row affected (10.00 sec)
这次插入一个值需要等待10秒（默认的等待时间)

mysql> insert into a values (5);
Query OK, 1 row affected (0.01 sec)
现在自动转成了原来的异步模式
~~~

3, 再次启动slave，查看同步模式

```powershell
[root@vm2 ~]# /mysql56/bin/mysqld_safe --defaults-file='/mysql56/etc/my.cnf' &

mysql> show global status like 'rpl_semi_sync%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Rpl_semi_sync_slave_status | OFF    |
+----------------------------+-------+
如需要再次半同步复制，则按照以上步骤重新开启就可以

mysql> set global rpl_semi_sync_slave_enabled=on;
mysql> stop slave IO_THREAD;
mysql> start slave IO_THREAD;



或者可以将该参数写入到配置文件中就可以实现永久生效：
master：rpl_semi_sync_master_enabled=1
slave：rpl_semi_sync_slave_enabled=1  
```



PS: 等待时间可以在master上动态调整，如下

~~~powershell
mysql> set global rpl_semi_sync_master_timeout=2000;
mysql> show global variables like 'rpl_semi_sync%';
+------------------------------------+---------+
| Variable_name                      | Value   |
+------------------------------------+---------+
| rpl_semi_sync_master_enabled       | ON      |
| rpl_semi_sync_master_timeout       | 2000    |
| rpl_semi_sync_master_trace_level   | 32      |
| rpl_semi_sync_master_wait_no_slave | ON      |
+------------------------------------+---------+
~~~






