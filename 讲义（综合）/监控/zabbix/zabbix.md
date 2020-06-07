

# 场景

运维工程师除了搭建架构环境，配置管理外，还需要保证业务的**==稳定==**运行。不稳定的情况包括很多方面,如:

* CPU负载过大
* 内存不够
* 磁盘空间满了
* 网络很卡
* 服务不能被访问

等等各种问题。我们运维工程师无法做到时刻盯着服务器查看各类状态，所以需要建立一套完善的**==自动化监控==**系统，将所有需要监控的服务器及其各种需要的状态数据都实时地**收集**, **图形展示**,**报警。**

![1578927121943](zabbix图片/监控架构图.png)



# **学习目标**

- [ ] 知道监控的目的与目标

- [ ] 能够安装zabbix服务器
- [ ] 能够使用zabbix-agent监控本机与远程linux
- [ ] 能够说出模板的作用
- [ ] 掌握自定义监控项的方法
- [ ] 能够为添加的监控项创建图形
- [ ] 能够为监控项设定触发器
- [ ] 能够实现zabbix报警
- [ ] 能够通过自动发现与动作实现自动监控
- [ ] 能够说出导入导出功能的作用
- [ ] 能够通过proxy来实现监控



# 一、认识监控

## **监控的目的**

* 实时收集数据并图形展示, 通过报警及时发现问题与处理问题。

* 为架构优化也提供依据。



## 监控的目标

**生活中的监控:**

![1541674720378](zabbix图片/1541674720378.png)

![1541674782863](zabbix图片/1541674782863.png)



那么**请问linux系统中的监控主要监控什么**?

* **任何你所想要监控的数据**, 如cpu负载,cpu的idle时间,内存使用量,内存利用率,io,network等等。
* 现在很多开源监控方案已经把常见的监控做成了模板，我们可以直接套用
* 大型公司会有更多的监控需求, 那么就需要专业的开发人员来做监控开发(运维人员也可以开发)

![1578930808598](zabbix图片/监控事项.png)



## 主流的开源监控平台介绍

* **mrtg**	(Multi Router Traffic Grapher)通过**snmp**协议得到设备的流量信息，并以包含PNG格式的图形的HTML文档方式显示给用户。

* **cacti**       (仙人掌) 用php语言实现的一个软件，它的主要功能是用snmp服务获取数据，然后用rrdtool储存和更新数据。官网地址: https://www.cacti.net/
* **ntop**      官网地址: https://www.ntop.org/
* **nagios**   能够跨平台,插件多,报警功能强大。官网地址: https://www.nagios.org/
* **centreon**  底层使用的就是nagios。是一个nagios整合版软件。官网地址:https://www.centreon.com/
* **ganglia**    设计用于测量数以千计的节点,资源消耗非常小。官网地址:http://ganglia.info/
* **open-falcon**  小米公司开源,高效率,高可用。用户基数相对小。官网地址: http://open-falcon.org/
* **==zabbix==**     跨平台,画图,多条件告警,多种API接口。用户基数大。官网地址: https://www.zabbix.com/
* **==prometheus==** 基于时间序列的数值数据的容器监控解决方案。官网地址: https://prometheus.io/





# 二、zabbix

![1578931155374](zabbix图片/zabbix主页.png)

## zabbix基础概念初探

1. **主机(host)和主机群组(host group)**	

主机指被监控的一个设备(服务器,交换机等)，当被监控的主机数量巨大时，就需要分组

2. **zabbix用户(user)与用户群组(group)**

zabbix可以多个用户登录管理(和Linux操作系统一样有管理员和普通管理者)

3. **监控项(item)与应用集(application)**

监控的需求太多了,就拿监控cpu平均负载来说,就有监控1分钟内,5分钟内,15分钟内等三个常见的监控参数。

监控项(item)是从收集数据或监控的一个**最小单位**。把cpu1分钟内的平均负载就可以做成一个监控项。

应用集就是多个监控项的组。

4. **图形**

监控项收集的数据需要用图形直观地展示出来。

5. **触发器和报警**

当监控项收集的数据达到一个临界点时，就要触发报警通知管理人员。

如: 当根分区使用率超过80%时, 就通过发报警信息到管理人员。

6. **模板**

模板主要包括监控项,图形,触发器等概念，相当于是把要监控的东西做成一个合集。



## 监控场景准备

**环境准备:** 这里为1台监控服务器和2台被监控端

![1579330958191](zabbix图片/实验环境图.png)

1. 静态ip 

2. 主机名

~~~powershell
各自配置好主机名
# hostnamectl set-hostname --static server

三台都互相绑定IP与主机名
# vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.1.11  server
10.1.1.12  agent1
10.1.1.13  agent2
~~~

3. 时间同步

~~~powershell
# systemctl restart ntpd
# systemctl enable ntpd
~~~

4. 关闭防火墙,selinux

~~~powershell
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F

# setenforce 0
setenforce: SELinux is disabled
~~~

3. 所有机器(zabbix服务器和所有被监控端)配置yum(安装完centos后默认的yum源+下面zabbix源)

~~~powershell
# vim /etc/yum.repos.d/zabbix.repo
[zabbix]
name=zabbix
baseurl=https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/4.4/rhel/7/x86_64/
enabled=1
gpgcheck=0
[zabbix_deps]
name=zabbix_deps
baseurl=https://mirrors.tuna.tsinghua.edu.cn/zabbix/non-supported/rhel/7/x86_64/
enabled=1
gpgcheck=0
~~~





# 三、zabbix服务器安装

参考: https://www.zabbix.com/documentation/current/manual/installation/install_from_packages/rhel_centos

**zabbix服务器结构图**

![1561796495280](zabbix图片/zabbix基础原理架构图.png)



