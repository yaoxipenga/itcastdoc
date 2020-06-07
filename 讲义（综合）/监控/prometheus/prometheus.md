# **学习目标**

- [ ] 能够安装prometheus服务器

- [ ] 能够通过node_exporter监控远程linux

- [ ] 能够通过mysqld_exporter监控远程mysql

- [ ] 能够安装grafana

- [ ] 能够在grafana添加prometheus数据源

- [ ] 能够使用grafana自定义监控cpu负载

- [ ] 能够使用grafana导入json实现mysql监控

- [ ] 能够通过grafana实现报警



# 一、认识普罗米修斯

## prometheus介绍

Prometheus(普罗米修斯)是一套**开源的监控&报警&时间序列数据库**的组合, 由go语言开发。

适合监控容器平台, 因为kubernetes(俗称k8s)的流行带动了prometheus的发展。

**PS：**由于目前还未学习容器，所以在今天的课程里使用prometheus监控仍然监控物理服务器。



官方网站: https://prometheus.io/

![1579933772538](prometheus图片/prometheus官方主页.png)



## 时序数据库介绍

**数据库分类:**

* 关系型   mysql,oracle,sql server,sybase,db2,access等
* 非关系型(nosql)
  * key-value   memcache  redis   etcd
  * 文档型    mongodb  elasticsearch
  * 列式      hbase 
  * 时序     prometheus
  * 图形数据库  Neo4j



**时间序列数据**(TimeSeries Data) : 按照时间顺序记录系统、设备状态变化的数据被称为时序数据.



**时序数据主要的特点：**

* 数据带有时间属性，且数据量随着时间递增

* 大都为插入操作较多且无更新的需求，插入数据多，每秒钟插入数据可到达千万甚至是上亿条
* 分析过去时序数据可以做成多纬度报表，揭示其趋势性、规律性、异常性
* 分析时序数据趋势可以做大数据分析，机器学习，实现预测和预警
* 能够按照条件筛选数据, 也可以按照时间范围统计,聚合,展示数据



**常见应用场景**:

* 无人驾驶车辆运行中要记录的经度，纬度，速度，方向，旁边物体的距离等等。每时每刻都要将数据记录下来做分析。
* 某一个地区的各车辆的行驶轨迹数据
* 传统证券行业实时交易数据
* 实时运维监控数据等



## prometheus主要特性

![1579958886645](prometheus图片/prometheus主要特性.png)



Prometheus的主要特性有: 

1. 多维度数据模型

2. 灵活的查询语言

3. 不依赖分布式存储，单个服务器节点是自主的

4. 以HTTP方式，通过pull模型拉去时间序列数据 

5. 也可以通过中间网关支持push模型

6. 通过服务发现或者静态配置, 来发现目标服务对象

7. 支持多种多样的图表和界面展示



## pormetheus原理架构图

![1543678972185](prometheus图片/prometheus架构图.png)





# 二、prometheus监控

## 实验环境准备

![1579941001512](prometheus图片/实验环境图.png)

1. **所有服务器**静态ip(要求能上外网)

2. **所有服务器**各配置主机名并绑定

~~~powershell
各自配置好主机名
# hostnamectl set-hostname --static server
三台都互相绑定IP与主机名
# vim /etc/hosts			
10.1.1.11  server
10.1.1.12  agent1
10.1.1.13  grafana
~~~

3. **所有服务器**时间同步(**时间同步一定要做**)

~~~powershell
# systemctl restart ntpd
# systemctl enable ntpd
~~~

4. **所有服务器**关闭防火墙,selinux

~~~powershell
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F
~~~




## 安装prometheus

下载地址:  https://prometheus.io/download/ (请使用共享的软件版本，以免出现不兼容问题)



1, 二进制版解压就能用，不需要编译.

~~~powershell
[root@server ~]# tar xf prometheus-2.5.0.linux-amd64.tar.gz -C /usr/local/
[root@server ~]# mv /usr/local/prometheus-2.5.0.linux-amd64/ /usr/local/prometheus
~~~

配置文件说明

