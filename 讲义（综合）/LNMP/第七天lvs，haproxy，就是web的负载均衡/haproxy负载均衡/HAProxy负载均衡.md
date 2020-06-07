# HAProxy负载均衡

# 一、HAProxy概述

## 1、**Introduction**

HAProxy, which stands for High Availability Proxy, is a popular opensource software TCP/HTTP LoadBalancer and proxying solution which can be run on Linux, Solaris, and FreeBSD. Its most common use is to improve the performance and reliability of a server environment by distributing the workload across multiple servers(e.g. web, application, database). It is used in many high-profile environments, including: GitHub, Imgur, Instagram, and Twitter.
In this guide, we will provide a general overview of what HAProxy is,basic load-balancing terminology, and examples of how it might be used to improve the performance and reliability of your own server environment.

简言之：HAProxy就是一款高性能的负载均衡器，而是一个开源的软件。支持TCP以及HTTP协议的应用。（支持四层也支持七层）

Nginx < HAProxy < LVS（DR模式）

## 2、Load Balance

**No Load Balancing**

A simple web application environment with no load balancing might look like the following:
In this example, the user connects directly to your web server, at your domain.com and there is no load balancing. If your single webserver goes down, the user will no longer be able to access your webserver. Additionally, if many users are trying to access your server simultaneously and it is unable to handle the load, they may have a slow experience or they may not be able to connect at all.

![1562171854725](media/1562171854725.png)

**Layer 4 Load Balancing**

The simplest way to load balance network traffic to multiple servers is to use layer 4 (transport layer) load balancing. Load balancing this way will forward user traffic based on IP range and port (i.e. if a request comes in for http://yourdomain.com/anything, the traffic will be forwarded to the backend that handles all the requests for yourdomain.com on port 80). For more details on layer 4, check out the TCP subsection of our Introduction to Networking.
Here is a diagram of a simple example of layer 4 load balancing:
The user accesses the load balancer, which forwards the user's request to the web-backend group of backend servers. Whichever backend server is selected will respond directly to the user's request.
Generally, all of the servers in the web-backend should be serving identical content--otherwise the user might receive inconsistent content. Note that both web servers connect to the same database server.

![1562171911196](media/1562171911196.png)

**Layer 7 Load Balancing**

Another, more complex way to load balance network traffic is to use layer 7 (application layer) load balancing. Using layer 7 allows the load balancer to forward requests to different backend servers based on the content of the user's request. This mode of load balancing allows you to run multiple web application servers under the same domain and port. For more details on layer 7, check out the HTTP subsection of our Introduction to Networking.
Here is a diagram of a simple example of layer 7 load balancing:
In this example, if a user requests yourdomain.com/blog, they are forwarded to the blog backend, which is a set of servers that run a blog application. Other requests are forwarded to web-backend,which might be running another application. Both backends use the same database server, in this example.

![1562171953919](media/1562171953919.png)

# 二、HAProxy配置

## 1、安装HAPorxy

yum方式安装：

```powershell
# yum install haporxy -y
```

## 2、haproxy.cfg配置

```powershell
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http                  # 默认使用协议
    log                     global                # 全局日志记录
    option                  httplog               # 详细记录http日志
    option                  dontlognull           # 不记录空日志
    option http-server-close                      # 启用http-server-close
    option forwardfor       except 127.0.0.0/8    # 来自127.0.0.0/8的请求都不转发
    option                  redispatch            # 重新分发,宕机强制重定向
    retries                 3                     # 3次连接失败则认为服务不可用
    timeout http-request    10s                   # 默认http请求超时时间
    timeout queue           1m                    # 默认队列超时时间
    timeout connect         10s                   # 默认连接超时时间
    timeout client          1m                    # 默认客户端超时时间
    timeout server          1m                    # 默认服务器超时时间
    timeout http-keep-alive 10s                   # 默认持久连接超时时间
    timeout check           10s                   # 默认检查时间间隔
    maxconn                 3000                  # 最大连接数

# 注:mode,可以为{http|tcp|health} http:是七层协议 tcp:是四层 health:只返回ok
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  main *:5000
	# 定义ACL规则，-i:忽略大小写
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js
	
	# 调用后端静态服务器检查ACL规则是否被匹配
    use_backend static          if url_static	=>  配置时，注释此行
    # 客户端访问时默认调用后端服务器地址
    default_backend             app

#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
# 定义静态服务器
backend static
	# 定义轮询算法为rr
    balance     roundrobin
    # check:启动对静态服务器server的健康状态检测
    server      static 127.0.0.1:4331 check

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
# 定义后端服务器地址
backend app
    balance     roundrobin
    server  app1 10.1.1.11:80 check
    server  app2 10.1.1.13:80 check

# 定义Web管理界面
listen statistics
	bind *:9090     	     # 定义监听端口
	mode http			     # 默认使用协议
	stats enable    	     # 启用stats
	stats uri /hadmin?stats  # 自定义统计页面的URL，默认为/haproxy?stats
    stats auth admin:admin   # 统计页面用户名和密码设置
  	stats hide-version 	     # 隐藏统计页面上HAProxy的版本信息
    stats refresh 30s 	     # 统计页面自动刷新时间
    stats admin if TRUE      # 如果认证通过就做管理功能，可以管理后端的服务器
    stats realm Hapadmin     # 统计页面密码框上提示文本，默认为Haproxy\ Statistics
```

## 3、常见错误

第一个：503错误：503 Service Unavailable

```powershell
100%，静态负载没有注释，所有静态资源请求全部转到127.0.0.1:4331端口
```

第二个：请求时，一会正常一会不正常

```powershell
① 有一台服务器并没有正常工作
解决办法：一台服务器一台测试，看看具体哪个后端服务宕机
② LVS环境没有清理干净，web01和web02，我们route del default删除过默认路由
解决方案：systemctl  restart  network
```

第三个：访问10.1.1.19:9090/hadmin?stats无法访问管理界面

```powershell
① 端口没有监听
解决办法：systemctl  stop  haproxy  =>  systemctl  start   haproxy

② 记错url地址，haproxy.cfg
listen statistics
	bind *:9090     	     # 定义监听端口
	stats uri /hadmin?stats  # 自定义统计页面的URL，默认为/haproxy?stats
	
http://10.1.1.19:9090/hadmin?stats
```

## 4、HAProxy调度算法

```powershell
balance roundrobin 	     # 轮询,软负载均衡基本都具备这种算法
balance static-rr 	     # 根据权重，建议使用	=>  server ...  weight 权重值
balance leastconn 		 # 最少连接者先处理，建议使用
balance source 			 # 根据请求源IP，建议使用（类似IP_HASH）
balance uri 		     # 根据请求的URI
balance url_param        # 根据请求的URl参数
balance hdr(name)        # 根据HTTP请求头来锁定每一次HTTP请求
balance rdp-cookie(name) # 根据cookie(name)来锁定并哈希每一次TCP请求
```

## 5、MySQL负载均衡（了解）

haproxy.cfg配置文件：

```powershell
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    tcp				=>   mysql负载均衡，必须是tcp
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  main *:3306
    default_backend             mysql

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend mysql
    balance     roundrobin
    server  mysql01 10.1.1.12:3306 check
    server  mysql02 10.1.1.14:3306 check
```

