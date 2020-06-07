---
typora-root-url: pictures
---

# 一、认识管道

##1、 什么是管道

管道，指在类UNIX系统中，进程之间通讯的一种方式或机制。

管道，也指一种特殊的文件，叫==管道文件==。

## 2、 管道的分类

### ㈠ ==匿名管道==

匿名管道，顾名思义，就是==没有名字==的管道，常常用于==父子关系==的进程之间通讯一种方式。

匿名管道，在bash中，用符号"==|=="来表示。

![pipe](/pipe.png)

```powershell
标准输出：1
标准错误：2
标准输入：0

[root@localhost ~]# rpm -aq|grep vsftpd
vsftpd-2.2.2-24.el6.x86_64

[root@localhost ~]# cat /etc/passwd|less
```

### ㈡ 命名管道

命名管道，顾名思义，就是==有名字的管道==，既可以用于有父子关系的进程之间通讯也可以用在非父子关系的进程之间通讯。

命名管道，可以使用==mkfifo==命令创建。

```powershell
[root@localhost ~]# mkfifo /tmp/p_file			//创建一个命名管道文件
[root@localhost ~]# file /tmp/p_file 			//判断该文件的类型
/tmp/p_file: fifo (named pipe)
[root@localhost ~]# ll /tmp/p_file 
prw-rw-r--. 1 root root 0 Mar 10 15:28 /tmp/p_file

[root@localhost ~]# tty
/dev/pts/1
[root@localhost ~]# echo "hello world" > /tmp/p_file

[root@localhost ~]# tty
/dev/pts/2
[root@localhost ~]# cat /tmp/p_file 
hello world
[root@localhost ~]# 
```



### (三) 匿名三叉管道

用于可以同时做二个输出的效果，如下例

~~~powershell
[root@localhost ~]# echo 123456 |tee 000.txt
123456

[root@localhost ~]# ls
000.txt

[root@localhost ~]# cat 000.txt
123456

~~~







## 3、匿名管道的作用

![管道](/管道.png)

**匿名管道作用：将上一个命令所执行的结果作为下一条命令的==标准输入==**

## 4、引申xargs命令

**场景**：找出某些文件将其删除或者找出某个进程将它结束，如何实现？

```powershell
需求：
在/tmp/dir1目录里有一个目录aaa和5个文件file1~file5，现需要删除该目录下的file1~file5

以下命令不能删除：
find /tmp/dir1 -name file* |rm -rf
但是，管道|后面加上xargs就可以删除：
find /tmp/dir1 -name file* |xargs rm -rf

以下命令可以成功删除：
find /tmp/dir1 -type f -exec rm -f {} \;	正确
find /tmp/dir1 -type f -delete

```

**xargs:** 将上一条命令所执行的结果作为下一条命令的==参数==

```powershell
命令 [可选项] 参数
[root@localhost ~]# ls -l /root

命令：整条shell命令的主体
选项：会影响或微调命令的行为
参数：命令作用的对象



举例说明：
cat -n  filename
命令  选项   参数

[root@localhost ~]# echo --help|cat
--help
[root@localhost ~]# echo --help|xargs cat

cat --help

[root@localhost tmp]# pwd
/tmp
[root@localhost tmp]# cat 1.sh
/root
[root@localhost tmp]# cat 1.sh|ls
1.sh
[root@localhost tmp]# cat 1.sh|xargs ls
aaa              Desktop    Downloads    install.log.syslog  Pictures  Templates
anaconda-ks.cfg  Documents  install.log  Music               Public    Videos
```

**xargs其他选项(了解)：**

```powershell
常见选项
-n：指定单行显示的参数个数
-d：定义分割符，默认是以空格和换行符
[root@localhost ~]# cat 1.txt 
a b c d
10.1.1.254
A	B	C
[root@localhost ~]# cat 1.txt |xargs -n 3
a b c
d 10.1.1.254 A
B C
[root@localhost ~]# cat 1.txt |xargs -n 4
a b c d
10.1.1.254 A B C
[root@localhost ~]# cat 1.txt |xargs -d'\t' -n 3
a b c d
10.1.1.254
A B C

[root@localhost ~]# cat 1.txt |xargs -d'.' -n 3
a b c d
10 1 1
254
A	B	C
```

