# LDAP(拓展)

LDAP  轻量级目录访问协议（Lightweight Directory Access Protocol）




关系型数据库   

员工表

| 工号 | 姓名 | 性别 | 生日       | 工资  | 奖金  | 部门 | 职位 | 上级领导工号 |
| ---- | ---- | ---- | ---------- | ----- | ----- | ---- | ---- | ------------ |
| 100  | 张三 | 男   | 1990-01-01 | 10000 | 50000 | it   | 1    | 10           |
| 101  | 李四 | 男   | 1991-01-01 | 10000 | 50000 | it   | 2    | 10           |




ldap树状结构


```powershell
			o=itcast公司 (dc=itcast,dc=com)
					|
	|－－－－－－－－－｜－－－－－－－－－－｜
  ou=管理层        ou=员工		 ou=部门分组
     				|
	 				|
			|－－－－－－－－－－｜
			cn=张三		cn=李四
```

**ldap名词概念**

cn=zhangsan,dc=itcast,dc=com

ou=it,dc=itcast,dc=com

| 名词 | 说明                                     |
| ---- | ---------------------------------------- |
| c    | countryName（国家）                      |
| o    | organization（组织-公司）                |
| ou   | organization unit（组织单元-部门）       |
| dc   | domainComponent（域名）                  |
| cn   | common name（常用名称）                  |
| dn   | Distinguished Name唯一名，不能与其它重复 |

**实验准备:** 准备一台虚拟机做ldap服务器

1. 主机名
2. 关闭防火墙,selinux
3. 时间同步
4. 配置本地yum源

**实验过程:**

第1步: 安装相关软件包

~~~powershell
只需要本地yum源就可以了
# yum install openldap openldap-servers openldap-clients  openldap-devel  migrationtools

# slapd -V			--确认版本
@(#) $OpenLDAP: slapd 2.4.40 (Nov  6 2016 01:21:28) $
	mockbuild@worker1.bsys.centos.org:/builddir/build/BUILD/openldap-2.4.40/openldap-2.4.40/servers/slapd
~~~

第2步: 拷贝数据库模版文件,修改权限并启动服务

~~~powershell
# cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG	
# chown ldap.ldap -R /var/lib/ldap/

先确认389端口没有启动，如果已经启动了可以pkill slapd杀掉进程，再启动
# netstat -ntlup |grep :389

# systemctl start slapd
# systemctl enable slapd

# netstat -ntlup |grep :389
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      10270/slapd         
tcp6       0      0 :::389                  :::*                    LISTEN      10270/slapd    
~~~

第3步:设置管理员密码，并添加到配置文件中

~~~powershell
# slappasswd 
New password: 
Re-enter new password: 
{SSHA}g/4TYKKn1rcat7Ebvm0HIoHzo3Nzdi8X

# vim /tmp/change_root_pw.ldif				--LDIF（LDAP Interchange Format）格式
dn: olcDatabase={0}config,cn=config			--代表/etc/openldap/slapd.d/cn\=config/olcDatabase\=\{0\}config.ldif文件(此版本不要直接用vi去修改配置文件，需要写成ldif文件再ldapadd增加到配置文件)
changetype: modify					--要对文件做修改（add也是修改)
add: olcRootPW						--增加一个叫olcRootPW的条目
olcRootPW: {SSHA}g/4TYKKn1rcat7Ebvm0HIoHzo3Nzdi8X	--增加的密码为前面用slappasswd命令创建的密码


# ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/change_root_pw.ldif 			－－导入数据，导入后可以去/etc/openldap/slapd.d/cn\=config/olcDatabase\=\{0\}config.ldif文件里查看多了一行olcRootPW条目
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={0}config,cn=config"

~~~

第4步: 向LDAP中导入一些基本的 Schema。

这些Schema文件位于/etc/openldap/schema/目录中，schema控制着条目拥有哪些对象类和属性

~~~powershell
# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=cosine,cn=schema,cn=config"

# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=nis,cn=schema,cn=config"

# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=inetorgperson,cn=schema,cn=config"
~~~

第5步: 配置自己的域为dc=itcast,dc=com，管理员为cn=admin,dc=itcast,dc=com

~~~powershell
# cat /tmp/change_domain.ldif
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=admin,dc=itcast,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=itcast,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,dc=itcast,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}g/4TYKKn1rcat7Ebvm0HIoHzo3Nzdi8X 		--密码对应前面的

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=admin,dc=itcast,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=admin,dc=itcast,dc=com" write by * read


# ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/change_domain.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}monitor,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"


# slaptest -u		--测试配置文件是否有异常
config file testing succeeded
~~~