## 1, 安装zabbix服务器端软件

~~~powershell
[root@server ~]# yum install zabbix-server-mysql zabbix-web-mysql mariadb-server
~~~

## 2, 启动数据库并建库

在mysql(mariadb)里建立存放数据的库并授权，然后导入zabbix所需要用的表和数据

~~~powershell
[root@server ~]# systemctl restart mariadb
[root@server ~]# systemctl enable mariadb

[root@server ~]# mysql
MariaDB [(none)]> create database zabbix default charset utf8;

MariaDB [(none)]> grant all on zabbix.* to zabbix@'localhost' identified by '123';
MariaDB [(none)]> flush privileges;
MariaDB [(none)]> quit
~~~

说明: 

* 建库要用utf8字符集，否则后面zabbix很多中文用不了(比如创建中文名用户就创建不了)
* 用户名与密码自定义，但需要和下面的第4步配置文件对应

## 3, 导入zabbix表数据

~~~powershell
[root@server ~]# zcat /usr/share/doc/zabbix-server-mysql-4.4.4/create.sql.gz |mysql -u zabbix -p123 zabbix
~~~

验证导入的表数据

~~~powershell
[root@server ~]# mysql -e 'use zabbix; show tables;'
~~~



## 4, 配置zabbix并启动服务

配置server端配置文件`/etc/zabbix/zabbix_server.conf` 

**注意: 有些参数默认为注释状态也是生效的。如果要修改，则必须要打开注释再修改**

~~~powershell
[root@server ~]# vim /etc/zabbix/zabbix_server.conf
ListenPort=10051
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=123						打开注释并修改连接mysql的密码,在124行
DBSocket=/var/lib/mysql/mysql.sock 	
ListenIP=0.0.0.0
~~~

~~~powershell
[root@server ~]# systemctl restart zabbix-server
[root@server ~]# systemctl enable zabbix-server

[root@server ~]# netstat -ntlup |grep 10051
tcp   0  0 0.0.0.0:10051      0.0.0.0:*         LISTEN      9221/zabbix_server
tcp6  0  0 :::10051           :::*              LISTEN      9221/zabbix_server
~~~



## 5, 配置httpd并启动服务

zabbix软件包自带了httpd的子配置文件,需要修改时区，否则监控的数据会出现时间不对应的情况

~~~powershell
[root@server ~]# vim /etc/httpd/conf.d/zabbix.conf

20 php_value date.timezone Asia/Shanghai			打开注释,并修改时区

[root@server ~]# systemctl restart httpd 
[root@server ~]# systemctl enable httpd

[root@server ~]# netstat -ntlup |grep :80
tcp6    0    0 :::80          :::*              LISTEN      9338/httpd
~~~

## 6, 浏览器配置与登录

使用浏览器访问http://10.1.1.11/zabbix

![1579010262154](zabbix图片/zabbix1.png)

![1579010373893](zabbix图片/zabbix2.png)

![1579010443721](zabbix图片/zabbix3.png)

![1579010538026](zabbix图片/zabbix4.png)

![1579010581873](zabbix图片/zabbix5.png)

![1579010648262](zabbix图片/zabbix6.png)

![1579010731995](zabbix图片/zabbix7.png)



## 7, 修改为中文web管理

右上角点一个类似小人的图标   --》 语言选 chinese zh-cn  --》 点 update后换成中文件界面

![1579010879816](zabbix图片/zabbix8.png)

![1579010995740](zabbix图片/zabbix9.png)

![1579011037744](zabbix图片/zabbix10.png)



# 四、zabbix服务器监控本机

概念:

* **主机(host)**: 指被监控的一个设备(服务器,交换机等)

* **主机群组(hostgroup)**: 指被监控的一组主机（主要应用在有特别多主机的情况，方便分组区分)



zabbix服务器端默认配置了监控本机，但还需要安装客户端收集工具:zabbix-agent。

![1579055669939](zabbix图片/zabbix11.png)





## 1, 服务器上安装zabbix-agent

~~~powershell
[root@server ~]# yum install zabbix-agent
~~~

## 2, 启动zabbix-agent服务

请使用vi或vim打开agent端配置文件`/etc/zabbix/zabbix_agentd.conf`修改,修改后的结果如下