~~~powershell
[root@server ~]# egrep -n : /usr/local/prometheus/prometheus.yml | awk -F'#' '{print $1}'
2:global:								全局配置段
3:  scrape_interval:     15s			每15s抓取(采集)数据一次
4:  evaluation_interval: 15s			每15秒计算一次规则
8:alerting:								Alertmanager报警相关
9:  alertmanagers:
10:  - static_configs:
11:    - targets:
12:
15:rule_files:							规则文件列表
19:
21:scrape_configs:						抓取的配置文件(也就是监控的实例)
23:  - job_name: 'prometheus'			监控的实例名称
28:    static_configs:
29:    - targets: ['localhost:9090']	监控的实例IP与端口,在这里为监控服务器本身
~~~

2, 直接使用默认配置文件启动, 建议加`&`后台符号


~~~powershell
[root@server ~]# /usr/local/prometheus/prometheus --config.file="/usr/local/prometheus/prometheus.yml" &
~~~

3, 验证9090端口

~~~powershell
[root@server ~]# netstat -ntlup |grep :9090
tcp6    0   0 :::9090          :::*             LISTEN      64950/prometheus
~~~



## prometheus界面

1, 通过浏览器访问**http://服务器IP:9090**就可以访问到prometheus的主界面

![1543244447650](prometheus图片/主界面.png)

2, 点Status --》点Targets --》可以看到只监控了本机  (默认只监控了本机一台)

![1543246024896](prometheus图片/监控的目标.png)3, 通过**http://服务器IP:9090/metrics**可以查看到监控的数据

**说明:** 这里的metrics你可以类比成zabbix里的监控项。

![1543246609467](prometheus图片/监控项数据.png)



4, 在web主界面可以通过关键字查询metrics, 并显示图形

![1543246563254](prometheus图片/通过表达式查询.png)







虽然prometheus服务器通过9090端口能监控一些metrics，但像cpu负载等这些linux常见的监控项却没有，需要node_exporter组件。

node_exporter组件可以安装在本机或远程linux主机上。



## 监控远程linux主机

**1, 在远程linux主机(被监控端agent1)上安装node_exporter组件**

下载地址: https://prometheus.io/download/ (请使用共享的软件版本，以免出现不兼容问题)

~~~powershell
[root@agent1 ~]# tar xf node_exporter-0.16.0.linux-amd64.tar.gz -C /usr/local/
[root@agent1 ~]# mv /usr/local/node_exporter-0.16.0.linux-amd64/ /usr/local/node_exporter
[root@agent1 ~]# ls /usr/local/node_exporter/
LICENSE  node_exporter  NOTICE
~~~

**2, 启动node_exporter, 并验证端口**

~~~powershell
[root@agent1 ~]# nohup /usr/local/node_exporter/node_exporter &
~~~

说明: 如果把启动node_exporter的终端给关闭,那么进程也可能会随之关闭。nohup命令可以挂起在后台，除非杀掉相关进程，否则不会随终端关闭而关闭进程。

**3, 验证9100端口**

~~~powershell
[root@agent1 ~]# netstat -ntlup |grep 9100
tcp6    0   0 :::9100         :::*          LISTEN      74755/node_exporter
~~~

**nohup**命令: 如果把启动node_exporter的终端给关闭,那么进程也可能会随之关闭。nohup命令可以挂起在后台，除非杀掉相关进程，否则不会随终端关闭而关闭进程。

**4, 浏览器访问http://被监控端IP:9100/metrics就可以查看到node_exporter在被监控端收集的metrics**

![1543286036926](prometheus图片/被监控端监控项数据.png)

**5, 回到prometheus服务器的配置文件里添加被监控机器的配置段**

说明: 其它都不变,只添加了最后3行配置.==注意YAML格式要求==。

~~~powershell
[root@server ~]# egrep -n : /usr/local/prometheus/prometheus.yml | awk -F'#' '{print $1}'
2:global:
3:  scrape_interval:     15s
4:  evaluation_interval: 15s
8:alerting:
9:  alertmanagers:
10:  - static_configs:
11:    - targets:
12:
15:rule_files:
19:
21:scrape_configs:
23:  - job_name: 'prometheus'
24:    static_configs:
25:    - targets: ['localhost:9090']
26:  - job_name: 'agent1'				最后加上这三行，取一个job名称来代表被监控的机器
27:    static_configs:						
28:    - targets: ['10.1.1.14:9100']	这里改成被监控机器的IP，后面端口接9100
~~~