第6步:把基本的域信息定义并导入

~~~powershell
				dc=itcast,dc=com
					|
		|－－－－－－－－－－－－－－－－－－｜

		people						group
		用户							组

		zhangsan				zhangsan
		lisi					lisi


# cat /tmp/basedomain.ldif
dn: dc=itcast,dc=com
changetype: add
objectClass: top
objectClass: dcObject
objectClass: organization
o: itcast Company
dc: itcast

dn: cn=admin,dc=itcast,dc=com
changetype: add
objectClass: organizationalRole
cn: admin

dn: ou=People,dc=itcast,dc=com
changetype: add
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=itcast,dc=com
changetype: add
objectClass: organizationalRole
cn: Group

# ldapmodify -x -D cn=admin,dc=itcast,dc=com  -W  -f /tmp/basedomain.ldif
Enter LDAP Password: 		--输入前面定义的密码
adding new entry "dc=itcast,dc=com"

adding new entry "cn=admin,dc=itcast,dc=com"

adding new entry "ou=People,dc=itcast,dc=com"

adding new entry "ou=Group,dc=itcast,dc=com"

~~~

第7步: 导入数据（可以自己写ldif文件导入，也可以使用我下面的做法:把/etc/passwd,/etc/shadow里的用户信息migrate成ldif文件，再导入)

~~~powershell
# vim /usr/share/migrationtools/migrate_common.ph

71 $DEFAULT_MAIL_DOMAIN = "itcast.com";

74 $DEFAULT_BASE = "dc=itcast,dc=com";
90 $EXTENDED_SCHEMA = 1;

# useradd zhangsan
# useradd lisi
# echo 123456 | passwd --stdin zhangsan
Changing password for user zhangsan.
passwd: all authentication tokens updated successfully.
# echo 123456 | passwd --stdin lisi
Changing password for user lisi.
passwd: all authentication tokens updated successfully.


# tail -2 /etc/passwd > /tmp/user
# tail -2 /etc/group > /tmp/group

# /usr/share/migrationtools/migrate_passwd.pl /tmp/user > /tmp/user.ldif
# /usr/share/migrationtools/migrate_group.pl /tmp/group > /tmp/group.ldif

# ldapadd -x -D cn=admin,dc=itcast,dc=com  -W  -f /tmp/user.ldif 
Enter LDAP Password: 
adding new entry "uid=zhangsan,ou=People,dc=itcast,dc=com"

adding new entry "uid=lisi,ou=People,dc=itcast,dc=com"

# ldapadd -x -D cn=admin,dc=itcast,dc=com  -W  -f /tmp/group.ldif 
Enter LDAP Password: 
adding new entry "cn=zhangsan,ou=Group,dc=itcast,dc=com"

adding new entry "cn=lisi,ou=Group,dc=itcast,dc=com"
~~~

第8步: 安装图形管理openldap的工具phpldapadmin

```powershell
# yum install epel-release
# yum install httpd php php-ldap php-gd php-mbstring php-pear  php-xml php-bcmath php-mbstring  phpldapadmin	--php-bcmath和php-mbstring在centos163源里,phpldapadmin在epel源里


# vim /etc/phpldapadmin/config.php
$servers->setValue('login','attr','dn');		--397行，打开注释
// $servers->setValue('login','attr','uid');		--398行，注释掉


# vim /etc/httpd/conf.d/phpldapadmin.conf


<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require local
    Require ip 192.168.72.0/24				--指定允许访问的IP或网段
  </IfModule>

# systemctl restart httpd
# systemctl enable httpd



http://10.1.1.12/phpldapadmin/			--用浏览器访问

用户名:cn=admin,dc=itcast,dc=com
密码:						--前面自己定义的密码

```

第9步: 客户端操作

~~~powershell
# yum install nss-pam-ldapd

# authconfig-tui	--把Use LDAP和Use LDAP Authentication前打*，把Use Shadow Passwords前面的*去掉

下一步:填上ldap服务器的ip和dn
ldap://10.1.1.12
dc=itcast,dc=com
~~~

第10步: 测试:

~~~powershell
下面的命令发现zhangsan,lisi,wangwu用户可以用id命令查出来（但是客户端自己是没有这几个用户的,说明是通过ldap服务器验证得到的)
# id zhangsan
uid=1001(zhangsan) gid=1001(zhangsan) groups=1001(zhangsan)
# id lisi
uid=1002(lisi) gid=1002(lisi) groups=1002(lisi)
# id wangwu
uid=1003(wangwu) gid=1003(wangwu) groups=1003(wangwu)
~~~