```powershell
[root@server ~]# egrep -vn '^#|^$' /etc/zabbix/zabbix_agentd.conf
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
98:Server=127.0.0.1						zabbix服务器的IP，agent被动监控(默认模式)
139:ServerActive=127.0.0.1				zabbix服务器的IP，agent主动监控
150:Hostname=server						zabbix服务器的主机名
290:Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

**说明:** 

* 默认为相对于agent的被动监控,表示server找agent拿数据, 而不是agent主动给数据server
* 主动与被动只是数据传输的方式不同, 具体区别我们在最后的章节讨论
* 我这里只修改了第150行的主机名,其它参数都为默认值未修改

~~~powershell
[root@server ~]# systemctl restart zabbix-agent
[root@server ~]# systemctl enable  zabbix-agent

[root@server ~]# netstat -ntlup |grep :10050
tcp    0    0 0.0.0.0:10050      0.0.0.0:*       LISTEN      65171/zabbix_agentd
tcp6   0    0 :::10050           :::*            LISTEN      65171/zabbix_agentd
~~~

## 3, 确认本机监控状态

![1579064070803](zabbix图片/zabbix12.png)

**监控状态不OK的排错思路:**

* 查看日志`cat /var/log/zabbix/zabbix_server.log`



## 4, 解决图形中文乱码问题

![1579072513968](zabbix图片/zabbix13.png)

![1579072798449](zabbix图片/zabbix14.png)

![1579072839653](zabbix图片/zabbix15.png)

![1579072906529](zabbix图片/zabbix16.png)



乱码原因: 字符不兼容

解决乱码方法: 换一个字体

下载我共享的`ttf-arphic-ukai.tar.gz`软件包,并做如下配置

~~~powershell
# tar xf ttf-arphic-ukai.tar.gz -C /usr/share/zabbix/fonts/
# mv /usr/share/zabbix/fonts/ukai.ttc /usr/share/zabbix/fonts/ukai.ttf
# vim /usr/share/zabbix/include/defines.inc.php

67 define('ZBX_GRAPH_FONT_NAME',           'ukai');   修改原来的graphfont字体改成ukai
~~~

做完后不用重启服务,web界面刷新查看图形就会发现中文显示正常了

![1579076073469](zabbix图片/zabbix17.png)



# 五、监控远程linux服务器

## 1, agent1上安装zabbix-agent

~~~powershell
[root@agent1 ~]# yum install zabbix-agent -y
~~~

## 2, 配置agent端并启动服务

配置`/etc/zabbix/zabbix_agentd.conf`配置文件，配置结果如下:

~~~powershell
[root@agent1 ~]# egrep -vn '^#|^$' /etc/zabbix/zabbix_agentd.conf
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
98:Server=10.1.1.11					修改成zabbix监控服务器的IP,agent被动模式
139:ServerActive=10.1.1.11			修改成zabbix监控服务器的IP,agent主动模式
150:Hostname=agent1					修改为被监控端的主机名
290:Include=/etc/zabbix/zabbix_agentd.d/*.conf
~~~

~~~powershell
[root@agent1 ~]# systemctl restart zabbix-agent
[root@agent1 ~]# systemctl enable zabbix-agent

[root@agent1 ~]# netstat -ntlup |grep :10050
tcp    0   0 0.0.0.0:10050        0.0.0.0:*        LISTEN      7413/zabbix_agentd
tcp6   0   0 :::10050             :::*             LISTEN      7413/zabbix_agentd
~~~

## 3, web管理界面创建监控主机

回到web管理界面－－》点配置－－》点主机 －－》 点创建主机

![1579084066121](zabbix图片/zabbix18.png)



![1579084528633](zabbix图片/zabbix19.png)

![1579084756873](zabbix图片/zabbix20.png)

## 4, 确认监控OK

![1579084898226](zabbix图片/zabbix21.png)

**监控不OK的排错思路:**

* 检查server与agent1的网络是否OK，防火墙是否关闭
* 检查IP与端口是否写错
* 在agent端查看日志`cat /var/log/zabbix/zabbix_agentd.log`
* 在server端查看日志`cat /var/log/zabbix/zabbix_server.log`





# 六、模板

## 模板介绍与作用

**模板(template)**: 是包括监控项，应用集，触发器，图形，聚合图形，自动发现，web监测等的一组实体。

**==使用模板可以方便应用到主机，更改模板也会将更改应用到所有链接的主机==**。

例: 比如我要把监控nginx相关的全部做成一个模板，有100台服务器需要监控nginx，我只需要链接模板到这100台机器即可。以后需要修改，只需要修改模板，这100台就会被同时修改。

![1579096833454](zabbix图片/zabbix22.png)





## 为主机添加或删除模板

zabbix自带了很多实用的模板, 对于一些要求不高的公司来说, 直接将模板添加到监控主机都几乎够用了。



![1579098438828](zabbix图片/zabbix23.png)

![1579099902498](zabbix图片/zabbix24.png)

![1579099983287](zabbix图片/zabbix25.png)

![1579100084571](zabbix图片/zabbix26.png)

![1579100154673](zabbix图片/zabbix27.png)

![1579100242876](zabbix图片/zabbix28.png)

## 创建自定义模板

![1579100352191](zabbix图片/zabbix29.png)

![1579100568737](zabbix图片/zabbix30.png)

![1579100785403](zabbix图片/zabbix31.png)



**练习:** 请将agent1其它模板都清空，只保留刚刚自定义的`Template test`模板。

操作的最终结果如下:

![1579101068432](zabbix图片/zabbix32.png)







# 七、监控项与应用集

**监控项(item)**: 是从主机收集的数据信息,代表收集数据或监控的一个**最小单位**。

比如cpu1分钟内平均负载,内存空闲值,磁盘使用率等等都可以做为监控项，可以说监控项有无限种可能。

**应用集(applications)**: 代表多个监控项目合成的组。



## 创建监控项的方式

创建监控项的方法有2种:

1. 在某一台被监控机上创建(如下图所示)，这样创建的监控项只对此监控机生效。

![1579102219637](zabbix图片/zabbix33.png)

2. 在模板里创建(如下图所示), 这样创建的监控项对所有使用此模板的主机生效(**推荐方式**)。

![1579102343190](zabbix图片/zabbix34.png)

![1579102406593](zabbix图片/zabbix35.png)



## 创建自带键值监控项

创建监控项中最核心的概念就是**==键值(key)==**。

**键值就看作是开发好的用于收集数据的命令**，主要有两种:

- **zabbix自带的键值**(太多了,不用特意去记忆)
- **自定义开发的键值**(用linux基础命令就可以开发)



案例: 使用zabbix自带键值创建监控项实现监控cpu的1分钟内平均负载

键值写法可参考下图:

![1579103212553](zabbix图片/zabbix36.png)



### 1, 在模板里创建监控项

![1579102343190](zabbix图片/zabbix34.png)

![1579102406593](zabbix图片/zabbix35.png)

### 2, 填写监控项相关信息

![1579154201717](zabbix图片/zabbix37.png)

![1579153272044](zabbix图片/zabbix38.png)

### 3, 确认创建成功

![1579153367459](zabbix图片/zabbix39.png)

![1579153471810](zabbix图片/zabbix40.png)





**练习:** 将cpu五分钟内平均负载, cpu十五分钟内平均负载分别做成cpu_avg5,cpu_avg15两个监控项

最终结果如下:

![1579154373049](zabbix图片/zabbix41.png)

## 创建自定义键值监控项

以监控登录用户数为例，自带键值中有`system.users.num`这个键值，但我们不使用它，使用自定义的键值来实现。



### 1, 在被监控端agent1上操作

首先在agent1多打开几个终端,模拟多个登录用户,然后使用`who |wc -l`查询

```powershell
[root@agent1 ~]# who |wc -l
15							我这里确认登录用户数为15
```

然后在agent1上,定义UserParameter

```powershell
[root@agent1 ~]# vim /etc/zabbix/zabbix_agentd.conf 

