# 认识Teleport

在开源堡垒机领域, 很多人都知道jumpserver, 但是jumpserver安装相对较复杂, 新手容易出现各种坑。

在这里介绍一款简单易用的开源堡垒机系统: **Teleport**, 它小巧、易用, 支持 RDP/SSH/SFTP/Telnet 协议的远程连接和审计管理.

Teleport由两大部分构成：

-  跳板核心服务
-  WEB操作界面

Teleport的特点:

- 极易部署
- 简洁设计，小巧灵活，无额外依赖，确保您可以在5分钟内完成安装部署，开始使用。
- 安全增强
- 配置远程主机为仅被teleport服务器连接,可有效降低嗅探、扫描、暴力破解等攻击风险。
- 单点登录
- 只需登录teleport服务器，即可一键连接您的任意远程主机，无需记忆每台远程主机的密码了。
- 按需授权
- 可以随时授权指定运维人员访问指定的远程主机，也可随时回收授权。仅仅需要几次点击！
- 运维审计
- 对远程主机的操作均有详细记录，支持操作记录录像、回放，审计工作无负担。

参考官方地址: https://tp4a.com/



# Teleport安装部署

Teleport非常小巧且极易安装部署：仅需一分钟，就可以安装部署一套您自己的堡垒机系统！！

因为Teleport内建了所需的脚本引擎, WEB服务等模块，因此不需要额外安装其他的库或者模块，整个系统的安装与部署非常方便。

## 下载并解压

~~~powershell
# wget https://tp4a.com/static/download/teleport-server-linux-x64-3.2.2.tar.gz

# tar xf teleport-server-linux-x64-3.2.2.tar.gz

~~~

## 执行安装脚本

~~~powershell
# cd teleport-server-linux-x64-3.2.2/

# ./setup.sh
~~~

![1569409901151](teleport图片/1.png)

![1569409984464](teleport图片/2.png)

## 服务控制方法

Teleport 有两个服务：

* 核心服务 `core` , 配置文件路径为`/usr/local/teleport/data/etc/core.ini`
* 网页服务 `web`, 配置文件路径为`/usr/local/teleport/data/etc/web.ini`

两个服务可以同时启动、停止、重启，也可单独操作其中的一个。



操作完整的 teleport 服务：

- 启动： `/etc/init.d/teleport start`
- 停止： `/etc/init.d/teleport stop`
- 重启： `/etc/init.d/teleport restart`
- 查看运行状态： `/etc/init.d/teleport status`

仅操作核心服务 core：

- 启动： `/etc/init.d/teleport start core`
- 停止： `/etc/init.d/teleport stop core`
- 重启： `/etc/init.d/teleport restart core`

仅操作网页服务 web：

- 启动： `/etc/init.d/teleport start web`
- 停止： `/etc/init.d/teleport stop web`
- 重启： `/etc/init.d/teleport restart web`



## 访问web管理界面

安装完后,确认web界面端口

~~~powershell
# netstat -ntlup |grep 7190
tcp     0   0 0.0.0.0:7190      0.0.0.0:*               LISTEN      7303/tp_web
~~~

使用浏览器访问`http://服务器的IP:7190`

![1569412999726](teleport图片/3.png)

## 安装mariadb并启动

在centos7上,我这里直接使用rpm版的mariadb比较方便(当然你也可以选择自己二进制安装或编译安装MySQL)

~~~powershell
# yum install mariadb-server mariadb-devel -y

# systemctl start mariadb
# systemctl enable mariadb

~~~

## 配置mariadb

~~~powershell
# mysql

MariaDB [(none)]> create database teleport default character set utf8;

MariaDB [(none)]> grant all on teleport.* to 'teleport'@'localhost' identified by '123';

MariaDB [(none)]> flush privileges;

MariaDB [(none)]> quit
~~~

## 修改teleport配置

主要修改[database]配置段,以连接mysql(mariadb)

~~~powershell
# grep -Ev ';|^$' /usr/local/teleport/data/etc/web.ini	# 修改后的配置如下
[common]
port=7190
log-level=2
debug-mode=0
core-server-rpc=http://127.0.0.1:52080/rpc

[database]
type=mysql
mysql-host=127.0.0.1
mysql-port=3306
mysql-db=teleport
mysql-prefix=tp_
mysql-user=teleport
mysql-password=123
~~~

## web配置连接

使用浏览器再次访问`http://服务器的IP:7190`

![1569591775349](teleport图片/4.png)

![1569591904120](teleport图片/5.png)

![1569592039018](teleport图片/6.png)

## 连接登录

![1569592299160](teleport图片/7.png)

