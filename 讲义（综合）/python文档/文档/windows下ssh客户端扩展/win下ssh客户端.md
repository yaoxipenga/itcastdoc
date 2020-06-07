# windows如何使用ssh客户端工具
# 1、常见ssh客户端

基于ssh协议
## 1、第三方厂商开发
mobaxterm、xshell、SecureCRT、finalshell、putty(很小)

## 2、windows默认版本

默认window之前版本没有openssh,新版系统  右键徽标=>运行=>cmd
 在cmd中使用ssh  

![image-20200410095811588](assets/image-20200410095811588.png)

## 3、其他一些命令终端

有一些软件带了ssh  git-bash  cmder

免密登录

# 2、gitbash

## 1、安装

安装过程和安装其他软件基本无异。需要注意一下软件安装的位置，其他默认下一步next

![image-20200410094616991](assets/image-20200410094616991.png)

## 2、使用

安装好软件之后，鼠标右键会出现以下菜单

![image-20200410094714787](assets/image-20200410094714787.png)

![image-20200410095014648](assets/image-20200410095014648.png)

## 3、windows连接linux免密登录

**①生成密钥对**

![image-20200410095359784](assets/image-20200410095359784.png)

**②添加公钥到服务端**

![image-20200410095619669](assets/image-20200410095619669.png)