**6，改完配置文件后,重启服务**

说明: 没有服务脚本，直接kill杀掉进程,再重启即可。

~~~powershell
[root@server ~]# pkill prometheus
[root@server ~]# netstat -ntlup |grep 9090			确认端口没有进程占用

[root@server ~]# /usr/local/prometheus/prometheus --config.file="/usr/local/prometheus/prometheus.yml" &

[root@server ~]# netstat -ntlup |grep 9090			确认端口被占用，说明重启成功
tcp6    0    0 :::9090       :::*         LISTEN      32651/prometheus
~~~

**7，回到web管理界面 --》点Status --》点Targets --》可以看到多了一台监控目标**

![1580375618719](prometheus图片/查看被监控端是否被成功监控.png)

**练习:**

前面实现了prometheus监控本机9090, 但是还有很多metrics无法监控，比如cpu负载信息等。这个时候我们在prometheus服务器上也安装node_exporter，并监控。

请自行实现，最终配置文件如下:

~~~powershell
[root@server ~]# egrep -n : /usr/local/prometheus/prometheus.yml | awk -F'#' '{print $1}'
2:global:
3:  scrape_interval:     15s
4:  evaluation_interval: 15s
8:alerting:
9:  alertmanagers:
10:  - static_configs:
11:    - targets:
12:
15:rule_files:
19:
21:scrape_configs:
23:  - job_name: 'prometheus'
24:    static_configs:
25:    - targets: ['localhost:9090']
26:  - job_name: 'agent1'
27:    static_configs:
28:    - targets: ['10.1.1.12:9100']
29:  - job_name: 'server'					其它不变,添加了最后3行
30:    static_configs:
31:    - targets: ['10.1.1.11:9100']
~~~





## 监控远程mysql

**1,在被管理机agent1上安装mysqld_exporter组件**

下载地址: https://prometheus.io/download/ (请使用共享的软件版本，以免出现不兼容问题)

~~~powershell
[root@agent1 ~]# tar xf mysqld_exporter-0.11.0.linux-amd64.tar.gz -C /usr/local/
[root@agent1 ~]# mv /usr/local/mysqld_exporter-0.11.0.linux-amd64/ /usr/local/mysqld_exporter
[root@agent1 ~]# ls /usr/local/mysqld_exporter/
LICENSE  mysqld_exporter  NOTICE
~~~

**2, 在agent1上安装mariadb并启动,用于被监控**

~~~powershell
[root@agent1 ~]# yum install mariadb-server -y
[root@agent1 ~]# systemctl restart mariadb
[root@agent1 ~]# systemctl enable mariadb
~~~

**3, 授权**

说明: 授权ip为localhost，因为不是prometheus服务器来直接找mariadb获取数据，而是prometheus服务器找mysqld_exporter,mysqld_exporter再找mariadb。所以这个localhost是指的mysql_exporter的IP

~~~powershell
[root@agent1 ~]# mysql

MariaDB [(none)]> grant select,replication client,process ON *.* to 'mysql_monitor'@'localhost' identified by '123';

MariaDB [(none)]> flush privileges;

MariaDB [(none)]> quit
~~~

**4, 创建连接mariadb配置文件**

说明: 配置文件里写上连接mariadb的用户名与密码(和上面的授权的用户名和密码要对应)

~~~powershell
[root@agent1 ~]# vim /usr/local/mysqld_exporter/.my.cnf
[client]
user=mysql_monitor
password=123
~~~

**5, 启动mysqld_exporter并验证9104端口**

~~~powershell
[root@agent1 ~]# nohup /usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my.cnf &

[root@agent1 ~]# netstat -ntlup |grep 9104
tcp6   0    0 :::9104       :::*          LISTEN      73358/mysqld_export
~~~

**6, 回到prometheus服务器的配置文件里添加被监控的mariadb的配置段**

