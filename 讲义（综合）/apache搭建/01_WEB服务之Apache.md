---
typora-root-url: ..\..\pictures
---

### 项目背景

初创小公司，随着业务不断增长，用户基数越来越大，为更好满足用户体验，开发人员提一个工单过来，需要运维人员给开发人员部署一套**预发布环境**（和生产环境保持一致），保证开发人员高效的进行预发布测试等工作。

![lamp预发布环境](/lamp预发布环境.png)

### 具体要求

- **源码**部署LAMP环境，和生产保持一致
- 静态资源文件同步生产环境（生产发生改变立马同步到预发布平台）

### 涉及知识点

- **==源码部署LAMP环境（重点）==**
- NFS文件共享（旧）
- rsync同步静态资源（旧）
- ==虚拟主机的配置（新）==
- 用户认证访问控制（新）
- ==Apache的安全认证（新）==

### 理论知识

#### 一、WEB服务概述

**web服务是我们日常使用最多的服务，所有的网站都是以web服务的形式为我们呈现**

##### 1. WEB服务的特点

服务的架构：

**C/S:**FTP SAMBA SSH	(一般应用于局域网中)

**B/S：**apache、nginx（一般应用于互联网中）

- web服务分为客户端和服务端

- web客户端通常是我们所使用的**浏览器**（IE/Chrome/Firefox/Safari或者命令行浏览器等）

- **web服务端**就是我们所访问的网站提供的**web服务器**

  - 常见的web服务端程序有：

    ==Apache（httpd）==/Nginx/Tengine/Lighttpd/IIS等，不同的web服务针对不同的系统平台各自有优缺点

#####2. HTTP协议

- web服务端与客户端是通过HTTP协议（HyperText Transfer Protocol）超文本传输协议进行交互

![http协议](/http协议.png)

- Apache或Nginx都**==只==**支持**==静态页面==**的解析

##### 3. 静态页面和动态页面

- HTML语言
  - HTML（HyperText Markup Language）超文本标记语言，是绝大多数网页使用的语言，几乎所有的网页都是以HTML作为源代码，通过浏览器解释后展现出来
  - HTML有固定语法，用来存储网页数据，定义不同元素，如文字、标题、图片等，现在的网页都用CSS语言来存储网页的表现形式
  - 现代主流的网页设计架构：
    ​    内容存储：HTML
    ​    网页架构：div
    ​    网页样式：css
  - HTML形式的页面我们称之为**静态页面**，包含一些图片、文本、表格等
- 动态语言
  - 网站使用特定的语言编写的一些程序，在用户访问的时候==基于不同的条件生成==不同的HTML代码返回给用户浏览器，这样就实现网页的动态化。	
  - 常见的动态语言： .php  .jsp   .cgi   .asp、python等

##### 4. WEB服务的中间件

- php:   ==**PHP-FPM**==



![1575600113565](/../05_Linux下WEB项目实战(源码构建LAMP)/01_笔记/01_WEB服务之Apache.assets/1575600113565.png)



- jsp:    ==**Tomcat**==、JBOSS、Resin、IBM WebSphere



![1575600130704](/../05_Linux下WEB项目实战(源码构建LAMP)/01_笔记/01_WEB服务之Apache.assets/1575600130704.png)







##### 5.常见的WEB组合方式

- ==LAMP    (Linux + Apache + MySQL + PHP)==                  php作为Apache的模块
- LNMP    (Linux + Nginx + MySQL + PHP)                    php-fpm进程（服务）
- Nginx /Apache+ Tomcat 







#### 二、Apache的介绍

- 美国少数民族
- 军用直升机
- 基金会

**Apache(httpd)是著名的web服务器软件，开源，由apache软件基金会负责管理开发。**

![Apache](/Apache.png)

##### 1. Apache服务特点

- 开放源码
- 跨平台
- 支持多种编程语言
- 采用模块化设计
- 安全稳定

##### 2. Apache的工作原理

![apache解析过程](/apache解析过程.png)

1. Apache只能够解析静态页面
2. 如果需要访问动态页面，==Apache调用libphp5.so模块==帮助解析，然后Apache将解析的结果返回用户

##### 3. Apache的官网和手册

- www.apache.org

