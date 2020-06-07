# 任务背景

* 运维工程师是天天跑机房的，大部分时间坐在办公室，远程通过xshell,secureCRT,mobaXterm等远程工具访问服务器。我们需要对这些远程访问的用户进行相应的安全控制才能提高机房内部服务器的安全。
* 多个运维工程师不可能都有服务器的root密码，需要分工精细，还要防止误操作，所以我们还要对用户的权限做相应的控制，并对其操作进行审计。



**学习目标:**

- [ ] 能够使用pam_nologin模块禁止所有非root用户登陆

- [ ] 能够使用pam_listfile模块实现服务登陆的黑白名单功能

- [ ] 能够使用pam_time模块实现登陆时间控制

- [ ] 能够使用pam_tally2模块限制ssh暴力猜密码

- [ ] 能够使用sudo分配权限



# 验证

> 什么是验证?
>
> 答:  就像你上网登录用户名和密码，验证对了才能登陆成功，也就证明了你的身份; 你用钥匙打开家门，钥匙能打开门就说明门验证了你是主人的身份。但如果有人偷了你的钥匙，然后打开了你家的门，那门的验证就出问题了？ 答案是否定的，门的验证并没有出错，因为它只认钥匙，而不认是谁在用钥匙。
>
> 如何提高验证的准确性和安全性？
>
> 答: 可以加**==多条件验证==**。比如你在家门再安装声音识别，指纹识别，眼角膜识别等等来加强安全验证。同样的道理，我们知道linux系统也有用户和密码，正确的用户名和密码就代表验证成功，那么我们是否也可以加多条件来加强安全性呢？ 当然可以。





## PAM验证

## PAM介绍

pam（Pluggable Authentication Modules for Linux）是linux可植入式验证模块。

在linux系统的/lib64/security/目录下这里有大量的pam模块，查看模块的使用文档就是使用man（比如pam_access.so模块，就使用man pam_access命令。当然man文档不容易看懂😃)

> 怎么配置PAM？
>
> 答: PAM的配置文件一般存放在/etc/pam.d/目录下，通过/etc/pam.d/目录下的文件名就知道是控制哪个程序的，比如login是控制系统登录的,sshd是控制sshd服务的,passwd是控制passwd命令的。假设我要对系统登录加安全条件，那么你就得去对应的配置文件/etc/pam.d/login里去加。

```powershell
我们以/etc/pam.d/login此文件为例
# cat /etc/pam.d/login 	
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
-session   optional     pam_ck_connector.so
每一行（非注释行)都代表了一个验证条件。每一行我们又分为三列。
第一列叫module-type（简单的看作是pam模块的分类就好了),主要为:
auth：对用户身份进行识别，如提示输入密码，判断是否root；
account：对账号各项属性进行检查，如是否允许登录，是否达到最大用户数；
session：定义登录前，及退出后所要进行的操作，如登录连接信息，用户数据的打开和关闭，挂载fs；
password：使用用户信息来更新数据，如修改用户密码。

第二列叫control-flag(控制多个条件之间的逻辑),主要为:
required：表示该行以及所涉及模块的成功是用户通过鉴别的必要条件。
requisite：与required相仿，只有带此标记的模块返回成功后，用户才能通过鉴别。
sufficient：表示该行以及所涉及模块验证成功是用户通过鉴别的充分条件。
optional：他表示即便该行所涉及的模块验证失败用户仍能通过认证
include: 包含后面的子配置文件,如果子配置文件里流程失败，也会退出父流程。
substack: 包含后面的子配置文件,如果子配置文件里流程失败，只退出子配置流程，不退出父流程。



第三列就是模块名。

比较难理解的是第二列，它代表了多个条件之间的逻辑。
举个例子，你是男的，要去相亲，requisite，sufficient，required，optional怎么对应下面的条件才合你的标准？：
1,性别女	requisite	sufficient required  optional
2,长得美   required 
3,身材好	required
4,年龄比自己小	required
5,985毕业		required


面试场景
1.领导的亲戚   sufficient
2.你吃饭了吗   optional
3.笔试	    requried
4.技术员面试	  requisite
5.技术经理面试  requisite
6.老板面试	   requisite
```

问题1:下面的条件怎样才能最终成功,怎样才会失败?

```powershell
条件一	required
条件二	required 
条件三	required
成功: 三个条件都pass; 失败: 任意条件failed都失败，并且不会告诉你是哪一个条件failed.
```

问题2:下面的条件怎样才能最终成功,怎样才会失败?

```powershell
条件一	required
条件二	requisite
条件三	required
成功: 三个条件都pass; 失败: 条件二failed就直接失败，并且不会验证条件三.
```

问题3:下面的条件怎样才能最终成功,怎样才会失败?