~~~powershell
[root@server ~]# egrep -n : /usr/local/prometheus/prometheus.yml | awk -F'#' '{print $1}'
2:global:
3:  scrape_interval:     15s
4:  evaluation_interval: 15s
8:alerting:
9:  alertmanagers:
10:  - static_configs:
11:    - targets:
12:
15:rule_files:
19:
21:scrape_configs:
23:  - job_name: 'prometheus'
24:    static_configs:
25:    - targets: ['localhost:9090']
26:  - job_name: 'agent1'
27:    static_configs:
28:    - targets: ['10.1.1.14:9100']
29:  - job_name: 'server'
30:    static_configs:
31:    - targets: ['10.1.1.13:9100']
32:  - job_name: 'agent1_mariadb'			加上这3句,取一个job名称来代表被监控的mariadb
33:    static_configs:
34:    - targets: ['10.1.1.14:9104']		这里改成被监控机器的IP，后面端口接9104

~~~

**7, 重启服务**

~~~powershell
[root@server ~]# pkill prometheus
[root@server ~]# netstat -ntlup |grep 9090

[root@server ~]# /usr/local/prometheus/prometheus --config.file="/usr/local/prometheus/prometheus.yml" &

[root@server ~]# netstat -ntlup |grep 9090
tcp6    0    0 :::9090       :::*         LISTEN      76661/prometheus
~~~



**8, 回到web管理界面 --》点Status --》点Targets --》可以看到监控mariadb了**

![1580375715668](prometheus图片/监控mysql.png)

![1580375906739](prometheus图片/监控mysql2.png)



# 三、grafana

## grafana介绍

 Grafana是一个开源的度量分析和可视化工具，可以通过将采集的数据分析，查询，然后进行可视化的展示,并能实现报警。

![1580392092293](prometheus图片/grafana官网介绍.png)

官方网址: https://grafana.com/



## grafana安装与登录

在grafana服务器上安装grafana

下载地址:https://grafana.com/grafana/download  (请使用共享的软件版本，以免出现不兼容问题)



1, 拷贝软件包到grafana服务器上安装

~~~powershell
[root@grafana ~]# rpm -ivh grafana-6.5.3-1.x86_64.rpm
~~~

2, 启动服务

~~~powershell
[root@grafana ~]# systemctl start grafana-server
[root@grafana ~]# systemctl enable grafana-server
~~~

3, 验证端口

~~~powershell
[root@grafana ~]# netstat -ntlup |grep :3000
tcp6  0   0 :::3000          :::*          LISTEN      60845/grafana-serve
~~~



4, 通过浏览器访问 **http://`grafana服务器IP`:3000**登录,使用默认的admin用户,admin密码就可以登陆了

![1543295339031](prometheus图片/grafana登陆界面.png)

## 设置prometheus为grafana数据源

把prometheus服务器收集的数据做为数据源添加到grafana,让grafana可以得到prometheus的数据。

![1543295892083](prometheus图片/增加数据源.png)

![1580450824907](prometheus图片/增加数据源1.png)

![1580451161525](prometheus图片/增加数据源2.png)



![1580455210078](prometheus图片/增加数据源3.png)



![1580455270162](prometheus图片/增加数据源4.png)

## grafana实现自定义监控cpu负载

**为添加好的数据源做图形显示**

![1580459483389](prometheus图片/创建图形1.png)

![1580459603722](prometheus图片/创建图形1-2.png)

![1580459761159](prometheus图片/创建图形1-3.png)



![1580459991199](prometheus图片/创建图形2.png)

**保存**

![1580460060906](prometheus图片/创建图形4.png)

**最后在dashboard可以查看到**

![1580460173914](prometheus图片/创建图形5.png)

 

**匹配条件显示**

![1580460354871](prometheus图片/匹配条件显示.png)





## 导入json模板实现mysql监控

根据上面的思路，我们可以将`mysql_global_status_threads_connected`这个metrics加到dashboard实现对mysql数据库的当前连接数的监控。

但是mysql需要监控的状态非常的多(`mysql> show status`得到的状态信息几乎都可以监控)，一个个的手动添加太累了。有没有类似zabbix里的模板那种概念呢?  

答案是有的,需要开发人员开发出相应的json格式的模板,然后导入进去就可以了。那么问题来了,谁开发?

有这么几种途径:

* 如果公司有这方面的专业开发支持，就可以实现定制化的监控, 运维工程师配合就好
* 当然运维工程师也可以学习并实现这方面的开发
* 寻找别人开发好的开源项目