318 UserParameter=loginusers,who | wc -l

说明: loginusers是我自定义的一个键值名称（会在创建监控项时用到),后面的who |wc -l就要被监控的命令
```

重启zabbix-agent服务使之生效

~~~powershell
[root@agent1 ~]# systemctl restart zabbix-agent
~~~



### 2, 在zabbix监控端上操作

在zabbix服务器安装`zabbix-get`工具，可以远程测试能否通过自定义的键值得到数据

```powershell
[root@server ~]# yum install zabbix-get

[root@server ~]# zabbix_get -s 10.1.1.12 -k loginusers
15					可以确认得到的值确实为agent1的登录用户数
```

说明:

* -s后接agent端的IP
* -k接agent端自定义的键值

### 3, 在web管理界面创建监控项

还是在自定义模板里创建

![1579168009677](zabbix图片/zabbix42.png)

![1579168267856](zabbix图片/zabbix43.png)

![1579168481402](zabbix图片/zabbix44.png)

### 4, 确认创建成功

![1579168970778](zabbix图片/zabbix45.png)



![1579169131554](zabbix图片/zabbix46.png)

# 八、图形与聚合图形

监控项创建好了, 但是它监控收集的数据在哪里看呢? 答案就是**图形**

## 创建图形显示监控项数据

### 1, 在模板里创建图形

![1579169315713](zabbix图片/zabbix47.png)

![1579169363263](zabbix图片/zabbix48.png)

### 2, 配置图形对应监控项

![1579169642292](zabbix图片/zabbix49.png)



![1579169745837](zabbix图片/zabbix50.png)

### 3, 验证图形

![1579169833817](zabbix图片/zabbix51.png)



![1579169878549](zabbix图片/zabbix52.png)

![1579169916611](zabbix图片/zabbix53.png)

![1579169995554](zabbix图片/zabbix54.png)

**练习: **请将前面自定义的登录用户数这个监控项也做成图形

最终结果如图: 

![1579172114342](zabbix图片/zabbix55.png)



## 聚合图形

**聚合图形:** 就是把多个重要常用的图形整合一起来显示,方便查看.

假设需要经常查看agent1的cpu负载与登录用户数这两张图,我们可以将其聚合到一起做成一张聚合图形



### 1, 创建聚合图形

![1579172803164](zabbix图片/zabbix56.png)

![1579172936908](zabbix图片/zabbix57.png)

![1579173124769](zabbix图片/zabbix58.png)

### 2, 编辑聚合图形

![1579173219745](zabbix图片/zabbix59.png)

![1579173339470](zabbix图片/zabbix60.png)

![1579173451898](zabbix图片/zabbix61.png)

![1579173514734](zabbix图片/zabbix62.png)

![1579173584145](zabbix图片/zabbix63.png)

### 3, 编辑仪表板并查看

![1579173923887](zabbix图片/zabbix64.png)



![1579174170530](zabbix图片/zabbix65.png)



**补充:** 也可以在模板里创建聚合图形，这样所有添加模板的主机都能有此聚合图形了。





# 九、触发器

虽然我们可以通过图形查看到监控的数据，但我们不可能一直盯着图形的变化。

所以需要定义监控项到达一个临界值(阈值)或者满足一个条件，就会发生状态变化的通知。

定义**触发器(trigger)**就是定义这个临界值(阈值)或条件.

监控项有无限种可能，触发器也一样有无限种可能。如: 

* cpu负载值大于某个值则通知
* 登录用户数大于某个值则通知
* 内存空闲率小于某个值则通知
* 磁盘使用率大于某个值则通知
* 主机名被修改则通知

等等，主要还是看需求。

## 创建登录用户数过多的触发器

### 1, 在模板里创建触发器

![1579176760782](zabbix图片/zabbix66.png)

![1579177103686](zabbix图片/zabbix67.png)

### 2, 配置触发器

![1579177551294](zabbix图片/zabbix68.png)



![1579177790405](zabbix图片/zabbix69.png)

![1579178242790](zabbix图片/zabbix70.png)

### 3, 验证创建成功

![1579178615519](zabbix图片/zabbix71.png)

![1579178691679](zabbix图片/zabbix72.png)

### 4, 验证触发器效果

先在agent1上再多打开几个终端，将登录用户数控制在20个以上(操作过程省略)

然后通过下图查看触发器通知

![1579178965780](zabbix图片/zabbix73.png)



![1579240449765](zabbix图片/zabbix73-1.png)

**自由思维与操作练习:  请将cpu负载的相关监控项也创建对应的触发器并验证。**



# 十、报警

触发器的通知信息显示在web管理界面, 运维工程师仍然没办法24小时盯着它。所以我们希望它能自动地通知工程师们，这就是报警。

zabbix的报警媒介支持email,jabber,sms(短信),微信,电话语音等。

## 报警过程原理

![1579191707006](zabbix图片/zabbix74.png)



## 报警平台申请

自己配置报警过程比较复杂，需要配置触发器动作，用户与其报警媒介，最麻烦的是写程序对接邮件,微信,短信，电话等接口.

* 邮件容易被拒，当做垃圾邮件
* 微信需要企业微信号并开发程序对接
* 短信一般都需要付费买运营商相关服务
* 电话语言需要更专业的开发

以上要求对于没有开发能力和开发支持的运维工程师来说，难度较大。

所以我们这里选择专业的报警平台就可以帮助实现一体化报警方案。



如:onealeart   参考:http://www.onealert.com/

请先申请一个账号,绑定邮箱,手机,微信等(过程省略)。



登录进去后,按如下图示操作

![1568533070324](zabbix图片/onealert新版-1)

## 报警平台增加zabbix应用

![1568533415668](zabbix图片/onealert新版-2)



![1568533560005](zabbix图片/onealert新版-3.png)





![1568533629600](zabbix图片/onealert新版-4.png)

## server上安装报警agent

![1568534140237](zabbix图片/onealert新版-5.png)

**按照提示进行安装**

```powershell
[root@server ~]# cd /usr/lib/zabbix/alertscripts
[root@server alertscripts]# wget https://download.aiops.com/ca_agent/zabbix/ca_zabbix_release-2.1.0.tar.gz