```powershell
条件一	sufficient
条件二	required
条件三	required
成功: 条件一pass直接成功。条件一failed，但条件二，三pass也成功。 失败:条件二或三任意一个failed.
```

问题4:下面的条件怎样才能最终成功,怎样才会失败?

```powershell
条件一	requisite
条件二	sufficient
条件三	required
条件四	required
成功: 条件一，二pass就成功。条件一，三，四pass，二failed也成功。失败: 条件一failed。一pass,二failed，三，四任意一个failed。
```

问题5:下面的条件有哪几种情况才能最终成功？

```powershell
条件一	required
条件二	requisite
条件三	required	
条件四	sufficient	
条件五	required
条件六	required
条件七	requisite  
条件八	sufficient
条件九	required
条件十	required
--注意:required如果失败，不会验证后面的sufficient
三种成功可能:
1,条件一，二，三，四pass
2,条件一，二，三，五，六，七，八pass,四failed
3,条件四，八failed，其它都pass
```

你可以这样理解：

PAM的各种模块就是相当于具备各种功能的锁（如:普通机械锁，可能还有看门狗,密码锁，声音识别，指纹识别，人脸识别，眼角膜识别等)。我们要把这些锁安装到门或柜子这些需要加强安全的地方（门和柜子在linux里就是类似系统login,ssh登录,ftp登录这种相应的程序）。你可以控制按顺序打开所有的锁才能进入，或者打开其中一个或几个锁就可以成功进入（配置文件第二列的逻辑有关）。

所以PAM可能有无数种应用可能，如果你够牛逼，你可以把系统登录写上100个条件，再把逻辑打乱，那么除了你谁也进不来了（条件太多，逻辑太复杂），这就是PAM加强安全验证的精髓。当然，实际应用时不会这么变态（这就像我骑个单车出去，还要带100把锁锁上，这有点过分了）。所以我们一般会在原有的基础做一两个条件的增加或更改，这还是非常实用的。下面就有一些小实例，希望有抛砖引玉的效果。



**小结:** PAM可以通过对服务(**不是任何服务**)加多验证条件来实现服务的安全加固。

例如:

~~~powershell
# ldd /usr/sbin/sshd |grep pam
        libpam.so.0 => /lib64/libpam.so.0 (0x00007fbc72cc0000)	支持libpam模块的服务就支持pam的配置

还有些软件在./configure编译时加--enable-libpam这样的参数也是代表支持pam的配置
~~~



## PAM实例

### pam_nologin

**实例1**:  禁止所有非root用户登录

方法1: 使用脚本来实现

~~~powershell
#!/bin/bash

for user in `awk -F: '$3>=1000 && $3!=65534 && $NF=="/bin/bash" {print $1}' /etc/passwd`
do
        sed -i '/^'$user':/s/\/bin\/bash/\/bin\/false/' /etc/passwd
done
~~~



方法2: 使用pam的pam_nologin模块来实现

```powershell
根据/etc/pam.d/login的第四行来进行测试，这一行默认就有，不需要做任何修改
account    required     pam_nologin.so

# touch /etc/nologin
然后登出用户，再用普通用户登录测试，发现所有普通用户都登录不了系统了

# rm /etc/nologin  -rf
删除此文件，普通用户又可以登录
```

> 测试时，可以用init 3切换到3级别，然后使用普通用户登陆来测试，或者远程用普通用户ssh来测试。

> 不要使用su - 普通用户测试（或者你把上面一句加到/etc/pam.d/su配置文件里也可以限制)。



### pam_listfile

**实例2**: 使用pam实现服务登录的黑名单或白名单

```powershell
根据/etc/pam.d/vsftpd的第二行进行测试
auth       required	pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed

vsftpd服务本身有一个黑白名单文件/etc/vsftpd/user_list，然后pam_listfile模块为vsftpd模块又加了一层黑白名单，也就是说vsftpd是双重黑白名单
```

> 可以通过查看/var/log/secure日志看到pam相关的拒绝信息
>

> 前两个例子就是用于控制系统用户登录的，你可以将这两个模块应用到ssh,ftp,samba等相关服务也可以实现相同的效果



### pam_time

**实例3**:   使用pam实现时间控制

回顾把ssh托管到xientd里，使用access_times实现时间控制

~~~powershell
# yum install xinetd -y

# vim /etc/xinet.d/ssh
service ssh
{
        disable = no
        socket_type = stream
        protocol = tcp
        wait = no
        user = root
        server = /usr/sbin/sshd
        server_args = -i
        access_times = 14:45-14:59				xinetd里控制时间的参数
}

# systemctl stop sshd
# systemctl restart xinetd

~~~

使用pam_time模块实现时间控制