- 英文手册：需要安装

  ```powershell
  httpd-manual.noarch			//安装后启动服务就可以本地查看
  yum -y install httpd-manual.noarch	
  service httpd restart
  查看官方手册：
  IE：http://10.1.1.1/manual
  
  ```

- 中文手册参考：http://www.jinbuguo.com/apache/menu22/index.html

##### 4. Apache的软件包

- 软件包：	httpd-2.2  httpd-2.4

##### 5. Apache相关文件介绍

~~~powershell
服务端口：
80/tcp(http)	443/tcp http+ssl(	https)

配置文件：
/etc/httpd/conf							主配置文件目录  
/etc/httpd/conf.d/*.conf  				子配置文件目录
/etc/httpd/conf.d/README				说明书
/etc/httpd/conf.d/welcome.conf		当没有首页index.html 显示红帽欢迎页面
/etc/httpd/conf/httpd.conf      		主配置文件
/etc/httpd/logs                 		日志目录 /var/log/httpd/硬链接
/etc/httpd/modules              		库文件 /usr/lib64/httpd/modules硬链接
/etc/httpd/run                  		pid信息
/etc/logrotate.d/httpd          		日志轮循
/etc/rc.d/init.d/httpd          		启动脚本
/etc/sysconfig/httpd            		额外配置文件
/usr/lib64/httpd               
/usr/lib64/httpd/modules        		库文件
/usr/lib64/httpd/modules/mod_actions.so
/usr/sbin/apachectl             		apache官方启动脚本
/usr/sbin/httpd
/var/www                        		apache数据目录
/var/www/cgi-bin                		存放apache的cgi脚本程序的数据目录
/var/www/html		              		存放apache的html数据目录
/var/www/error                 
/var/www/error/HTTP_NOT_FOUND.html.var    404
/var/www/error/HTTP_FORBIDDEN.html.var    403

~~~

##### 6. Apache主配置文件

~~~powershell
vim /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"								服务主目录
Listen 80												监听端口
IncludeOptional conf.d/*.conf						包含conf.d下的*.conf文件
User apache												运行Apache的用户
Group apache											运行Apache的用户组
DirectoryIndex index.html index.php				设置默认主页
DocumentRoot               /var/www/html/		站点默认数据主目录

<Directory />											系统的根目录授权
    Options FollowSymLinks							支持软链接
    AllowOverride None
   //不支持.htaccess访问列表 .htaccess文件提供了针对每个目录改变配置的方法
</Directory>

RHEL6(httpd-2.2)：
<Directory "/var/www/html">         		授权
    Options Indexes FollowSymLinks      	支持索引，支持软链接
    AllowOverride None          				不支持 .htaccess 访问列表
    Order allow,deny            				排序，先允许再拒绝
    Allow from all                 			允许所有人
</Directory>

REHL7(httpd-2.4)：
<Directory "/var/www/html">
     AllowOverride None
     Require all granted        				允许所有人访问
</Directory>
~~~

###实战演练

#### 基本功操作

##### 需求1：

**访问一个静态页面，内容：hello world 新年快乐！**

```powershell
环境：
web-server:10.1.1.1
client:10.1.1.2
思路：
1. 搭建web服务
1）安装httpd软件
2）启动服务

2.创建首页文件
[root@server ~]# echo "hello world 新年快乐！" > /var/www/html/index.html

引申：修改默认的静态资源数据根目录
1. 修改配置文件
# vim /etc/httpd/conf/httpd.conf
DocumentRoot "/webserver"
<Directory "/webserver">
	Options Indexes FollowSymLinks
	AllowOverride None
	Order allow,deny
	Allow from all
</Directory>

2. 创建数据目录及首页文件
[root@server conf]# mkdir /webserver
[root@server conf]# echo "this is webserver test page" > /webserver/index.html

3. 重启web服务
# service httpd restart
4. 客户端测试验证
[root@client ~]# elinks http://10.1.1.1


扩展：Apache作为文件共享服务使用
注意：默认情况下，apache回到默认的数据目录里找index.html的首页文件，如果首页文件不存在就会找测试页，如果测试页不存在，那么就会将目录里的文件共享出去
需求：访问http://10.1.1.1来查看共享文件
1）在默认的数据目录里创建数据文件
2）将测试页删掉或者重命名
[root@server conf.d]# mv welcome.conf welcome.conf.abc
[root@server conf.d]# service httpd restart

```

##### 需求2：

**搭建2个静态页面网站，内容分别为：**

this is first test page！

this is second test page！

~~~powershell
环境：一台服务	——>搭建两个网站
http://10.1.1.1/web1
http://10.1.1.1/web2

方法1：（不推荐）
步骤：
[root@web-server ~]# mkdir /www/web{1..2}
[root@web-server ~]# echo "this is first test page！" > /www/web1/index.html
[root@web-server ~]# echo "this is 2 test page！" > /www/web2/index.html
测试验证：
http://10.1.1.1/web1
http://10.1.1.1/web2


方法2：通过虚拟主机的方式实现（推荐）
基于IP的虚拟主机
基于端口的虚拟主机
基于域名的虚拟主机

http://10.1.1.2     	web1
http://192.168.0.1  	web2

80		web1
8080	web2

http://10.1.1.1:80		web1
http://10.1.1.1:8080		web2
~~~

###### 1. 基于IP虚拟主机

~~~powershell
需求：
http://10.1.1.2			this is 10.1.1.2 test page
http://192.168.0.1		this is 192.168.0.1 test page
环境准备：
eth0		10.1.1.1
eth0:1	192.168.0.1

[root@server ~]# ifconfig eth0:1 192.168.0.1/24			临时增加子接口
[root@server ~]# cd /etc/sysconfig/network-scripts/
[root@server network-scripts]# cp ifcfg-eth0 ifcfg-eth0:1	永久配置
[root@server network-scripts]# cat ifcfg-eth0:1
DEVICE=eth0:1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.1
NETMASK=255.255.255.0

重启网卡：
# service network restart


在配置文件的最后面有虚拟主机的模板：
#<VirtualHost *:80>
#    ServerAdmin webmaster@dummy-host.example.com
#    DocumentRoot /www/docs/dummy-host.example.com
#    ServerName dummy-host.example.com
#    ErrorLog logs/dummy-host.example.com-error_log
#    CustomLog logs/dummy-host.example.com-access_log common
#</VirtualHost>

发布虚拟主机：
1. 创建不同网站的数据目录以及首页文件
# mkdir /www/web{1,2} -p
# echo "this is 10.1.1.1 test page" > /www/web1/index.html
# echo "this is 192.168.0.1 test page" > /www/web2/index.html

2.发布网站
在配置文件/etc/httpd/conf/httpd.conf追加如下内容：
<VirtualHost 10.1.1.2:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web1						web1网站的数据根目录
    #ServerName dummy-host.example.com
    ErrorLog logs/10.1.1.1-error_log
    CustomLog logs/10.1.1.1-access_log common
</VirtualHost>
<VirtualHost 192.168.0.1:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web2						web1网站的数据根目录
    #ServerName dummy-host.example.com
    ErrorLog logs/192-error_log
    CustomLog logs/192-access_log common
</VirtualHost>

3. 启动服务
</VirtualHost>
[root@server conf]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd: httpd: apr_sockaddr_info_get() failed for server.heima.cc
httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
[Thu Jan 03 03:21:26 2019] [error] (EAI 3)Temporary failure in name resolution: Failed to resolve server name for 192.168.0.1 (check DNS) -- or specify an explicit ServerName
[Thu Jan 03 03:21:26 2019] [error] (EAI 3)Temporary failure in name resolution: Failed to resolve server name for 10.1.1.2 (check DNS) -- or specify an explicit ServerName
                                                           [  OK  ]
以上报错原因：IP地址无法解析
解决：修改hosts文件
[root@server conf]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.1.2     server.heima.cc    server
192.168.0.1     server.heima.cc  server

4. 测试验证
1）保证客户端和服务的的网络畅通
[root@client ~]#ping 10.1.1.1
[root@client ~]#ping 192.168.0.1

[root@client ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.1.1.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         10.1.1.254      0.0.0.0         UG    0      0        0 eth0
[root@client ~]# route add -net 192.168.0.0/24 dev eth0
[root@client ~]# ping 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
64 bytes from 192.168.0.1: icmp_seq=1 ttl=64 time=18.8 ms

2）测试验证
[root@client ~]# elinks http://10.1.1.1
[root@client ~]# elinks http://192.168.0.1

~~~

###### 2. 基于端口虚拟主机

~~~powershell
1）需要2个端口
Listen 80
Listen 8080
2）创建两个网站的数据目录和首页文件
3）发布网站
在配置文件/etc/httpd/conf/httpd.conf追加如下内容：
Listen 80
Listen 8080
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web1						web1网站的数据根目录
    #ServerName dummy-host.example.com
    ErrorLog logs/10.1.1.1-error_log
    CustomLog logs/10.1.1.1-access_log common
</VirtualHost>
<VirtualHost *:8080>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web2						web1网站的数据根目录
    #ServerName dummy-host.example.com
    ErrorLog logs/192-error_log
    CustomLog logs/192-access_log common
</VirtualHost>

4）重启服务
# netstat -nltp|grep httpd		80  8080

~~~

###### 3. ==基于域名虚拟主机（重点）==

~~~powershell
需求：
http://www.heima.cc				this is www.heima.cc test page
http://bbs.momowu.cn				this is bbs.momowu.cn
环境：
web-server:10.1.1.2		提供2个网站
dns-server:10.1.1.3		域名解析
client:10.1.1.1			用于测试
步骤：
0.搭建DNS服务（多域管理）	10.1.1.3
1）以下配置文件参考
[root@dns-server named]# tail -10 /etc/named.rfc1912.zones 
zone "heima.cc" IN {
        type master;
        file "heima.cc.zone";
        allow-update { none; };
};
zone "momowu.cn" IN {
        type master;
        file "momowu.cn.zone";
        allow-update { none; };
};
[root@dns-server named]# cat /var/named/heima.cc.zone 
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.heima.cc.
dns     A       10.1.1.3
www     A       10.1.1.2
[root@dns-server named]# cat /var/named/momowu.cn.zone 
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.momowu.cn.
dns     A       10.1.1.3
bbs     A       10.1.1.2

2）启动服务
[root@dns-server named]# service named start
Generating /etc/rndc.key:                                  [  OK  ]
Starting named:                                            [  OK  ]
[root@dns-server named]# netstat -nlutp|grep named

3）客户端测试验证
[root@client ~]# echo nameserver 10.1.1.3 > /etc/resolv.conf 
[root@client ~]# nslookup www.heima.cc
Server:         10.1.1.3
Address:        10.1.1.3#53

Name:   www.heima.cc
Address: 10.1.1.2

[root@client ~]# nslookup bbs.momowu.cn
Server:         10.1.1.3
Address:        10.1.1.3#53

Name:   bbs.momowu.cn
Address: 10.1.1.2

1.在web-server上创建两个网站的数据目录和首页文件
mkdir /www/web{1,2}
echo "this is www.heima.cc test page" > /www/web1/index.html
echo "this is bbs.momowu.cn test page" > /www/web2/index.html
2.发布两个网站（配置2个虚拟主机）
[root@web-server ~]# cd /etc/httpd/conf
[root@web-server conf]# vim httpd.conf
NameVirtualHost *:80
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web1				网站目录
    ServerName www.heima.cc			域名
    ErrorLog logs/heima.cc-error_log
    CustomLog logs/heima.cc-access_log common
</VirtualHost>
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot /www/web2
    ServerName bbs.momowu.cn
    ErrorLog logs/bbs-error_log
    CustomLog logs/bbs-access_log common
</VirtualHost>

3.重启服务
[root@web-server conf]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]

4.客户端测试验证
1）指定DNS服务器
[root@client ~]# echo nameserver 10.1.1.3 > /etc/resolv.conf
2）测试验证
[root@client ~]# elinks http://bbs.momowu.cn
[root@client ~]# elinks http://www.heima.cc
~~~

##### 需求3：

**对于第一个静态网站，需要特定的用户和密码才能访问，并且拒绝10.1.1.0/24网段访问除了10.1.1.254**

~~~powershell
核心思路：对指定的网站数据目录做访问控制
<Directory  /var/www/html>
....
</Directory>


1. 创建密码文件并将用户加入其中
[root@web-server conf]# htpasswd -cm /etc/httpd/conf/.pass user01
New password: 
Re-type new password: 
Adding password for user user01
[root@web-server conf]# cat .pass 
user01:$apr1$r5TsZKph$kxdIssOcWyR39jMW0bnbW.
[root@web-server conf]# htpasswd -bm /etc/httpd/conf/.pass user02 123
Adding password for user user02
[root@web-server conf]# cat .pass 
user01:$apr1$r5TsZKph$kxdIssOcWyR39jMW0bnbW.
user02:$apr1$zzoCZcb.$zTaH7vfvP1QnfCPcVP0Xb.

2.修改配置文件开启认证的功能
<Directory "/www/web1">
    Options Indexes FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
	AuthType Basic
	AuthName "Input your name and password:"
	AuthBasicProvider file
	AuthUserFile /etc/httpd/conf/.pass
	Require user user01
</Directory>

3. 启动服务测试验证
[root@web-server conf]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd: [Thu Sep 06 16:37:27 2018] [warn] _default_ VirtualHost overlap on port 80, the first has precedence
                                                          [  OK  ]
解决：开启如下开关                                                        
NameVirtualHost *:80

如何允许多个人来访问？
方法1：将用户加入到组中，然后再允许组访问
1. 创建组文件
[root@web-server conf]# vim /etc/httpd/conf/groups
admin:user01 stu1 stu2

2. 修改配置文件
<Directory "/www/web1">
    Options Indexes FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
AuthType Basic										//启用认证
AuthName "Input your name and password:"		//输入提示信息
AuthBasicProvider file
AuthUserFile /etc/httpd/conf/.pass			//指定密码文件
AuthGroupFile /etc/httpd/conf/groups		//指定组文件
Require group admin								//允许admin的人来访问
</Directory>

注意：
属于admin组的成员必须在密码文件中存在。

方法2：允许密码文件里的所有用户访问
<Directory "/www/web1">
    Options Indexes FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
AuthType Basic
AuthName "Input your name and password:"
AuthBasicProvider file
AuthUserFile /etc/httpd/conf/.pass
#AuthGroupFile /etc/httpd/conf/groups
#Require group admin
#Require user user02
Require valid-user		//允许多个用户
Order deny,allow
Deny from 10.1.1.0/24
Allow from 10.1.1.254
</Directory>

~~~

**网络访问控制：**

~~~powershell
RHEL6：http 2.2

Order allow,deny  如果allow和deny冲突，deny为准
Order deny,allow  如果allow和deny冲突，allow为准

1、禁止部分ip不能访问网站
Order allow,deny
Allow from  all
Deny from  192.168.0.254 172.16.2.10

2、针对某个网段
Order allow,deny
Allow from  all
Deny from  192.168.0.0/255.255.255.0

3、针对域名
Order allow，deny
Allow from  all
Deny from  node1.itcast.cc .example.com

4、拒绝大部分，只允许某个ip
Order deny，allow
Deny from  all
Allow from 192.168.0.254

需求3：只拒绝10.1.1.2主机访问我的网站

Order allow，deny
Allow from  all
Deny from  10.1.1.2

引申扩展：
RHEL7：http 2.4+
案例1：允许所有主机访问
<Directory "/var/www/html">
     AllowOverride None
     Require all granted
</Directory>

AllowOverride All        允许子目中的 .htaccess 中的设置覆盖当前设置
AllowOverride None       不允许子目中的 .htaccess 中的设置覆盖当前设置

案例2：只允许网段192.168.0.0/24和192.168.10.254/24访问
<Directory "/var/www/html">
     AllowOverride None
     Require ip 192.168.0.0/24
     Require ip 192.168.10.254
</Directory>

案例3：只拒绝某些主机访问
<Directory "/var/www/html">
        AllowOverride None
        <RequireAll>
                Require not ip 10.1.1.254
                Require all granted
        </RequireAll>
</Directory>
~~~

##### 总结：

1. Apache（httpd）的工作原理

   - 只解析静态页面
   - php的动态页面解析需要调用php的模块

2. 一台web服务器搭建多个网站如何实现？

   **==虚拟主机技术==**

   - 基于IP虚拟主机
   - 基于端口虚拟主机
   - **基于域名虚拟主机（重点）**

3. 网站做访问控制

   - 对象访问控制（用户名密码认证）
   - 网络访问控制（允许或拒绝某个主机某个IP等）
   - httpd-2.2和httpd-2.4版本区别（知道）

### 课程目标

- 了解常见的WEB服务器
- 理解Apache的工作原理
- 能够更改apache的默认数据根目录 /var/www/html
- ==能够配置对网页实现用户名密码认证（掌握）==
- ==能够配置apache的虚拟主机（重点）==
- 熟悉Apache的网络访问控制配置（掌握）