# 二、进程概述

## 1、什么是进程

进程，由程序产生，是==正在运行==的程序，或者说是已启动的可执行程序的运行实例。

进程，具有自己的==生命周期==和各种==不同的状态==。

**引申：什么是线程？**

线程，也被称作==轻量级进程==，线程是进程的执行单元，==一个进程可以有多个线程==。线程==不拥有资源==，它与父进程的其它线程==共享==该进程所拥有的资源。线程的执行是==抢占式==的。

## 2、进程有什么特点

- 独立性

  进程是系统中独立存在的实体，它可以拥有自己的==独立资源==，每一个进程都有自己的私有地址空间；

  在没有经过进程本身允许的情况下，一个用户进程不可以直接访问其他进程的地址空间。

- 动态性

  进程与程序的区别在于，**程序**只是一个==静态的指令集合==，而进程是一个正在系统中==活动的指令集合==；

  进程具有自己的生命周期和各种不同的状态。

- 并发性

  多个进程可以在单个处理器上并发执行，多个进程之间不会互相影响。

**程序和进程有什么区别？**

- 程序。二进制的文件，静态的。如:/usr/sbin/vsftpd，/usr/sbin/sshd
- 进程。程序的运行过程，动态的，有==生命周期及运行状态==的。



## 3、进程生命周期