```powershell
对系统登陆加上时间控制
# vim /etc/pam.d/login	--把下面这句加到最前面
account     requisite     pam_time.so

# vim /etc/security/time.conf  	--然后修改这个配置文件，在最后加上
login;*;abc;!Th1700-1800		--表示针对login程序实现abc用户在任何终端（只对tty终端有效，图形登录无效）非周四的17点到18点才能登录

login;tty1;abc;!We1100-1300		--abc用户在周三的11点到13点不能在tty1登录系统，但可以在tty2,tty3等其它终端正常登录
```

~~~powershell
对sshd服务加上时间控制
# vim /etc/pam.d/sshd		--把下面这句加到最前面
account     requisite     pam_time.so

# vim /etc/security/time.conf 
sshd;*;abc;!Th1700-1800		--这样测试就是abc用户在周四的17点到18点不能ssh登录

课后练习：按上面原理对vsftpd（经测试,对vsftpd的匿名用户无效)或samba等实现时间控制。
~~~

### pam_tally2

**实例4**: 防止暴力猜root密码

```powershell
# vim /etc/pam.d/sshd		--把下面这句加到最前面
auth   required   pam_tally2.so deny=3 even_deny_root root_unlock_time=600 unlock_time=600

even_deny_root表示对root用户也生效
deny=3
root_unlocak_time=600表示root用户累计登录失败3次，就会锁定600秒(测试时建议30秒就可以了)

deny=3
unlock_time=600表示普通用户累计登录失败3次，就会锁定600秒(测试时建议30秒就可以了)


服务器端可以通过.命令查看连续失败的次数。成功ssh登录后,失败次数会清零。
服务器端也可以使用pam_tally2 --user=root --reset把连续失败次数清零。
```



### pam_cracklib(了解)

**实例5**:  控制密码复杂度(**拓展**)

注意: centos6及以前用的是pam_cracklib模块，centos7是pam_pwquality模块。但centos7上仍然可以使用pam_cracklib模块,pam_pwquality模块也完全兼容pam_cracklib模块的参数

~~~powershell
pam_cracklib.so用法
# vim /etc/pam.d/passwd		--在此文件最前面加上下面一行
password	required	pam_cracklib.so  minlen=8 minclass=4 difok=3 maxrepeat=3 maxsequence=5

测试：使用普通用户自己改自己的密码来测试（这里要求是长度为8，字符类型要包含4类:数字，小写字母，大写字母，符号;difok=3表示新改的密码和老密码最少需要变动3个字符)
maxrepeat=3表示重复相同字节不要超过3个，比如666可以，但6666就不行
maxsequence=5表示类似12345或febcd这种连续字节不能超过5位
~~~



```powershell
pam_pwquality用法
配置方法一:
# vim /etc/pam.d/passwd
password	required	pam_pwquality.so	dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minlen=8 disfok=3 retry=3	--参数写到这里，那么没写的参数会使用/etc/security/pwquality.conf文件里的默认值
配置方法二:
# vim /etc/pam.d/passwd
password	required	pam_pwquality.so	--这里不写参数，把参数写到/etc/security/pwquality.conf里
# vim /etc/security/pwquality.conf
dcredit=-1
ucredit=-1
lcredit=-1
ocredit=-1
minlen=8
disfok=3
retry=3
因为pam_pwquality模块兼容pam_cracklib模块的参数，所以下面主要介绍几个不同的参数:
dcredit=N：定义用户密码中最多包含N个数字(-1表示至少有一个)
ucredit=N：定义用户密码中最多包含N个大写字母
lcredit=N：定义用户密码中最多包含N个小些字母
ocredit=N：定义用户密码中最多包含N个特殊字符
```

~~~powershell
注意:这两个模块对root无效
建议就控制一下密码长度和字符类(minlen=8 minclass=4)就可以了，其它的参数有点变态，视具体情况使用
~~~



### pam_securetty

**实例6**:  控制root用户本地登录的终端(**拓展**)

```powershell
# vim /etc/pam.d/login	--验证此文件默认有的第一句pam_securetty模块
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so

# vim /etc/securetty
tty2		--只留下tty2，表示只能在tty2进行root用户登录（非root用户不受影响);还可以把这里的终端全去掉,实现root用户无法登录，只能使用普通用户登录(后面讲sudo会提到这种管理方式)

扩展:
# vim /etc/pam.d/sshd	--加上下面这一句
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
# vim /etc/securetty
tty2
ssh			--这里要加上ssh（不是sshd)才能允许远程ssh登录
```



~~~powershell
在vmware虚拟里切换终端快捷键为alt+F1-F6来切换
~~~

### pam_limits

**实例7**: 限制用户会话对系统资源的使用

