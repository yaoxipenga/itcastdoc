# jumpserver架构图

![1562038695489](jumpserver图片/jumpserver架构图.png)



主要难理解的三个用户概念:

1. 用户: 指上图中的运维老大或运维小弟,用来通过公网登录jumpserver的
2. 管理用户: 用于管理资产的用户,一般为root或sudo配置的无密码登录用户
3. 系统用户: 登录资产时使用的用户, 为了安全不直接使用root用户,而是使用普通用户(通过root授予相应的权限)





4A标准

auth

authorized

audit

account





# jumpserver部署

直接参考官方网站,简单暴力(但**需要网速较好**,因为要下载大量的软件包,python模块与docker镜像等)

https://jumpserver.readthedocs.io/zh/master/setup_by_centos7.html



==**重点注意: jumpserver服务器需要打开ip_forward**==



安装完成后,使用浏览器访问http://IP就可以了



![1562040658683](jumpserver图片/jumpserver登录主页.png)





**部署问题:**

除了官方文档上的问题解决外,还有一个坑

因为软件包随着时间的不同,可能版本会有变化,如果在安装python模块时出现下面的问题,**请解决**,否则即使能部署成功,但后面的功能也会受影响

![](jumpserver图片/jumpserver安装问题.png)

解决思路:

~~~powershell
(py3) [root@vm5 ~]# pip install urllib3==1.22
(py3) [root@vm5 ~]# pip install future==0.16.0
~~~

![1562809090990](jumpserver图片/pip安装错误图.png)

~~~powershell
(py3) [root@vm5 ~]# pip install jms-storage==0.0.22
~~~



注意: **`pip install`会自动卸载原版本,安装你指定的版本.**但也有可能会出现新的报错。总之全解决,直到没有报错才继续。







# 邮箱授权

admin(运维老大)创建个用户(运维小弟),还要帮你创建密码? 

不好意思,我小弟太多管不过来,而且我是管理员,不屑于知道你密码。

那你就配置个邮箱吧,发邮件链接给你自己改。

![1561701823255](jumpserver图片/邮件授权.png)

![1561701881862](jumpserver图片/邮件授权2.png)

![1561701955771](jumpserver图片/邮件授权3.png)



![1561702096715](jumpserver图片/邮件授权4.png)



![1561702189255](jumpserver图片/邮件授权5.png)







# jumpserver系统设置
![1561729734920](jumpserver图片/1.png)

![1561701154953](jumpserver图片/jumpserver1.png)

![1561702473425](jumpserver图片/jumpserver2.png)

![1561702525728](jumpserver图片/jumpserver3.png)



# 创建jumpserver普通用户

![1561701353240](jumpserver图片/创建用户1.png)

![1561702794818](jumpserver图片/创建用户2.png)



![1561702840317](jumpserver图片/创建用户3.png)



![1561702899246](jumpserver图片/创建用户4.png)





**张三登录自己的邮箱自行设置密码**

![1562033793144](jumpserver图片/创建用户5.png)



![1562033709013](jumpserver图片/创建用户6.png)

![1562033878495](jumpserver图片/创建用户7.png)



![1562033981796](jumpserver图片/创建用户8.png)



![1562034149955](jumpserver图片/创建用户9.png)



![1562034237734](jumpserver图片/创建用户10.png)



# 创建管理用户



![1562034479880](jumpserver图片/创建管理用户1.png)



![1562034736008](jumpserver图片/创建管理用户2.png)



![1562034816921](jumpserver图片/创建管理用户3.png)



# 创建系统用户

![1562034927200](jumpserver图片/创建管理用户4.png)



![1562035070954](jumpserver图片/创建管理用户5.png)



![1562035230007](jumpserver图片/创建管理用户6.png)



![1562035275610](jumpserver图片/创建管理用户7.png)



# 创建资产

![1562035427111](jumpserver图片/资产1.png)



![1562035552762](jumpserver图片/资产2.png)



![1562035647156](jumpserver图片/资产3.png)



![1562035722773](jumpserver图片/资产4.png)



# 创建授权规则

![1562035807636](jumpserver图片/资产5.png)



![1562035933054](jumpserver图片/资产6.png)



![1562035968364](jumpserver图片/资产7.png)



![1562036003148](jumpserver图片/资产8.png)



# 连接测试

## 命令连接进行管理

![1562036185425](jumpserver图片/连接测试1.png)

![1562036251995](jumpserver图片/连接测试2.png)



![1562036328946](jumpserver图片/连接测试3.png)



## 登录web进行管理

![1562037494243](jumpserver图片/用户登录连接测试.png)





![1562037331521](jumpserver图片/用户登录执行命令.png)



**点击web终端就会跳到web管理终端**

![1562036652271](jumpserver图片/web终端登录.png)





**点击文件管理就会跳到文件管理界面**

![1562037111079](jumpserver图片/文件管理.png)





# 管理员查看信息

**admin管理员可以进行会话的管理与查看, 命令历史记录,录像的回放等功能**

![1562036412977](jumpserver图片/连接会话查看.png)





![1562036782423](jumpserver图片/连接会话查看2.png)



![1562036845468](jumpserver图片/连接会话查看3.png)



**更多功能请自行挖掘,觉得功能还不够,请自行二次开发.**

