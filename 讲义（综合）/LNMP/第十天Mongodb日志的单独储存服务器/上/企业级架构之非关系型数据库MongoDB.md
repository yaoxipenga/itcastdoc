typora-copy-images-to: ./media

# 企业级架构之MongoDB

# 学习目标

1、能够简单描述MongoDB的使用特点

2、能够安装配置启动MongoDB

3、能够使用命令行客户端简单操作MongoDB

4、能够实现基本的数据操作

5、能够实现MongoDB基本安全设置

6、能够操作安装php的MongoDB扩展

# 一、背景描述及方案设计

## 1、业务背景描述

时间：2017.6-2017.9

发布产品类型：互联网动态站点 商城

用户数量： 25000-30000（用户量猛增）

PV ： 1000000-5000000（24小时访问次数总和）

DAU： 5000（每日活跃用户数）

根据业务需求：

用户访问日志是在web服务器access.log存储

## 2、模拟运维设计方案

![image-20190709011039458](media/image-20190709011039458-2605839.png)

根据以上业务需求，采用mongodb数据库存储用户的访问日志，使用单台服务器

① 访问日志存储

② 在mongo中筛选查看信息

# 二、MongoDB概述

## 1、MongoDB介绍

![image-20190709011341316](media/image-20190709011341316-2606021.png)

数据库排名：<https://db-engines.com/en/ranking>

关系数据库 RDBMS   设计表结构，通过SQL语句进行操作。

常见的关系型数据库：mysql  oracle（商业） DB2（IBM） sqlserver（微软） access（微软） sqlite3（小型 嵌入到APP中） postgresql（加州伯克利大学）

nosql 泛指非关系数据库 存储格式key=>value

memcached   redis 内存缓存数据库

mongodb  具有更多的功能，可以适用于大部分的mysql场景	document store 文档型数据库

存储介质：

关系型数据库大部分存储在硬盘中（MySQL/Mariadb/SQL Server/Oracle）

非关系型数据库大部分存储在内存中（MongoDB/Redis）

## 2、产品特点

☆ 存储性

比较适合存储大量的没有规则、无序的数据。

存储量大：单表实现存储PB级别的数据。

1KB = 1024B

1M = 1024KB

1G = 1024M

1TB = 1024G

1PB = 1024TB

☆ 效率性

数据的效率，就是指存储和读写速度。

MongoDB效率（对比MySQL）

![1562664023497](media/1562664023497.png)

## 3、术语与概念

| SQL术语/概念 | MongoDB术语/概念 | 解释/说明                           |
| ------------ | ---------------- | ----------------------------------- |
| database     | database         | 数据库                              |
| table        | collection       | 数据库表/集合                       |
| row          | document         | 数据记录行/文档                     |
| column       | field            | 数据字段/域                         |
| index        | index            | 索引                                |
| table joins  |                  | 表连接,MongoDB不支持                |
| primary key  | primary key      | 主键,MongoDB自动将_id字段设置为主键 |

# 三、安装与配置

## 1、下载MongoDB

yum方式安装：<https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/>

手动通用安装：<https://docs.mongodb.com/manual/tutorial/install-mongodb-on-linux/>

## 2、二进制方式安装

第一步：解压mongodb

```powershell
shell > tar xvf mongodb-linux-x86_64-4.0.10.tgz
shell > mv mongodb-linux-x86_64-4.0.10 /usr/local/mongodb
```

目录介绍

```powershell
# ls /usr/local/mongodb/bin
mongo  : 客户端
mongod : 服务器端，d代表daemon后台运行
```

第二步：创建存储目录与日志目录

```powershell
# cd /usr/local/mongodb
# mkdir data
# mkdir logs
```

第三步：启动mongodb

```powershell
# cd /usr/local/mongodb/bin
# ./mongod --dbpath=/usr/local/mongodb/data --logpath=/usr/local/mongodb/logs/mongodb.log --fork
```

参数介绍：

dbpath  数据存储路径

logpath 日志存储路径

fork        后台启动

auth       权限开启

bind_ip  指定绑定网卡ip

## 3、mongo命令行操作

```powershell
# /usr/local/mongodb/bin/mongo
> help
...
> db.help()
```

