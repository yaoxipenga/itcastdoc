# Ambari自动部署Hadoop

## Ambari介绍

Apache Ambari项目旨在通过开发用于配置，管理和监控Apache Hadoop集群的软件来简化Hadoop管理。Ambari提供了一个由RESTful API支持的直观，易用的Hadoop管理Web UI。

Ambari使系统管理员能够：

- 提供Hadoop集群安装
  - Ambari提供了跨任意数量的主机安装Hadoop服务的分步向导。
  - Ambari处理群集的Hadoop服务配置。
- 管理Hadoop集群
  - Ambari提供集中管理，用于在整个集群中启动，停止和重新配置Hadoop服务。
- 监控Hadoop集群
  - Ambari提供了一个仪表板，用于监控Hadoop集群的运行状况和状态。
  - Ambari利用[Ambari指标系统](https://issues.apache.org/jira/browse/AMBARI-5707)进行指标收集。
  - Ambari利用[Ambari Alert Framework](https://issues.apache.org/jira/browse/AMBARI-6354)进行系统警报，并在需要您注意时通知您（例如，节点出现故障，剩余磁盘空间不足等）

Ambari使应用程序开发人员和系统集成商能够：

- 使用[Ambari REST API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)轻松将Hadoop配置，管理和监控功能集成到自己的应用程序中



## Ambari部署

Ambari本身也是一个分布式架构软件，主要由两部分组成：

- Ambari Server
- Ambari Agent

用户通过Ambari Server通知Ambari Agent安装对应的软件，Agent会定时发送各个机器每个软件模块的状态给Server,最终这些状态信息会呈现给Ambari的GUI,方便用户了解到集群中各组件状态，做出相应的维护策略。

Ambari部署介绍: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.1.5/bk_ambari-installation/content/hdp_26_repositories.html

## 环境准备

宿主机做Ambari Server

5台KVM虚拟机做Ambari Agent(hadoop集群部署在这5台上面)



![1562994664774](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari环境图.png)





### 第1大步: 环境准备

- 所有机器静态IP,主机名及绑定

```powershell
# vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.122.1   daniel.cluster.com
192.168.122.11  vm1.cluster.com
192.168.122.12  vm2.cluster.com
192.168.122.13  vm3.cluster.com
192.168.122.14  vm4.cluster.com
192.168.122.15  vm5.cluster.com
```

- 所有机器关闭防火墙,selinux
- 所有机器时间同步

```powershell
# systemctl restart ntpd
# systemctl enable ntpd
```

- 所有机器调大文件描述符限制

```powershell
# ulimit -SHn 20480

# vim /etc/security/limits.conf
* soft nofile 20480
* hard nofile 20480
```



### 第2大步: ssh免密

配置ambari server到所有hadoop集群节点的root用户ssh免密

```powershell
[root@daniel ~]# ssh-keygen
```

```powershell
[root@daniel ~]# for i in {1..5}; do ssh-copy-id vm$i.cluster.com ; done
```



### 第3大步: 配置ambari源

在ambari server上配置ambari的yum源,并拷贝到所有hadoop集群节点

```powershell
[root@daniel ~]# vim /etc/yum.repos.d/ambari.repo
[ambari]
name=ambari
baseurl=http://192.168.122.1/hadoop/ambari/
enabled=1
gpgcheck=0
```

使用下面命令拷贝到所有hadoop集群节点(或者使用mobaXterm的multiexec功能)

```powershell
[root@daniel ~]# for i in {1..5}; do scp /etc/yum.repos.d/ambari.repo vm$i.cluster.com:/etc/yum.repos.d/ambari.repo; done
```



### 第4大步: 安装jdk

在ambari server上安装jdk

```powershell
[root@daniel ~]# tar xf /share/hadoop/jdk-8u191-linux-x64.tar.gz -C /usr/local/
```

拷贝jdk到所有hadoop集群节点

```powershell
[root@daniel ~]# for i in {1..5}; do scp /share/hadoop/jdk-8u191-linux-x64.tar.gz vm$i.cluster.com:/root/; done
```

并在所有hadoop集群节点解压安装

```powershell
[root@daniel ~]# for i in {1..5}; do ssh vm$i.cluster.com tar xf /root/jdk-8u191-linux-x64.tar.gz -C /usr/local ; done
```



### 第5大步: 安装ambari server

1, 在ambari server上安装数据库,启动服务,并导入相关数据(其它服务器不安装)

```powershell
[root@daniel ~]# yum install mariadb mariadb-server mysql-connector-java

[root@daniel ~]# systemctl start mariadb
[root@daniel ~]# systemctl enable mariadb
```

```powershell
[root@daniel ~]# mysql

MariaDB [(none)]> create database ambari;


MariaDB [(none)]> grant all on ambari.* to ambari@'daniel.cluster.com' identified by 'bigdata';		授权的库名，用户名，主机名，密码全部要在下一步的ambari配置里对应


MariaDB [(none)]> flush privileges;

MariaDB [ambari]> quit
```

2, 在ambari server上安装ambari-server, 并在mysql里导入数据(其它服务器不操作)

```powershell
[root@daniel ~]# yum install ambari-server

[root@daniel ~]# mysql		
安装完后，连到数据库里导入数据(必须要安装完ambari-server后才有导入的.sql文件)

MariaDB [(none)]> use ambari;


MariaDB [ambari]> source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql

MariaDB [ambari]> quit

```

3, 在ambari server配置

```powershell
[root@daniel ~]# ambari-server setup
Using python  /usr/bin/python
Setup ambari-server
Checking SELinux...
SELinux status is 'disabled'
Customize user account for ambari-server daemon [y/n] (n)? y	输入y自定义用户
Enter user account for ambari-server daemon (root):				使用root用户
Adjusting ambari-server permissions and ownership...
Checking firewall status...
Checking JDK...
[1] Oracle JDK 1.8 + Java Cryptography Extension (JCE) Policy Files 8
[2] Oracle JDK 1.7 + Java Cryptography Extension (JCE) Policy Files 7
[3] Custom JDK
==============================================================================
Enter choice (1): 3				选1,2需要连网下载，速度慢，直接选择3(因为前面步骤我们已经准备好了)
WARNING: JDK must be installed on all hosts and JAVA_HOME must be valid on all hosts.
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Path to JAVA_HOME: /usr/local/jdk1.8.0_191/						对应前面解压的jdk路径
Validating JDK on Ambari Server...done.
Completing setup...
Configuring database...
Enter advanced database configuration [y/n] (n)? y				输入y配置数据库连接选项
Configuring database...
==============================================================================
Choose one of the following options:
[1] - PostgreSQL (Embedded)
[2] - Oracle
[3] - MySQL / MariaDB
[4] - PostgreSQL
[5] - Microsoft SQL Server (Tech Preview)
[6] - SQL Anywhere
[7] - BDB
==============================================================================
Enter choice (1): 3											选择mysql/mariadb
Hostname (localhost): daniel.cluster.com					写上ambari server的主机名
Port (3306):												数据库port
Database name (ambari):										库名，和前面授权对应	
Username (ambari):											用户名,和前面授权对应	
Enter Database Password (bigdata):							密码,和前面授权对应
Configuring ambari database...
Configuring remote database connection properties...
WARNING: Before starting Ambari Server, you must run the following DDL against the database to create the schema: /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql						这个警告可以无视，前面我们已经导入了数据
Proceed with configuring remote database connection properties [y/n] (y)?	y确认
Extracting system views...
ambari-admin-2.5.1.0.159.jar
...........
Adjusting ambari-server permissions and ownership...
Ambari Server 'setup' completed successfully.


```

4, 启动ambari-server(其它服务器不用操作)

```powershell
[root@daniel ~]# ambari-server start
Using python  /usr/bin/python
Starting ambari-server
Ambari Server running with administrator privileges.
Organizing resource files at /var/lib/ambari-server/resources...
Ambari database consistency check started...
Server PID at: /var/run/ambari-server/ambari-server.pid
Server out at: /var/log/ambari-server/ambari-server.out
Server log at: /var/log/ambari-server/ambari-server.log
Waiting for server start............................
Server started listening on 8080

DB configs consistency check: no errors and warnings were found.
Ambari Server 'start' completed successfully.


[root@daniel ~]# lsof -i:8080
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    27096 root 1439u  IPv6 131946      0t0  TCP *:webcache (LISTEN)
```

### 第6大步: 图形配置

![1562936147211](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari1.png)

![1562936325394](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari2.png)



![1562936411120](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari3.png)



![1562936775467](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari4.png)



![1562937056933](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari5.png)

![1562937307517](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari6.png)



![1562937344642](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari7.png)



![1562937449908](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari8.png)



**注册不成功的可能问题**

提示Connecting to https://daniel.cluster.com:8440/ca ERROR

解决方法如下(**以下操作在所有的hadoop节点上修改,ambari server不用**)

```powershell
# vim /etc/python/cert-verification.cfg

[https]

verify=disable #修改

# vim /etc/ambari-agent/conf/ambari-agent.ini

[security]
force_https_protocol=PROTOCOL_TLSv1_2 #添加一行

# ambari-agent restart

# yum install libtirpc-devel -y
centos7.6中要安装
```



![1562939074899](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari9.png)



![1562939135586](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari10.png)

**解决问题后再重新注册**

![1562939327311](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari11.png)



![1562939489259](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari12.png)



![1562939595412](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari13.png)

![1562939637565](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari14.png)



![1562939805525](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari15.png)



![1562939836601](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari16.png)



![1562939972512](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari17.png)



![1562940063362](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari18.png)



![1562940224159](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari19.png)



![1562940276599](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari20.png)



![1562940340723](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari21.png)



![1562943497758](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari22.png)

## 登录验证

![1562943580149](D:/01_北京10期/hadoop大数据运维/讲义/hadoop图片/ambari23.png)

























































































