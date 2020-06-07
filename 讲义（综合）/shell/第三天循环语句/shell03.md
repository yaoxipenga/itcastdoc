# Linux shell编程三

#课程目标

- [ ] 掌握for循环语句的基本语法结构
- [ ] 掌握while和until循环语句的基本语法结构
- [ ] 能使用RANDOM变量产生随机数
- [ ] 理解嵌套循环



**易混符号小结**

| 符号                 | 说明                       |
| -------------------- | -------------------------- |
| $( )                 | 执行符                     |
| `` 反撇号,不是单引号 | 执行符                     |
| $[ ]                 | 运算符                     |
| $(( ))               | 运算符                     |
| ${ }                 | 获取变量并可以做截取       |
| [  ]                 | 判断条件                   |
| [[  ]]               | 判断条件，里面可以使用正则 |



# 一、循环语句

**生活中的循环**

![1555066558898](pictures/循环场景.png)

运维维护中经常会出现重复多次执行的工作,如批量建用户,批量删除文件等。利用shell里的循环语句可以很好地帮我们解决问题。



## 1. for循环

**特点**: 多用于已知次数的循环(**定循环**)，比如循环100次，循环一个目录下的文件，这些都是有一定次数的。

### for循环语法结构

```powershell
for variable in 1 2 3 4 5
do
	command
	command
	......
done

```

~~~powershell
for(( expr1;expr2;expr3 ))				# 类C风格的for循环
do
	command
	command
	......
done

expr1：定义变量并赋初值
expr2：决定是否进行循环（条件）
expr3：决定循环变量如何改变，决定循环什么时候退出
~~~

### for结构循环数字或字母

~~~powershell
#!/bin/bash

for i in 1 2 3 4 5
do
        echo $i
done
~~~

其它示例:

```powershell
# for i in `seq 10`;do echo $i;done
# for i in $(seq 10);do echo $i;done
# for i in `seq 10 -2 1`;do echo $i;done

# for i in {1..10};do echo $i;done
# for i in {0..10..2};do echo $i;done			# 大括号中第3个数字2为一步的长度
# for i in {10..1};do echo $i;done
# for i in {10..1..-2};do echo $i;done

# for ((i=1;i<=5;i++));do echo $i;done
# for ((i=1;i<=10;i+=2));do echo $i;done
# for ((i=10;i>=1;i-=2));do echo $i;done

# for i in {a..z}; do echo $i; done
```

示例: 用循环实现计算1+2+3的和

~~~powershell
#!/bin/bash

sum=0

i=1
sum=$[$sum+$i]
# sum结果为0+1=1

i=2
sum=$[$sum+$i]
# sum结果为1+2=3

i=3
sum=$[$sum+$i]
# sum结果为3+3=6

~~~

~~~powershell
sum=0
for i in {1..3}
do
        sum=$[$sum+$i]
done
echo $sum
~~~



**示例:**计算1到100的奇数之和

```powershell
思路：
1. 定义一个变量来保存奇数的和	sum=0
2. 找出1-100的奇数，保存到另一个变量里  i
3. 从1-100中一个一个地找出奇数后，再相加，然后将和赋值给sum变量
4. 循环完毕后，将sum的值打印出来
```

~~~powershell
#!/bin/bash

sum=0
for i in {1..100..2}
do
        sum=$[$sum+$i]
done
echo $sum
~~~



### **循环控制语句**

**循环体：** ==do....done==之间的内容

- continue：继续；表示==循环体==内下面的代码不执行，重新开始下一次循环
- break：打断；马上停止循环，执行==循环体==后面的代码
- exit：表示直接跳出程序

**示例:** 改写计算1到100的奇数之和

~~~powershell
用continue来改写
sum=0
for i in {1..100}
do
        if [ $[$i%2] -eq 0 ];then
                continue
        fi
        sum=$[$sum+$i]
done
echo $sum
~~~

**示例:** 批量加10个用户, 以student1到student10命名，并统一加一个新组，组名为class,统一改密码为123

~~~powershell
#!/bin/bash

groupadd class

# 思路如下
#useradd student1 -G class
#echo 123 | passwd --stdin student1 &> /dev/null


#useradd student2 -G class
#echo 123 | passwd --stdin student2 &> /dev/null


#useradd student3 -G class
#echo 123 | passwd --stdin student3 &> /dev/null
#......

# 把上述思路做成循环
for i in {1..10}
do
        useradd student$i -G class
        echo 123 | passwd --stdin student$i &> /dev/null
done
~~~