# 四、数据结构类型操作

## BSON格式

MongoDB里存储数据的格式文档形式，以BSON格式的文档形式：

```powershell
参考百科说明：BSON( Binary Serialized Document Format) 是一种二进制形式的存储格式，采用了类似于 C 语言结构体的名称、对表示方法，支持内嵌的文档对象和数组对象，具有轻量性、可遍历性、高效性的特点，可以有效描述非结构化数据和结构化数据。

BSON是一种类JSON的一种二进制形式的存储格式，简称Binary JSON，它和JSON一样，支持内嵌的文档对象和数组对象，但是BSON有JSON没有的一些数据类型，如Date和BinData类型。
BSON可以做为网络数据交换的一种存储形式，这个有点类似于Google的Protocol Buffer，但是BSON是一种schema-less的存储形式，它的优点是灵活性高，但它的缺点是空间利用率不是很理想，
BSON有三个特点：轻量性、可遍历性、高效性。
```

```javascript
{
    title:"MongoDB",
    last_editor:"192.168.1.122",
    last_modified:new Date("27/06/2011"),
    body:"MongoDB introduction",
    categories:["Database","NoSQL","BSON"],
    revieved:false
}
```

这是一个简单的BSON结构体，其中每一个element都是由key/value对组成的。

## 1、插入数据

```powershell
# use itheima   => 切换数据库，没有则自动创建同名数据库
# db.getName() 	=> 获取当前库的名称
-------------------------------------------------
基本语法：
db.集合名称.insert（bson格式数据）
```

### ☆ 普通数据

```powershell
# db.goods.insert({title:'huawei p30',price:5999,weight:135,number:35})
拆解：
# db.goods（集合===数据表）.insert插入
{
	title:'huawei p30',
	price:5999,
	weight:135,
	number:35
}
```

### ☆ 多维数据

```powershell
# db.goods.insert({name:'xiaomi9',price:2999,weight:156,number:45,area:{province:'hubei',city:'wuhan'}})

{
	name:'xiaomi9',
	price:2999,
	weight:156,
	number:45,
	area:{
		province:'hubei',
		city:'wuhan'
	}
}
```

### ☆ 数组数据

```powershell
# db.goods.insert({name:'iphone xr',price:6800,weight:180,number:100,area:{province:'guangdong',city:'shenzhen'},color:['black','white','red']})

{
	name:'xiaomi9',
	price:2999,
	weight:156,
	number:45,
	area:{
		province:'hubei',
		city:'wuhan'
	},
	color:['black','white','red']
}
```

## 2、查询数据

```powershell
基本语法：
db.集合名称.find(查询条件)  		=> 查询所有数据 => 结合pretty()
db.集合名称.findOne(查询条件)       => 查询指定数据
```

### ☆ 普通查询

满足查询条件的所有信息，全部取出来

```powershell
# db.goods.find()
```

findOne会取出满足查询条件的第一条信息，并且以格式化形式返回

```powershell
# db.goods.findOne()
```

### ☆ 条件查询

```powershell
# db.goods.find({name:'xiaomi9'})
# db.goods.findOne({name:'xiaomimax'})
```

### ☆ 范围查询

```powershell
mysql   <    <=    >    >=   !=
mongo  $lt  $lte  $gt  $gte  $ne

$lt = litter than
$lte = litter than equal
$gt = greater than
$gte = greater than equal
$ne = not equal
```

案例：

```powershell
# db.goods.find({price:{'$lt':3000}})
# db.goods.find({price:{'$gt':3000}})
```

### ☆ 多字段查询

类似MySQL中的AND，基本语法：

```powershell
# db.goods.find({price:{'$gt':5000},number:{'$gte':40}})
```

### ☆ 多维字段查询

```powershell
# db.goods.find({'area.city':'shenzhen'})
```

==注意：多维字段需要用引号包含起来==

### ☆ 数组条件查询

① 查询满足其中之一即可显示

```powershell
# db.goods.find({color:'black'})
```

② 满足查询条件所有的才可显示

```powershell
# db.集合名称.find({字段(数组):{'$all':[v1,v2]}})
```