[root@server alertscripts]# tar xf ca_zabbix_release-2.1.0.tar.gz
[root@server alertscripts]# cd cloudalert/bin/

[root@server bin]# bash install.sh 2842d6d7-f7a1-fb97-254d-9be972403dd0
start to create config file...
Zabbix管理地址: http://10.1.1.11/zabbix
Zabbix管理员账号: admin
Zabbix管理员密码: 
......
```

## 验证安装

配置完onealert后，我们可以验证下它安装后到底对zabbix做了啥。简单来说，它做了三件事:

1. 增加了一个报警动作
2. 增加了一个用户和一个用户组用于报警
3. 增加了一个报警媒介类型

### 验证动作

![1579238479690](zabbix图片/zabbix78.png)

### 验证用户

![1579238051894](zabbix图片/zabbix76.png)

![1579238251598](zabbix图片/zabbix77.png)

### 验证报警媒介

![1579237930087](zabbix图片/zabbix75.png)

### 验证报警脚本

以下脚本看不懂没关系，我们只要知道是对接报警平台的API接口就OK了

~~~powershell
[root@server bin]# cat /usr/lib/zabbix/alertscripts/cloudalert/bin/alert.sh
#!/bin/bash
# PATH
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
echo $DIR
source $DIR/log.sh
$(log INFO ZabbixActionParams "$3")
r=`curl -H "Content-Type:application/json"  -X POST -d "$3" http://api.aiops.com/alert/api/event/zabbix/v3`
$(log INFO ItsmAlertResponse "$r")
~~~



把以上验证的内容再连成一条复习一下:

**监控项** --》**图形** --》**触发器** --》**动作** --》**用户** --》**报警媒介** --》**报警脚本** --》**报警平台**



## 配置通知策略

在报警平台按需求配置通知策略(过程省略)

我这里主要配置的是任务时间任务报警立刻发送到我所绑定的邮箱，微信，手机短信，手机电话。

![1579239739000](zabbix图片/zabbix79.png)

## 触发器触发报警

这里以前面配置过的"**登录用户数大于20个**"这个触发器来测试报警.

**注意:** ==要触发器有状态变化才能报警==。

如果在测试前就已经大于20个了是不会报警的，需要先降到20以下，再升到20以上让其触发。

![1579247441452](zabbix图片/zabbix80.png)



![1579248035419](zabbix图片/zabbix81.png)









# 十一、自动化批量监控

我们要监控的服务器数量很大的情况下，如何批量操作:

* 系统使用cobbler批量安装
* zabbix-agent安装与配置可以使用cobbler的postscript脚本实现，或者使用ansible来实现
* 监控主机元素: 监控项，图形，触发器等，统一使用模板



因为创建监控主机和添加模板都需要web界面操作，如何自动批量做?

答案: 自动发现或自动注册。



## 自动发现或自动注册

**自动发现:** 由Zabbix Server开启发现进程，每隔一段时间扫描网络中符合条件的主机。

**自动注册:** 与自动发现相反由Zabbix agent去找Server注册。

所以大家看到，和前面提过的主动监控与被动监控的概念很类似。



**自动发现案例:**

前面早就准备了一台agent2，一直还没使用，这里就尝试自动发现这台agent2，并通过动作将其创建为监控主机并添加模板。

### 1, agent2上安装zabbix-agent

~~~powershell
[root@agent2 ~]# yum install zabbix-agent
~~~

### 2, 配置agent端并启动服务

配置`/etc/zabbix/zabbix_agentd.conf`配置文件，配置结果如下:

~~~powershell
[root@agent2 ~]# egrep -vn '^#|^$' /etc/zabbix/zabbix_agentd.conf
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
98:Server=10.1.1.11
139:ServerActive=10.1.1.11
150:Hostname=agent2
290:Include=/etc/zabbix/zabbix_agentd.d/*.conf
~~~

~~~powershell
[root@agent2 ~]# systemctl restart zabbix-agent
[root@agent2 ~]# systemctl enable zabbix-agent

[root@agent2 ~]# netstat -ntlup |grep :10050
tcp     0  0 0.0.0.0:10050      0.0.0.0:*       LISTEN      20447/zabbix_agentd
tcp6    0  0 :::10050           :::*            LISTEN      20447/zabbix_agentd
~~~

**再次说明: 在自动化运维体系里可以使用cobbler的postscript脚本或ansible来批量做以上2步**



### 3, 配置并启用自动发现规则

![1579255244884](zabbix图片/zabbix82.png)

![1579255475816](zabbix图片/zabbix83.png)

![1579255633099](zabbix图片/zabbix84.png)



![1579255684336](zabbix图片/zabbix85.png)

### 4, 确认自动发现到主机

![1579256658573](zabbix图片/zabbix86.png)

### 5, 配置动作实现自动监控

![1579262645161](zabbix图片/zabbix87.png)

![1579263327305](zabbix图片/zabbix88.png)

![1579263535785](zabbix图片/zabbix89.png)

![1579263637401](zabbix图片/zabbix90.png)

### 6, 确认动作更新并启用

![1579263687621](zabbix图片/zabbix91.png)

### 7, 验证最终效果

确认时间同步, 需要耐心等待一段时间。(可能几分钟到十几分钟)

最终效果如下:

![1579263963810](zabbix图片/zabbix92.png)



**问题:** agent2上的"登录用户数"这个监控项的图形上没有数据, 为什么? 如何解决?



**自动注册就不再演示了，仅了解即可。**



## 批量操作

把大量的服务器实现了自动监控后，后续还可能会做一些相关的批量操作，如:

* 批量启用主机
* 批量禁用主机
* 批量删除主机

![1579265383260](zabbix图片/zabbix93.png)

**说明:**

*  因为我们建议使用模板来管理监控，所以批量更新功能也可以直接更新模板即可
* 导出功能在当前版本经测试只能导出单个主机的配置信息为`.xml`格式文件

## 导出导出

辛苦配置好的模板或主机，如果被误删除了怎么办? 或者我想搭建多个zabbix服务器，那么又要辛苦再配置一遍？

解决方法就是把配置的模板或主机导出成`.xml`格式文件，主要有两大好处:

* **备份**(防止误删除)
* **迁移**(导出后, 导入到另一个服务器)

![1579266298631](zabbix图片/zabbix94.png)



![1579266464078](zabbix图片/zabbix95.png)

![1579267456135](zabbix图片/zabbix96.png)

![1579267742833](zabbix图片/zabbix97.png)



![1579267805127](zabbix图片/zabbix98.png)



# 十二、zabbix代理

## zabbix proxy应用场景

参考: https://www.zabbix.com/documentation/current/manual/distributed_monitoring/proxies



![1579329775005](zabbix图片/zabbix99.png)

**应用场景1: 跨内外网监控**

当zabbix server与被监控机器不在同一个机房时,跨公网监控会很麻烦, 也会带来安全隐患

* 比如有防火墙的情况,需要防火墙开放的端口增多
* 像mysql数据库这类应用是不适合直接被公网连接的



**应用场景2: 分布式监控**

当监控机主机特别多,甚至分散在不同的地域机房。这个时候zabbix server压力很大，所以可以通过增加zabbix proxy来代理收集每个机房里的主机信息，再统一给zabbix server.

![1579329871119](zabbix图片/zabbix100.png)

## zabbix proxy案例

**环境准备:**



![1579331331190](zabbix图片/zabbix101.png)

1, **新增一台新服务器做proxy，修改主机名**

~~~powershell
[root@proxy ~]# hostnamectl set-hostname --static proxy
~~~

2, **==四台服务器全部==重新绑定主机名**

~~~powershell
# vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.1.11  server
10.1.1.12  agent1
10.1.1.13  agent2
10.1.1.14  proxy
~~~

3, 确认关闭防火墙,selinux

4, 确认时间同步

5, proxy上添加zabbix源

~~~powershell
[root@proxy ~]# vim /etc/yum.repos.d/zabbix.repo

[zabbix]
name=zabbix
baseurl=https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/4.4/rhel/7/x86_64/
enabled=1
gpgcheck=0
[zabbix_deps]
name=zabbix_deps
baseurl=https://mirrors.tuna.tsinghua.edu.cn/zabbix/non-supported/rhel/7/x86_64/
enabled=1
gpgcheck=0
~~~







**操作步骤:**

### 1, 在proxy上安装软件包

~~~powershell
[root@proxy ~]# yum install mariadb-server zabbix-proxy-mysql zabbix-agent -y
~~~

### 2, 启动数据库并建库授权

~~~powershell
[root@zabbixproxy ~]# systemctl restart mariadb
[root@zabbixproxy ~]# systemctl enable mariadb

[root@zabbixproxy ~]# mysql

MariaDB [(none)]> create database zabbix_proxy default charset utf8;
MariaDB [(none)]> grant all privileges on zabbix_proxy.* to 'zabbix'@'localhost' identified by '123';
MariaDB [(none)]> flush privileges;
MariaDB [(none)]> quit
~~~

### 3, 导入proxy数据并验证

~~~powershell
[root@proxy ~]# zcat /usr/share/doc/zabbix-proxy-mysql-4.4.4/schema.sql.gz |mysql zabbix_proxy -u zabbix -p123

[root@proxy ~]# mysql -e 'use zabbix_proxy; show tables' 
~~~

### 4, 修改proxy端配置并启动服务

~~~powershell
[root@proxy ~]# egrep -vn '^#|^$' /etc/zabbix/zabbix_proxy.conf
30:Server=10.1.1.11						修改为zabbix服务器的ip
49:Hostname=proxy						修改为本代理服务器的主机名
91:LogFile=/var/log/zabbix/zabbix_proxy.log
102:LogFileSize=0
143:PidFile=/var/run/zabbix/zabbix_proxy.pid
153:SocketDir=/var/run/zabbix
173:DBName=zabbix_proxy
188:DBUser=zabbix
196:DBPassword=123				打开注释并修改为连接数据库的密码,和上面授权对应
250:ConfigFrequency=60			proxy多久从server接收一次配置数据(打开注释并修改)
259:DataSenderFrequency=5		proxy多久发送一次收集的数据给server(打开注释并修改)
406:SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
482:Timeout=4
525:ExternalScripts=/usr/lib/zabbix/externalscripts
561:LogSlowQueries=3000
667:StatsAllowedIP=127.0.0.1

[root@proxy ~]# systemctl restart zabbix-proxy
[root@proxy ~]# systemctl enable zabbix-proxy
~~~

**说明:** `ConfigFrequency=60`和`DataSenderFrequency=5`这两个参数需要配置，否则最终结果会很久都看不到数据。



### 5, 配置agent端

除了agent1和agent2之外,server和proxy也可以被监控, 也就是说一共4台都可以被监控。

这4台都可以被proxy监控，也可以被server监控。本实验我选择以下方案:

* server监控自己(默认不变), proxy,agent1,agent2都被proxy监控，然后将数据给server

所以==proxy,agent1,agent2这3台都做如下操作==:

~~~powershell
# egrep -vn '^#|^$' /etc/zabbix/zabbix_agentd.conf
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
98:Server=10.1.1.14							修改为proxy的IP,而不是server的IP
139:ServerActive=10.1.1.14					修改为proxy的IP,而不是server的IP
150:Hostname=XXX							主机名分别为proxy,agent1,agent2
290:Include=/etc/zabbix/zabbix_agentd.d/*.conf
318:UserParameter=loginusers,who | wc -l	都加上此自定义监控项

# systemctl restart zabbix-agent
~~~

### 6, 创建proxy为被监控主机

![1579339965115](zabbix图片/zabbix102.png)



![1579340332089](zabbix图片/zabbix103.png)



![1579340398884](zabbix图片/zabbix104.png)

### 7, 为3台被代理机添加模板

![1579340647921](zabbix图片/zabbix105.png)



![1579340731476](zabbix图片/zabbix106.png)

![1579341091375](zabbix图片/zabbix107.png)

### 8, 创建proxy为代理

![1579341822578](zabbix图片/zabbix108.png)



![1579343588288](zabbix图片/zabbix109.png)

### 9, 批量更新代理

![1579343844743](zabbix图片/zabbix110.png)



![1579343895493](zabbix图片/zabbix111.png)

![1579344314901](zabbix图片/zabbix112.png)

### 10, 验证

在被代理监控机上(agent1,agent2,proxy)做信息的改变, 比如改变登录用户数，然后在web管理界面的图形上能查看到相应变化，则表示代理一切OK。

过程省略, 请自行验证.



# 十三、主动监控与被动监控

**一共有4种模式:**

1. agent主动
2. agent被动(默认)
3. proxy主动(默认)
4. proxy被动



## agent被动

相对于agent的被动,也就是表示是server或proxy去找agent拿数据。

~~~powershell
# grep -n ^Server= /etc/zabbix/zabbix_agentd.conf
98:Server=10.1.1.14					agent被动模式, IP为server或proxy的IP
~~~

## agent主动

相对于agent的主动, 也就是表示是agent主动把数据传给server或proxy

**优点:**  当agent太多的情况下, server或proxy去找这么多agent搜集数据, 压力负载过大。用agent主动模式就可以缓解server或proxy的压力。

但用主动模式的问题是: 监控项也要转为主动式.

![1579354937008](zabbix图片/zabbix128.png)



![1579355081914](zabbix图片/zabbix129.png)



![1579355176776](zabbix图片/zabbix130.png)

![1579355227441](zabbix图片/zabbix131.png)



## proxy主动与被动  

由`/etc/zabbix/zabbix_proxy.conf`里的`ProxyMode`参数决定。

![1579355540387](zabbix图片/zabbix132.png)

## 结论

默认情况下的监控方向如下图所示:



![1579353877666](zabbix图片/zabbix126.png)

上图中:

* 由server找agent拿数据
* 这种情况server端压力较大, agent端压力较小



![1579353682697](zabbix图片/zabbix127.png)

上图中:

* proxy找agent拿数据,又主动将agent的数据提交给server
* proxy压力最大



个人推荐默认的模式，完全不用修改。请讨论或思考为什么? 什么情况才有可能需要修改模式?



# 十四、web监测(拓展补充)

**web监测**: 类似一个大监控项(可以包含多个小监控项),主要针对web服务器做监控场景。

可以对一个url页面进行监测（监测它的状态码,页面匹配的字符串,响应时间,下载速度等）



## 1, 在agent1上创建web监测

![1579348087966](zabbix图片/zabbix113.png)

## 2, 创建web场景

![1579348141193](zabbix图片/zabbix114.png)



![1579348558182](zabbix图片/zabbix115.png)

## 3, 添加步骤一

![1579349008676](zabbix图片/zabbix116.png)



![1579349978178](zabbix图片/zabbix117.png)

![1579350224838](zabbix图片/zabbix118.png)

## 4, 添加步骤二

![1579350272676](zabbix图片/zabbix119.png)



![1579350508846](zabbix图片/zabbix120.png)



![1579350591228](zabbix图片/zabbix121.png)



![1579350860502](zabbix图片/zabbix122.png)

## 5, 验证步骤一

![1579351109094](zabbix图片/zabbix123.png)

去agent1上安装httpd,创建主页,并启动服务

~~~powershell
[root@agent1 ~]# yum install httpd -y
[root@agent1 ~]# echo web1 > /var/www/html/index.html
[root@agent1 ~]# systemctl restart httpd
[root@agent1 ~]# systemctl enable httpd
~~~

再次验证

![1579351662610](zabbix图片/zabbix124.png)

6，验证步骤二

~~~powershell
[root@agent1 ~]# echo "1111111haha22222222" > /var/www/html/test.txt
~~~

![1579352267490](zabbix图片/zabbix125.png)



**练习:** 为上面的web监测创建一个触发器,状态码不为200就触发（选监控项的时候要注意看清楚, 一个web监测会产生好几个小的监控项，选状态码的那一个）



# 十五、练习

## 监控系统

系统有4大子系统: CPU, 内存, 磁盘IO, 网络。除了这4大子系统外还有进程, 登录用户等等。

请有实力的同学在以下题目基础上做自由拓展。



1, 监控所有进程数量,并设定触发器(当大于200就警告，当大于300就严重警告，超过400个就灾难）

```powershell

```

2, 监控tcp连接数量, 并自定义触发器

```powershell

```

3, 监控某分区磁盘使用率，并自定义触发器

```powershell

```

4, 监控可用内存，并自定义触发器

```powershell

```



## 监控nginx

在前面讲模板章节中有提到zabbix4版本中有自带的nginx模板，如下图所示:

![1579357686547](zabbix图片/zabbix133.png)



**不想用自带模板的, 也可以参考以下方式自定义监控nginx：**



nginx有一个状态页，通过查看状态页信息可以连接到nginx服务负载情况.

下面我们假设监控agent1的nginx

1,在agent1上安装nginx

~~~powershell
[root@agent1 ~]# yum install epel-release
[root@agent1 ~]# yum install nginx
~~~

2,在nginx里的server{}配置段里加上下面一段，然后重启服务

~~~powershell
[root@agent1 ~]# vim /etc/nginx/nginx.conf

		location /status {
                stub_status on;
                allow 10.1.1.11; # 必须要允许zabbix server访问(或zabbix_proxy)
                allow 127.0.0.1; # 允许本机访问
                allow 10.1.1.1;	 # 加这个IP是为了windows宿主机访问用的
                deny all;
                access_log off;
        } 
        
[root@agent1 ~]# systemctl restart nginx
[root@agent1 ~]# systemctl enable nginx
~~~

3, 通过浏览器访问http://10.1.1.12/status就能看到如下nginx状态信息

~~~powershell
Active connections: 1 
server accepts handled requests
 59 59 115 
Reading: 0 Writing: 1 Waiting: 0 

Active  connections：当前所有处于打开状态的活动连接数
accepts ：已经接收连接数
handled ： 已经处理过的连接数
requests ： 已经处理过的请求数，在保持连接模式下，请求数量可能会大于连接数量

Reading: 正处于接收请求的连接数
Writing: 请求已经接收完成，处于响应过程的连接数
Waiting : 保持连接模式，处于活动状态的连接数
~~~

4, 在agent1上准备一个脚本,并给执行权限

~~~powershell
[root@agent1 ~]# vim /opt/nginx_status.sh
#!/bin/bash

HOST="127.0.0.1"
PORT="80"

function ping {						# 这个不是ping，是判断nginx进程是否存在
    /sbin/pidof nginx | wc -l
}

function active {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
}
function accepts {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
}
function handled {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
}
function requests {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
}
function reading {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
}
function writing {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
}
function waiting {
    /usr/bin/curl "http://$HOST:$PORT/status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
}
$1

[root@agent1 ~]# chmod 755 /opt/nginx_status.sh 
~~~

5, 在agent1上定义UserParameter，并重启服务

~~~powershell
在配置文件里加上下面一句
[root@agent1 ~]# vim /etc/zabbix/zabbix_agentd.conf 
UserParameter=nginx_status[*],/opt/nginx_status.sh $1

[root@agent1 ~]# systemctl restart zabbix-agent
~~~

6, 在server上(如果使用了使用proxy则这里就在proxy上操作)zabbix_get测试

~~~powershell
[root@server ~]# zabbix_get -s 10.1.1.12 -k nginx_status[ping]
1
[root@server ~]# zabbix_get -s 10.1.1.12 -k nginx_status[handled]
76
~~~

7, 测试能成功监控取到值，说明监控OK。



说明: web管理界面添加监控项的过程请自行完成, 这里省略。



## 监控mariadb

数据库能做监控项的基本都在`show status`命令里



例: 自定义监控agent1上mariadb的当前登录用户数, 并设定触发器(当大于50个就警告)

~~~powershell
[root@agent1 ~]# yum install mariadb-server -y
[root@agent1 ~]# systemctl restart mariadb
~~~

方法一:

下面这条命令就可以得到当前登录用户数，然后自定义一个UserParameter就可以了

~~~powershell
[root@agent1 ~]# mysqladmin extended-status |grep Threads_connected |awk '{print $4}'
~~~



方法二:

~~~powershell
[root@agent1 ~]# vim /etc/zabbix/zabbix_agentd.conf

UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | mysql -N | awk '{print $$2}'

[root@agent1 ~]# systemctl restart zabbix-agent
~~~

**说明:** 这句配置在zabbix3版本里`/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf`配置文件默认自带,zabbix4自带的参数不能直接对mariadb使用了,所以我们手工再加上



在server或proxy上验证，`show status`命令里的理论上都可以验证

~~~powershell
[root@proxy ~]# zabbix_get -s 10.1.1.12 -k mysql.status[Threads_connected]

[root@proxy ~]# zabbix_get -s 10.1.1.12 -k mysql.status[uptime]
~~~



## 综合场景练习

请通过上网查资料, 设计一个监控场景自由发挥.

思路步骤:

* 规则要监控的主机与业务
* 按照监控项的类型创建不同的自定义模板
* 在自定义模板中配置监控项,图形与触发器等
* 实现报警

* 配置自动发现与动作实现自动监控新主机并添加模板
* 导出模板实现备份

更大规模架构监控:

* 多台zabbix server分担主机进行监控
* 使用proxy分担server压力
* 结合cobbler和ansible实现全自动化监控