![1569592353890](teleport图片/8.png)



# Teleport简单应用

## 添加主机

![1569667992136](teleport图片/9.png)

![1569668206341](teleport图片/10.png)

![1569668420616](teleport图片/10-1.png)



**主机连接模式**

在添加主机时有两种连接模式如下图所示:

![1569668234485](teleport图片/11.png)



直接连接较好理解，端口映射是在直接连接的基础上又加了一个路由主机, 多做了一次跳转.



## 安装Teleport助手

因为下一个步骤测试远程连接时需要安装Teleport助手(windows客户端安装)

助手下载地址: https://tp4a.com/download/get-file/teleport-assist-windows-3.2.2.exe

除了windows版外,还有mac版,暂不支持linux版。

安装过程省略, 安装完后效果:

![1569670766338](teleport图片/12-1.png)

![1569670897565](teleport图片/12-2.png)





## 添加主机账号

添加完主机后，还需要为此主机设置远程登录的账号

![1569668794368](teleport图片/12.png)



![1569668908670](teleport图片/13.png)

![1569669676278](teleport图片/15.png)

![1569669582741](teleport图片/14.png)

![1569669969185](teleport图片/16.png)





![1569670044454](teleport图片/17.png)



## 远程连接操作

![1569670221651](teleport图片/18.png)



## 会话审计

![1569670333917](teleport图片/19.png)



![1569670432631](teleport图片/20.png)

==特别注意:== **录像存放路径为`/usr/local/teleport/data/replay/`,会占较大的存储空间,建议使用单独的存储盘或远程存储(NAS,SAN,分布式存储等)挂到到此目录,以防止空间不够.**

如果要修改录像占用目录的路径, 方法如下:

~~~powershell
# vim /usr/local/teleport/data/etc/core.ini

replay-path=XXXXXX			   打开注释,并修改成合适的路径

保存后,重启服务生效
# /etc/init.d/teleport restart`
~~~

# Teleport应用进阶

## 批量添加资产主机

如果有很多台主机需要批量加入,我们可以将所有主机信息填写到资产信息文件里，然后一键导入即可。

![1576842002730](teleport图片/21.png)



![1576842366174](teleport图片/22.png)



![1576842473853](teleport图片/23.png)



![1576842502808](teleport图片/24.png)

![1576842549311](teleport图片/25.png)

## 主机资产分组

当主机数据过多时，为了方便管理，我们需要将其进行分组.

![1576842858881](teleport图片/26.png)

![1576842926820](teleport图片/27.png)

![1576842984493](teleport图片/28.png)

![1576843058299](teleport图片/29.png)

![1576843132240](teleport图片/30.png)

## 用户管理

这里要讨论的用户与主机账号必须要区分开。用户可以指定不同的角色。

用户: 指运维工程师们在办公室或家里远程连接到堡垒机的用户.

主机账号: 指堡垒机ssh连接资产主机的账号,如root等。为了更安全建议使用普通用户与sudo结合。

角色: 指一类权限的集合。

![1576843521078](teleport图片/31.png)

![1576843731854](teleport图片/32.png)

![1576843821018](teleport图片/33.png)

![1576843851416](teleport图片/34.png)

![1576843916804](teleport图片/35.png)

![1576844941058](teleport图片/35-1.png)

![1576845030635](teleport图片/35-2.png)



如果用户比较多，也可以对用户进行分组管理，这里就不详解讨论了。

![1576843956269](teleport图片/36.png)

## 为用户授权资产

主机资产多, 用户也不止一个, 所以还需要做资产授权管理，让不同的用户管理不同的资产。

![1576844255654](teleport图片/37.png)

![1576844324831](teleport图片/38.png)

![1576844370265](teleport图片/39.png)



![1576844476274](teleport图片/40.png)

![1576844523173](teleport图片/41.png)

![1576844621375](teleport图片/42.png)

![1576844707294](teleport图片/43.png)

![1576844840995](teleport图片/44.png)

## 普通用户登录验证

![1576845105208](teleport图片/45.png)

![1576845195776](teleport图片/46.png)

请自行使用张三用户管理操作，然后使用admin用户进行审计验证。



## nginx反向代理teleport

加一个nginx做反向代理的好处:

- 可以将端口映射为默认端口，更好记；
- 可以配置为使用域名方式访问你的TP服务；
- 可以配置成HTTPS方式访问，更安全。

参考: https://docs.tp4a.com/nginx/

# 总结

最终实现多用户，多资产主机授权管理的安全堡垒机，符合4A标准:

1. authention		 验证
2. authority            授权
3. account              账户管理
4. audit                   审计