**示例:** 批量删除上例建立的10个用户（包括把用户的家目录和邮件目录给删除干净),并删除class组

~~~powershell
#!/bin/bash

for i in student{1..10}
do
        userdel -r $i &> /dev/null
done
groupdel class
echo "删除成功"
~~~



### for结构循环linux文件

比较下列两段的区别:

~~~powershell
for file in /etc/*
do
	echo $file
done

for file in $(find /etc)
do
	echo $file
done
~~~

**示例**: 找出/usr/share/doc目录下所有文件名为index.html的文件，把他们拷到/tmp/index目录下，文件名按找到的先后更改，第一个找到的为index.html.1,第二个找到的为index.html.2。。。。以此类推

~~~powershell
#!/bin/bash

rm -rf /tmp/index/
mkdir /tmp/index/ -p

count=1
for file in $(find /usr/share/doc/ -name "index.html")
do
	cp $file /tmp/index/index.html.$count
	count=$[$count+1]				# 或者let count++
done
~~~

**练习: read输入一个目录,查找此目录下所有的死链接文件**

~~~powershell
#!/bin/bash

read -p "输入一个目录:" dir

if [ ! -d $dir ];then
        echo "你输入的不是目录"
        exit
fi

for file in $(find $dir -type l)
do
        if [ ! -e $file ];then
                echo "$file是死链接文件"
        fi
done
~~~



## 2. while循环

**特点：**条件为真就进入循环；条件为假就退出循环.多用于不定次数的循环

for循环常用于**定循环**，while循环常用于**不定循环**，很多场景两个都可以用

如:  

6点-18点，每个小时整点循环（定了次数，每天都会有6点-18点） 

当有太阳，每个小时整点循环（不定次数，天气和季节都会影响是否有太阳）

### while循环语法结构

~~~powershell
while 条件
do
      条件满足时候:执行动作一
	  条件满足时候:执行动作二
      ......
done
~~~



**示例:** 用for循环与while循环做比较打印1-5

~~~powershell
for ((i=1;i<=5;i++))			
do
	echo $i
done

i=1
while [ $i -le 5 ]
do
	echo $i
	let i++
done
~~~



### 死循环

死循环就是一直循环，除非使用循环控制语句跳出

~~~powershell
while true			条件永远为true,所以会一直循环下去
do
	command
done
~~~

```powershell
其它的死循环写法,不要去记，会上面一种即可
while :
do
	command
done

for (( ;1; ))
do
	command
done

for ((i=1;;i++))
do
	command
done
```

示例: 每隔1秒钟打印累加的数字

~~~powershell
#!/bin/bash

a=1
while true
do
        echo $a
        let a++
        sleep 1						# 等待1秒
done
~~~



**示例:** 

写一个30秒同步一次时间，同步服务器为10.1.1.12的脚本,如果同步失败,则使用logger记录到/var/log/messages里,每次失败都记录;同步成功,也进行日志记录,但是成功100次才记录一次。

**准备工作:**

![1555248906996](pictures/时间同步环境图.png)

**在时间服务器上操作**

~~~powershell
# yum install xinetd  -y

# vim /etc/xinetd.d/time-stream
6       disable         = no				把yes改为no

# /etc/init.d/xinetd restart

# netstat -ntlup |grep :37
tcp        0      0 :::37         :::*         LISTEN      6801/xinetd 
~~~

**在客户端上写脚本同步**

**分析:**

- 不能使用crond来实现(因为crond最少时间间隔单位为1分钟)
- 每个30s同步一次时间，使用死循环，使用`sleep 30`实现等待30秒
- 同步失败记录日志
  - 在do.....done循环体之间加if...else...(判断同步失败还是成功)
- 同步成功100次发送邮件
  - 统计成功次数——>count=0——>成功1次加+1

~~~powershell
# yum install rdate -y

#!/bin/bash

count=0
while true
do
	rdate -s 10.1.1.12 &> /dev/null
	if [ $? -ne 0 ];then
		logger -t "rdate时间同步" "同步失败"
	else
		count=$[$count+1]							# 每成功一次计数加1
		if [ $count -eq 100 ];then
		 	logger -t "rdate时间同步" "同步成功"
			count=0									# 当累计100次记录成功日志后，清零计数
		fi
	fi	 
	sleep 30										# sleep等待30秒
done
~~~

## 3. until循环(了解)

**特点：**直到满足条件就退出循环

~~~powershell
until 条件				# 直到满足条件就退出循环
do
	command
	command
	......
done
~~~

比较for与until打印1-5

~~~powershell
a=1
until [ $a -gt 5 ]	  			for ((a=1;a<6;a++))
do								do
        echo $a						echo $a
        let a++					done
done
~~~

**建议:** **until循环结构看得懂就好。因为for与while就完全可以胜任所有的循环，并且后面学习python,python就只有for与while.**



# 二、随机数

bash默认有一个$RANDOM的变量, 默认范围是0~32767.

使用`set |grep RANDOM`查看上一次产生的随机数

~~~powershell
# echo $RANDOM
19862
# set |grep RANDOM
RANDOM=19862
~~~

产生0~1之间的随机数

~~~powershell
# echo $[$RANDOM%2]
~~~

产生0~2之间的随机数

~~~powershell
# echo $[$RANDOM%3]
~~~

产生1-2之内的随机数

~~~powershell
# echo $[$RANDOM%2+1]
~~~

产生50-100之内的随机数

~~~powershell
# echo $[$RANDOM%51+50]
~~~

产生三位数的随机数

~~~powershell
# echo $[$RANDOM%900+100]
~~~



**示例:** 写一个猜数字的小游戏

```powershell
#!/bin/bash

echo "猜一个1-100的整数,猜对砸蛋:" 

num=$[$RANDOM%100+1]

while true
do
	read -p "请猜:" gnum
    if [ $gnum -gt $num ];then
		echo "大了"
	elif [ $gnum -lt $num ];then
		echo "小了"
	else	
		echo "对了"
		break
	fi
done

echo "砸蛋"
```



# 三、嵌套循环

一个==循环体==内又包含另一个**完整**的循环结构，称为循环的嵌套。

在外部循环的每次执行过程中都会触发内部循环，直至内部完成一次循环，才接着执行下一次的外部循环。

for循环、while循环和until循环可以**相互**嵌套。

~~~powershell
for i in {a..c}
do
        for j in {1..3}
        do
                echo $i$j
        done
done

~~~



**示例:** 打印出如下结果

~~~powershell
*
**
***
****
*****
******
~~~

~~~powershell
回顾echo命令:
echo默认打印会换行
echo -n打印不换行
echo -e会让/n为换行号,\t为制表符(tab键)

# echo -e "你\n好\t吗"
你
好      吗
~~~



~~~powershell
#!/bin/bash

for i in $(seq 5)					# 循环5行
do
        for j in $(seq $i)			# 每行循环次数和行数保持一致
        do
                echo -n "*"
        done
        echo
done
~~~

**示例:**打印出如下结果

~~~powershell
1
12
123
1234
12345
~~~

~~~powershell
#!/bin/bash

for i in $(seq 5)
do
       	for j in $(seq $i)
        do
                echo -n $j
        done
        echo
done
~~~



# 课后作业

1, 将/etc/passwd里的用户名分类，分为管理员用户，系统用户，普通用户

~~~powershell
#!/bin/bash

rm -rf /tmp/root_user
rm -rf /tmp/system_user
rm -rf /tmp/normal_user

cat /etc/passwd |while read line
do
        user=$(echo $line |cut -d: -f1)
        uid=$(echo $line |cut -d: -f3)
        if [ $uid -eq 0 ];then
                echo "$user" >> /tmp/root_user
        elif [ $uid -ge 1 -a $uid -le 499 -o $uid -eq 65535 ];then
                echo "$user" >> /tmp/system_user
        else
                echo "$user" >> /tmp/normal_user
        fi
done

echo "管理员用户有:"
cat /tmp/root_user
echo
echo "系统用户有:"
cat /tmp/system_user
echo
echo "普通用户有:"
cat /tmp/normal_user

此例后面学习awk后会有更简单的方法
~~~

2, 写一个脚本把一个目录内的所有**空文件**都删除，最后输出删除的文件的个数

~~~powershell
方法一:
read -p "输入一个你要删除空文件的目录:" dir

a=0
for i in `find $dir -type f`
do
	[ ! -s $i ] && rm -rf $i && let a++
done

echo "删除的个数为:" "$a"	


方法二:
#!/bin/bash

read -p "输入一个你要删除空文件的目录:" dir

if [ ! -d $dir ];then
        echo "不存在或不是目录，重试"
        exit 0
fi

a=0
for i in `find $dir -size 0 -type f`
do
        rm -rf $i
        let a++
done
echo $a




~~~

3, 建立a1, a2, a3, a4, a5, b1, b2, b3, b4, b5。。。。。。。以此类推,一直到e1,e2, e3, e4, e5一共25个用户, 每个用户密码为随机三位数字(100-999), 并将用户名与密码保存到/root/.passwd文件中

~~~powershell

~~~