```powershell
# db.goods.insert({name:'iphone xs',price:8398,weight:100,number:200,area:{province:'jiangsu',city:'nanjing'},color:['gray','black','white','gold']})

# db.goods.find({color:{'$all':['black','gold']}})
```

### ☆ 限制字段查询

在实际使用环境，不需要查询并显示太多的字段。可以选择设定显示。

```powershell
语法：db.集合名称.find({查询条件},{筛选条件})
显示为1,不显示为0   
特别注意：field要是1必须所有都是1，要是0必须都是0，_id除外
```

案例1：

```powershell
# db.goods.find({color:{'$all':['black','gold']}},{name:1,_id:0})
```

_id是mongodb数据库里的集合中，默认的主键id，具有索引内容，通过主键查询，会很快的查询速度。不要随意修改此值，使用默认即可。

### ☆ 多条件或查询

满足其中之一的条件就可以显示，类似MySQL的中的or条件

select * from goods where price > 5000 or number >= 100

```powershell
# db.goods.find({'$or':[{price:{'$gt':5000}},{number:{'$gte':100}}]})
```

### ☆ count总记录查询

返回总记录数

```powershell
# db.goods.count()
# db.goods.find({price:{'$gt':5000}}).count()
# db.goods.count({price:{'$gt':5000}})
```

### ☆ limit与skip限制查询

类似于MySQL中的limit(skip,length)语法

limit()  取几个

skip()   跳过几个

```powershell
# db.goods.find().limit(1);
# db.goods.find().skip(1).limit(1);
```

## 3、修改数据

```powershell
语法：db.集合名称.update({查询条件},{修改条件})
     db.集合名称.updateOne()   修改匹配的第一条
     db.集合名称.updateMany()  修改匹配的所有条
```

### ☆ 有$set的修改

```powershell
db.goods.update({name:'iphonex'},{'$set':{price:8500}})
注：如果price不存在，则添加price字段

db.goods.updateOne({name:'xiaomi5'},{'$set':{price:1500}})
```

### ☆ 无$set的修改

没有$set关键字语法，把设置的字段进行修改,没有设置的就会被删除掉

```powershell
db.goods.update({name:'iphonex'},{price:8550})
```

## 4、删除数据

### ☆ 删除记录

```powershell
语法：db.集合名称.remove({查询条件})
	 db.集合名称.deleteOne()   删除匹配的第一条
	 db.集合名称.deleteMany()  删除匹配的多条
```

```powershell
db.goods.remove({price:8550})
db.goods.deleteMany({price:{'$lte':2000}})
```

值给一个就可以删除了

真实业务当中，一般不做物理删除，会使用一个标识，来确认是否已经被删除的数据

###　☆ 删除字段

可以删除某个字段的操作，使用的是update语法的$unset

```powershell
db.goods.update({title:'huawei p30'},{'$unset':{weight:135}})
```

# 五、安全设置

<https://docs.mongodb.com/manual/tutorial/create-users/>

mongodb安全事件：<https://www.jianshu.com/p/48d17a69e190>

## 1、限制登录

用另外一台虚拟机，使用mongo命令行端进行测试

远程登录方法

第一步：求帮助

```powershell
# ./mongo --help
# ./mongo 10.1.1.23
Error:couldn't connect to server 10.1.1.20:27017, connection attempt failed
```

第二步：关闭mongodb

```powershell
# db.shutdownServer()
try 'use admin'
# use admin
# db.shutdownServer()
```

第三步：添加conf/mongodb.conf文件

```powershell
# vim conf/mongodb.conf
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/logs/mongodb.log
fork=true
logappend=true
port=27017
auth=false
bind_ip=127.0.0.1,10.1.1.23
```

第四步：添加mongodb.service

```powershell
# vim /usr/lib/systemd/system/mongodb.service

[Unit]
Description=MongoDB
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/usr/local/mongodb/bin/mongod --shutdown -f /usr/local/mongodb/conf/mongodb.conf
PrivateTmp=true

[Install]
WantedBy=multi-user.target

# chmod +x /usr/lib/systemd/system/mongodb.service
# systemctl daemon-reload
```

重启mongodb

## 2、用户权限

需求：设置一个超级管理员账户，对于所有库具有读写权限

