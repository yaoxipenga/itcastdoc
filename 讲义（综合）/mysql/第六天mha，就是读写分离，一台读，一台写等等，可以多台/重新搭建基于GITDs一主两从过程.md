## 1,三台`/mysql56/etc/my.cnf`配置文件如下

**master的**

~~~powershell
[mysqld]
port=3307
datadir=/mysql56/data
log-error=/mysql56/data/mysql56-err.log
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
user=mysql

log-bin=master
server-id=100

gtid-mode=on
log-slave-updates=1
enforce-gtid-consistency
~~~

**slave1的**

~~~powershell
[mysqld]
port=3307
datadir=/mysql56/data
log-error=/mysql56/data/mysql56-err.log
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
user=mysql


server-id=200

log-bin=slave1
gtid-mode=on
log-slave-updates=1
enforce-gtid-consistency

~~~

**slave2的**

~~~powershell
[mysqld]
port=3307
datadir=/mysql56/data
log-error=/mysql56/data/mysql56-err.log
pid-file=/mysql56/data/mysql56.pid
socket=/tmp/mysql56.sock
user=mysql


server-id=300

log-bin=slave2
gtid-mode=on
log-slave-updates=1
enforce-gtid-consistency
~~~





## 2, 三台mysql都做以下操作

~~~powershell
# pkill mysql

# rm /mysql56/data/* -rf


# /mysql56/scripts/mysql_install_db --datadir='/mysql56/data/' --basedir=/mysql56  --user=mysql

# /mysql56/bin/mysqld_safe --defaults-file='/mysql56/etc/my.cnf' &
~~~



## 3, 只在master和slave1上授权

~~~powershell
mysql> grant replication slave on *.* to 'slave'@'%' identified by '123';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
~~~



## 4,在 slave1和slave2配置为master的从

~~~powershell

mysql> change master to master_host='10.1.1.11',master_port=3307,master_user='slave',master_password='123',master_auto_position=1;
Query OK, 0 rows affected, 2 warnings (0.03 sec)

mysql> start slave;

mysql> show slave status\G
~~~