**父进程**,复制自己的地址空间（fork）创建一个新的（子）进程结构。每个新进程分配一个唯一的进程 ID （PID），满足跟踪安全性之需。PID 和 父进程 ID (PPID）是子进程环境的元素，任何进程都可以创建子进程，所有进程都是第一个系统进程的后代：Centos5/6:  ==init==   Centos7:  ==systemd==  

**子进程,**继承父进程的安全性身份、过去和当前的文件描述符、端口和资源特权、环境变量，以及程序代码。随后，子进程exec 自己的程序代码。通常，父进程在子进程运行期间处于睡眠（sleeping）状态。当子进程完成时发出（exit）信号请求，在退出时， 子进程会关闭或丢弃了其资源环境，剩余的部分称之为僵停（僵尸Zombie）。父进程在子进程退出时收到信号而被唤醒，清理剩余的结构，然后继续执行其自己的程序代码。

![process](/process.png)

# 三、==进程信息查看==

## 1、静态查看ps命令

![进程信息2](/进程信息2.png)

![进程信息1](/进程信息1.png)

- 常见组合

```powershell
ps -ef
ps -eF
ps -ely
ps aux
ps auxf

a	显示当前终端下的所有进程，包括其他用户的进程
u	显示进程拥有者、状态、资源占用等的详细信息（注意有“-”和无“-”的区别）
x	显示没有控制终端的进程。通常与a这个参数一起使用，可列出较完整信息
o	自定义打印内容
-e	显示所有进程。
-f	完整输出显示进程之间的父子关系
-l	较长、较详细的将该进程的信息列出
```

- 进程信息解释说明

```powershell
[root@MissHou ~]# ps aux|head
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  19356  1432 ?        Ss   19:41   0:03 /sbin/init

USER:		运行进程的用户
PID:		进程ID
%CPU:		CPU占用率
%MEM:		内存占用率
VSZ:		占用虚拟内存
RSS:		占用实际内存,驻留内存
TTY:		进程运行的终端
STAT:		进程状态,man ps获取帮助(/STATE)
      R 	运行
      S 	可中断睡眠 Sleep
      D	不可中断睡眠
      T 	停止的进程 
      Z 	僵尸进程
      X  死掉的进程
      
     Ss  	s进程的领导者，父进程
     S< 		<优先级较高的进程
     SN  	N优先级较低的进程
     R+		+表示是前台的进程组
     Sl		以线程的方式运行
	
START		进程的启动时间
TIME		进程占用CPU的总时间
COMMAND	进程文件，进程名

其他命令查看进行信息
pidof		查看指定进程的PID
pstree	查看进程树

查看端口对应的进程编号
[root@localhost ~]# lsof -i TCP:80
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   7448  root    6u  IPv4  67068      0t0  TCP *:http (LISTEN)
nginx   7448  root    7u  IPv6  67069      0t0  TCP *:http (LISTEN)
nginx   7450 nginx    6u  IPv4  67068      0t0  TCP *:http (LISTEN)
nginx   7450 nginx    7u  IPv6  67069      0t0  TCP *:http (LISTEN)



```

## 2、动态查看top命令

**第一部分：统计信息**

```powershell
[root@localhost ~]# top
top - 10:55:44 up  3:19,  2 users,  load average: 1.03, 0.50, 2.10
Tasks: 112 total,   1 running, 111 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
Mem:   1004412k total,   331496k used,   672916k free,    58364k buffers
Swap:  2031608k total,        0k used,  2031608k free,   107896k cached
```

关注==load average==:系统1分钟、5分钟、15分钟内的平均负载，判断一个系统负载是否偏高需要计算单核CPU的平均负载，如下图，一般以==1以内==为比较合适的值。偏高说明有比较多的进程在等待使用CPU资源。 

![load](../pictures/load.png)

计算方法：

平均负载 / 逻辑cpu数量

```powershell
物理CPU(N路)：主板上CPU插槽的个数
CPU核数：一块CPU上面能处理数据的芯片组的数量
逻辑CPU：一般情况，一颗cpu可以有多核，加上intel的超线程技术(HT), 可以在逻辑上再分一倍数量的cpu core出来；逻辑CPU数量=物理cpu数量 x cpu核数。如果支持HT,还要更多。

查看物理CPU的个数
# cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l  
查看逻辑CPU的个数
# cat /proc/cpuinfo |grep "processor"|wc -l  
查看CPU是几核
# cat /proc/cpuinfo |grep "cores"|uniq  

```

第三行：当前的CPU运行情况

```powershell
us		用户进程占用CPU的比率
sy		内核、内核进程占用CPU的比率；
ni		如果一些用户进程修改过优先级，这里显示这些进程占用CPU时间的比率；
id		CPU空闲比率，如果系统缓慢而这个值很高，说明系统慢的原因不是CPU负载高；
wa		CPU等待执行I/O操作的时间比率，该指标可以用来排查磁盘I/O的问题，通常结合wa和id判断
hi		CPU处理硬件中断所占时间的比率；
si		CPU处理软件中断所占时间的比率；
st		其他任务所占CPU时间的比率；

说明：
1. 用户进程占比高，wa低，说明系统缓慢的原因在于进程占用大量CPU，通常还会伴有较低的id，说明CPU空闲时间很少；
2. wa低，id高，可以排除CPU资源瓶颈的可能。
3. wa高，说明I/O占用了大量的CPU时间，需要检查交换空间的使用；如果内存充足，但wa很高，说明需要检查哪个进程占用了大量的I/O资源。
```

**第二部分：进程信息**

![top](/top.png)

- **top命令常用按键命令**
  - 在top的执行过程中，还可以使用以下的按键命令：

```powershell
h|?	帮助

M	按内存的使用排序
P	按CPU使用排序
T	按该进程使用的CPU时间累积排序
k	给某个PID一个信号（signal），默认值是信号15
1	显示所有CPU的负载
s	改变两次刷新之间的时间。默认是5秒
q	退出程序

N	以PID的大小排序
R	对排序进行反转
f	自定义显示字段
r	重新安排一个进程的优先级别

```

- **top命令常用的选项**

```powershell
-d		后面可以接秒数，指定每两次屏幕信息刷新之间的时间间隔；
-p		指定某个进程来进行监控；
-b -n	以批处理方式执行top命令。通常使用数据流重定向，将处理结果输出为文件；

[root@MissHou ~]# top
[root@MissHou ~]# top -d 1
[root@MissHou ~]# top -d 1 -p 10126					    查看指定进程的动态信息
[root@MissHou ~]# top -d 1 -u apache				    查看指定用户的进程
[root@MissHou ~]# top -d 1 -b -n 2 > top.txt 	    将2次top信息写入到文件
```

# 四、==进程控制==

## 1、进程的优先级控制

### ㈠ 调整==正在运行==进程的优先级(renice)

#### ① 使用top按"r"来调整

```powershell
优先级的范围：
-20——19  数字越低，优先级越高，系统会按照更多的cpu时间给该进程
```

#### ② 命令行使用renice调整

```powershell
sleep命令没有实际意义，延迟(睡觉)5000秒
[root@localhost ~]# sleep 5000 &
[1] 2544

sleep程序已经运行，通过renice命令调整优先级
[root@localhost ~]# renice -20 2544
2544: old priority 0, new priority -20
```

###㈡ 程序运行时指定优先级(nice)

```powershell
启动进程时，通常会继承父进程的 nice级别，默认为0。
# nice -n -5 sleep 6000 & 
# ps axo command,pid,nice |grep sleep
```



##2、==进程的运行状态控制==

### ㈠ 如何控制进程的状态？

用户通过给进程**==发送信号==**来控制进程的状态。

### ㈡ 常见的信号有哪些？

| 信号编号 | 信号名  | 解释说明                                                   |
| -------- | ------- | ---------------------------------------------------------- |
| ==1==    | SIGHUP  | 默认终止控制终端进程(==可用来重新加载配置文件==，平滑重启) |
| ==2==    | SIGINT  | 键盘中断(ctrl+c)                                           |
| 3        | SIGQUIT | 键盘退出(ctrl+\\)，一般指程序异常产生core文件              |
| ==9==    | SIGKILL | 强制终止                                                   |
| ==15==   | SIGTERM | 正常结束，默认信号                                         |
| 18       | SIGCONT | 继续                                                       |
| 19       | SIGSTOP | 停止                                                       |
| 20       | SIGTSTP | 暂停(ctrl+z),一般子进程结束                                |

### ㈢ 如何给进程发送信号？

```powershell
kill	[信号]	进程PID
killall
pkill

给进程号为15621的进程发送默认信号(-15可以省略)
kill -15 15621
给stu1用户的所有进程发送9号信号（结束stu1的所有进程），根据用户结束进程
pkill -9 -u stu1
给进程名为vsftpd的进程发送9号信号(根据进程名来结束进程)
pkill -9 vsftpd
killall -15 vsftpd

```

### ㈣ 进程其他控制命令

```powershell
# jobs  	查看当前终端后台的进程
# fg		把后台进程放到前台来运行
# bg		把后台暂停的进程放到后台运行
# fg %1	将作业1调回到前台
# bg %2 	把后台编号为2的进程恢复运行状态

# kill -20 %3		给job编号为3的进程发送信号
# firefox www.baidu.com	&	打开浏览器放到后台运行

kill 信号	进程编号 或者 job编号
pkill	信号	进程名字
killall 信号  进程名字

fg  %2	把后台job编号为2的进程放到前台来运行
bg  %3	把后台job编号为3的进程放到后台继续运行

```

#五、课堂练习

1. 启动vsftpd和httpd服务

   ```powershell
   service vsftpd start
   service httpd start
   ```

2. 分别使用ps和top命令查看vsftpd和httpd进程的相关信息

3. 重新设置vsftpd进程的nice值为-5，并且查看

4. 结束httpd进程

5. Linux下打开Firefox火狐浏览器并放到后台运行

6. 停止Firefox火狐浏览器，并把它放到前台继续运行