```powershell
登录mongodb
> use admin
> db.createUser({user:"root",pwd:"root",roles:["root"]})

注：roles代表角色，具体参考
https://docs.mongodb.com/manual/reference/built-in-roles/#all-database-roles
```

重启mongodb，在配置文件mongodb.conf中加入auth参数：

```powershell
auth=true
```

验证权限：

```powershell
use admin
db.auth('root','root')
```

# 六、企业级MongoDB案例

## 1、php mongodb扩展

① 上传php扩展包

② 解压编译安装

```powershell
shell > tar xvf mongodb-1.5.3.tgz
shell > cd mongodb-1.5.3
shell > phpize
shell > ./configure && make && make install
```

③ 查看redis.so

```powershell
# ls /usr/local/php/lib/php/extensions/no-debug-zts-20170718
```

④ 添加extension=mongodb.so到php.ini

```powershell
shell > vim /usr/local/php/etc/php.ini
extension=mongodb.so
```

⑤ 重启php-fpm查看phpinfo

![1562716089180](media/1562716089180.png)

## 2、桌面管理使用Studio 3T

软件是绿色版本，直接解压，点击使用即可

![1562716321165](media/1562716321165.png)

![1562716361925](media/1562716361925.png)

## 3、日志统计展示

很多网站需要统计某个页面或者某个功能访问量，如果访问量比较大，需要记录的组件具有很快的读写效率。可以使用功能性更多的mongodb来完成此业务。mongodb具有更多的数据灵活性。

网站访问日志记录的信息：

ip 用户访问的来源ip

url  用户访问的地址  功能模块页面地址

time  访问时间  记录用户访问的时间值

user_agent 用户访问的客户端信息

修改Web服务器（web01与web02）中的/home/www/public/index.php，如下图所示：

```powershell
<?php
// +----------------------------------------------------------------------
// | ThinkPHP [ WE CAN DO IT JUST THINK ]
// +----------------------------------------------------------------------
// | Copyright (c) 2006-2016 http://thinkphp.cn All rights reserved.
// +----------------------------------------------------------------------
// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
// +----------------------------------------------------------------------
// | Author: liu21st <liu21st@gmail.com>
// +----------------------------------------------------------------------
// [ 应用入口文件 ]

// 定义应用目录
define('APP_PATH', __DIR__ . '/../application/');
$data = array(
  // 用户访问的ip
  'ip' => $_SERVER['REMOTE_ADDR'],
  // 访问地址
  'url' => $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],
  // 用户访问的客户端信息
  'agent' => $_SERVER['HTTP_USER_AGENT'],
  // 访问的时间
  'time' => time()
);
// 连接管理数据库
$manager = new MongoDB\Driver\Manager('mongodb://root:root@10.1.1.23/admin');
// 实列化写入方法
$bulk = new MongoDB\Driver\BulkWrite;
$rs = $bulk->insert($data);
// 执行语句
$result = $manager->executeBulkWrite('dsshop.logs', $bulk);
// 加载框架引导文件
require __DIR__ . '/../thinkphp/start.php';

注：负载均衡时，获取真实的客户端IP，需要使用'ip' => $_SERVER['HTTP_X_FORWARDED_FOR']
```

运行结果：

![1562753032266](media/1562753032266.png)

## 4、MongoDB备份与还原

### ☆ 备份数据

```powershell
# mongodump -h dbhost -d dbname -o dbdirectory
```

案例：全库备份

```powershell
# bin/mongodump -h 10.1.1.24 -u root -p root --authenticationDatabase=admin
```

案例：对指定库进行备份

```powershell
# bin/mongodump -h 10.1.1.24 -u root -p root --authenticationDatabase=admin -d itheima -o /tmp/mongobak
```

### ☆ 恢复数据

```powershell
# mongorestore -h dbhost -d dbname --dir dbdirectory
补充：
--drop： 恢复的时候，先删除当前数据，然后恢复备份的数据。就是说，恢复后，备份后添加修改的数据都会被删除，慎用！
```

案例：对itheima进行还原

```powershell
# bin/mongorestore -h 10.1.1.24 -u root -p root --authenticationDatabase=admin -d itheima --dir /tmp/mongobak/itheima
```