grafana-dashboards就是这样的开源项目

参考网址: https://github.com/percona/grafana-dashboards



**1, 下载grafana-dashboards开源项目**

~~~powershell
# git clone https://github.com/percona/grafana-dashboards.git
说明: 学习完git与github相关课程后就明白为什么会这样下载了
~~~

因为github下载网速非常慢, 我这里已经下载好了共享给大家

![1580569852327](prometheus图片/grafana-dashboards.png)



**2，在grafana图形界面导入相关json文件**

![1580569234271](prometheus图片/导入mysql的json文件.png)

![1580569444059](prometheus图片/导入mysql的json文件1.png)



![1580569535504](prometheus图片/导入mysql的json文件2.png)



**3, 导入后,刷新就有数据了(如下图所示)**  

![1580569682857](prometheus图片/查看mysql监控信息.png)





# 四、grafana+onealert报警

prometheus报警需要使用alertmanager这个组件，而且报警规则需要手动编写(对运维来说不友好)。所以我这里选用grafana+onealert报警。

注意: 实现报警前把所有机器**==时间同步==**再检查一遍.



## grafana对接onealert

**1, 在onealert里添加grafana应用(申请onealert账号在zabbix已经讲过)**

http://www.onealert.com

![1568623160170](prometheus图片/onealert.png)

![1568623529894](prometheus图片/onealert添加granfa.png)

![1580570031569](prometheus图片/onealert添加granfa2.png)



**2, 配置通知策略**

![1568623797665](prometheus图片/onealert配置通知策略.png)



**3, 在grafana增加通知通道**

![1580570101991](prometheus图片/onealert添加granfa2-2.png)

![1580570202126](prometheus图片/granfa添加通知通道.png)



![1580570563343](prometheus图片/granfa添加通知通道2.png)



![1543676056834](prometheus图片/granfa添加通知通道3.png)

## 测试cpu负载报警

**1, 创建alert**

![1580570669586](prometheus图片/报警测试.png)

**2, 自定义报警规则**

![1580571105371](prometheus图片/报警测试2.png)



![1580571306279](prometheus图片/报警测试3.png)

**3, 在被监控机上加大cpu负载(如写个死循环的shell计算脚本让其执行)，然后测试报警**

![1543677287856](prometheus图片/报警测试4.png)



**4, 最终的邮件报警效果**

![1543678019297](prometheus图片/报警测试6.png)



## **测试mysql连接数报警**

**1, 创建alert**

![1548321435039](prometheus图片/mysql链接数报警0.png)

![1543741346238](prometheus图片/mysql链接数报警1.png)



![1548322466548](prometheus图片/mysql链接数报警2.png)



![1548326398846](prometheus图片/mysql链接数报警2-2.png)



**2, 自定义报警规则**

![1548322567131](prometheus图片/mysql链接数报警3.png)



![1548322567131](prometheus图片/mysql链接数报警4.png)



**3, 加大mysql连接数(可通过多个终端使用mysql命令登录模拟)，然后测试报警**

![1548322567131](prometheus图片/mysql链接数报警5.png)



**4, 邮件报警结果**

![1548322567131](prometheus图片/mysql链接数报警6.png)



## 总结报警不成功的可能原因

- 各服务器之间时间不同步，这样时序数据会出问题，也会造成报警出问题
- 必须写通知内容，留空内容是不会发报警的
- 修改完报警配置后，记得要点右上角的保存
- 保存配置后，需要由OK状态变为alerting状态才会报警(也就是说，你配置保存后，就已经是alerting状态是不会报警的)
- grafana与onealert通信有问题



# 五、课外扩展

prometheus目前还在发展中，很多相应的监控都需要开发。但在官网的dashboard库中,也有一些官方和社区开发人员开发的dashboard可以直接拿来用。

地址为: https://grafana.com/grafana/dashboards

![1548343742261](prometheus图片/grafana-dashboards下载.png)

**示例:**

![1548335365112](prometheus图片/监控dashboard展示.png)

![1548335440541](prometheus图片/dashboard展示2.png)

**有兴趣的同学可以下载几个尝试一下(不一定版本兼容,如果不兼容，可多试几个不同版本)**