```powershell
# vim /etc/pam.d/sshd	--把下面这句加到最前面
session    required     pam_limits.so

# vim /etc/security/limits.conf
abc     hard    maxlogins       2		--表示abc普通用户，最多只能ssh登录两个，第三个登录就会被拒绝

当然pam_limits.so模块还可以应用于很多其它资源限制场景，比如像oracle,nginx这种大并发的软件调大限制nofile(进程能打开的文件描述符数）,nproc（用户能打开的进程数），因为系统默认的限制比较保守。

此模块对root无效
```

> PAM资源限制针对用户,不针对进程. 如果需要实现进程资源限制,可以考虑使用Cgroup





### 课后思考题目

我有一个公网上的服务器，实现需求:

1. 拒绝root用户的本地登录(只允许本地tty5登录)和远程ssh登录

~~~powershell

~~~

2. 控制普通用户的密码复杂度为:小写字母，大写字母，数字，符号四类都需要，最小长度为10位，其它默认

~~~powershell

~~~

3. 控制普通用户远程ssh密码登录失败三次则锁定10分钟

~~~powershell

~~~

4. 控制普通用户远程ssh只能同时登录一个连接

~~~powershell

~~~

5. 控制普通用户只能7:00-22:00点才能远程ssh登录

~~~powershell

~~~



# sudo

## sudo介绍

问题：

1. 按上面pam的题目需求,都使用普通用户来操作确实很安全,普通用户并没有一些操作的权限,如何解决?

2. root用户权限太大，运维工程师如何防止自己误操作？



man sudo得到的标准定义为execute a command as another user,意为用另一个用户的身份来执行命令。

在前面的学习中遇到的能够转换用户身份来执行命令的方法有:

1,  suid,sgid(也就是s位:`-rwsr-xr-x`) 

2, 使用脚本切换用户身份

~~~powershell
su - user1 << EOF
touch 123
exit
EOF
~~~

3, `su - user1 -c "touch 123"`



## sudo实例

**实例1**: root授予普通用户abc所有权限（此做法安全隐患大），实际环境尽量考虑**==权限最小化==**

```powershell
# useradd abc
# echo 123 | passwd --stdin abc
# vim /etc/sudoers

 91 root    ALL=(ALL)       ALL
 92 abc     ALL=(ALL)       ALL		--加上这一句表示把所有的相关权限给abc用户 
 #允许abc用户 在任何主机=(以任何人身份)  执行任何命令


# su - abc
$ touch /root/abc			--abc不允许在root家目录创建文件
touch: cannot touch `/root/abc': Permission denied

$ sudo touch /root/abc			--命令前加sudo，第一次使用sudo，会有下面的一段话

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for abc:	--输入的是abc的密码，而不是root的密码，就可以成功创建 

$ sudo ls -l /root/abc		--再次用sudo就不需要输入密码了，也可以看到其实还是用的root的身份
-rw-r--r-- 1 root root 0 Nov  7 09:59 /root/abc
```



**补充**

~~~powershell
# vim /etc/sudoers

 91 root    ALL=(ALL)       ALL
 92 abc     ALL=(ALL)       ALL
 93 aaa     ALL=(ALL)       NOPASSWD: ALL		NOPASSWD代表自己的密码都不用输入了
~~~



**实例2**: 直接使用**完整命令**授予普通用户abc部分权限

```powershell
# vim /etc/sudoers

 91 root    ALL=(ALL)       ALL
 92 abc     ALL=/usr/bin/touch /root/222,/usr/bin/touch /root/333  
 
这里表示只给abc用户touch /root/222和touch /root/333的权限，那么abc想sudo ls -l /root/222都不行。（注意，命令要写绝对路径)
```

**实例3**: 使用**命令**授予普通用户abc部分权限

```powershell
# vim /etc/sudoers

 91 root    ALL=(ALL)       ALL
 92 abc		ALL=/usr/sbin/route
 
 这里表示abc用户可以使用route命令的所有权限，包括使用route增删路由，增删网关等
```

**实例4**: 使用**命令别名**授予普通用户abc部分权限

```powershell
# vim /etc/sudoers

Cmnd_Alias NETWORKING = /usr/sbin/route,/usr/sbin/ifconfig

root    ALL=(ALL)       ALL
abc     ALL=NETWORKING    

多条命令可以一起定义一个别名，然后直接把别名授权给用户
```



**练习题目**:  

运维组长老李（root)，手下有5个新员工。现在分配各自的权限，规则如下：

网络路由管理: 张三(zhangsan)，李四(lisi)

磁盘管理: 王五(wangwu)，马六(maliu) 

软件包管理: 田七(tianqi)

如何实现?

~~~powershell

~~~



小结: root用户授予相应的权限给普通用户（权限最小化的原则），普通用户就可以不使用root密码来实现root相应的权限，即使做了误操作，也能相应防护。





