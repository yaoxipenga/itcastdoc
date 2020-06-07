# **学习目标**

- [ ] 能够用input输入和print进行格式化输出
- [ ] 能辨认常见的算术,赋值,比较,逻辑,成员运算符
- [ ] 能写出python里判断语句的三种分支结构做简单的判断
- [ ] 能使用python里的while语句和for语句做简单的循环




# 六、输入输出(重点)

## 输入

还记得shell里的read吗？

用python3中可以使用input()函数等待用户的输入（python2中为raw_input()函数)

**示例**:

~~~python
name = input("what is your name: ")
age = input("what is your age: ")		# input输入的直接就为str类型，不需要再str()转换了

print(name, "你" + age + "岁了")
~~~

~~~powershell
name = input("请输入你的名字:")
age = int(input("请输入你的年龄:"))

print(name+",你5年后为"+str(age+5)+"岁了")
~~~

**小结:**  用单引号，双引号，三引号,  str()函数转换的和input()函数输入的都为字符串类型。



## 输出

### 普通输出

输出用print()

**示例**:

~~~python
print("="*10)				 # 表示连续打印10个=符号
print("1-系统")
print("2-数据库")
print("3-quit")
print("="*10)
或者
print("="*10)
print('''1-系统				# 使用'''  '''符号来换行
2-数据库
3-quit''')
print("="*10)
结果一样，如下:
~~~

![1541051758585](图片/1541051758585.png)





### 格式化输出（难点）

很多语言里使用printf来进行格式化打印

python里不用printf，但也可以用 % 表示格式化操作符

| 操作符 | 说明   |
| :----- | ------ |
| %s     | 字符串 |
| %d     | 整数   |
| %f     | 浮点数 |
| %%     | 输出 % |

**示例**:

~~~python
name = "daniel"
age = str(20)

# 字符串拼接的写法
print(name+",你有"+age+"岁了")

# 两种格式化输出的写法
print("%s,你有%s岁了" % (name, age))
print("{},你有{}岁了".format(name, age))
~~~

~~~powershell
name = input("请输入你的名字:")
age = int(input("请输入你的年龄:"))

print(name+",你5年后为"+str(age+5)+"岁了")
print("%s,你5年后为%d岁了" % (name, age+5))
print("{},你5年后为{}岁了".format(name, age+5))
~~~

**小结:** 

- %s或%d相当于是一个占位符，按顺序一一对应后面()里的变量(需要类型对应)
- {}也相当于是一个占位符，按顺序一一对应后面format()里的变量。这种写法的好处是不用对应类型
- 这三种写法为格式化输出, 简单来说就是为了解决`调用变量值和其它字符串结合场景`的方式。



## **综合练习**

请用前面所学过的知识,写python代码实现下面的结果（颜色可以不做要求:smiley:):

![1541054703297](图片/1541054703297.png)

**参考答案1:**

~~~powershell
name = input("输入你的名字:")
sex = input("输入你的性别:")
job = input("输入你的职业:")
num = input("输入你的手机号:")

print("-"*10+"information of "+name+"-"*10)
print("name: {}".format(name))
print("sex: {}".format(sex))
print("job: {}".format(job))
print("phonenum: {}".format(num))
~~~

**参考答案2:**

~~~powershell
name = input("输入你的名字:")
sex = input("输入你的性别:")
job = input("输入你的职业:")
num = input("输入你的手机号:")

print("-"*10+"information of "+name+"-"*10)
print('''name: {}
sex: {}
job: {}
phonenum: {}
'''.format(name, sex, job, num))
~~~

**参考答案3:**

~~~powershell
name = input("输入你的名字:")
sex = input("输入你的性别:")
job = input("输入你的职业:")
num = input("输入你的手机号:")

print("-"*10+"information of "+name+"-"*10)

print("name: {}\nsex: {}\njob: {}\nphonenum: {}".format(name, sex, job, num))
~~~

**参考答案4** :

~~~powershell
name = input("输入你的名字:")
sex = input("输入你的性别:")
job = input("输入你的职业:")
num = input("输入你的手机号码:")

print('''---------- information of {} -------------
name: {}
sex: {}
job: {}
num: {}'''.format(name, name, sex, job, num))
~~~





# 七、运算符

## 算术运算符(常用)

| 算术运算符 | 描述         | 实例                              |
| ---------- | ------------ | --------------------------------- |
| +          | 加法         | 1+2=3                             |
| -          | 减法         | 5-1=4                             |
| *          | 乘法         | 3*5=15                            |
| /          | 除法         | 10/2=5                            |
| //         | 整除         | 10//3=3  不能整除的只保留整数部分 |
| **         | 求幂         | 2**3=8                            |
| %          | 取余（取模） | 10%3=1  得到除法的余数            |



## 赋值运算符(常用)

| 赋值运算符 | 描述                                     | 实例                              |
| ---------- | ---------------------------------------- | --------------------------------- |
| =          | 简单的赋值运算符，下面的全部为复合运算符 | c =a + b 将a + b的运算结果赋值给c |
| +=         | 加法赋值运算符                           | a += b 等同于 a = a + b           |
| -=         | 减法赋值运算符                           | a -= b 等同于 a = a - b           |
| *=         | 乘法赋值运算符                           | a *= b 等同于 a = a * b           |
| /=         | 除法赋值运算符                           | a /= b 等同于 a = a / b           |
| //=        | 整除赋值运算符                           | a //= b 等同于 a = a // b         |
| **=        | 求幂赋值运算符                           | a ** = b 等同于 a = a ** b        |
| %=         | 取余（取模)赋值运算符                    | a %= b 等同于 a = a % b           |



## 比较运算符(常用)

| 比较运算符 | 描述                                            | 实例                     |
| ---------- | ----------------------------------------------- | ------------------------ |
| ==         | 等于（注意与=赋值运算符区分开),类似shell里的-eq | print(1==1)   返回True   |
| !=         | 不等于,类似shell里的-ne                         | print(2!=1)    返回True  |
| <>         | 不等于（同 != )                                 | print(2<>1)   返回True   |
| >          | 大于, 类似shell里的-gt                          | print(2>1)     返回True  |
| <          | 小于, 类似shell里的-lt                          | print(2<1)     返回False |
| >=         | 大于等于 类似shell里的-ge                       | print(2>=1)   返回True   |
| <=         | 小于等于 类似shell里的-le                       | print(2<=1)  返回False   |

```python
print(type(2<=1)) 		# 结果为bool类型，所以返回值要么为True,要么为False.
```



## 逻辑运算符(常用)

| 逻辑运算符 | 逻辑表达式 | 描述                                                         |
| ---------- | ---------- | ------------------------------------------------------------ |
| and        | x and y    | x与y都为True,则返回True;x与y任一个或两个都为False，则返回False |
| or         | x or y     | x与y任一个条件为True，则返回True                             |
| not        | not x      | x为True，返回False; x为False，返回True                       |



## 成员运算符(比较常用)

在后面讲解和使用序列(str,list,tuple) 时，还会用到以下的运算符。

| 成员运算符 | 描述                                                         |
| ---------- | ------------------------------------------------------------ |
| in         | x 在 y 序列中 , 如果 x 在 y 序列中返回 True; 反之，返回False |
| not in     | x 不在 y 序列中 , 如果 x 不在 y 序列中返回 True; 反之，返回False |

```powershell
在SQL语句里也有in和not in运算符;如(没有学习mysql的话，后面会学习了就知道了)
mysql > select * from xxx where name not in ('tom','john');
```



## 身份运算符(拓展)

| 身份运算符 | 描述                                        | 实例                                                         |
| ---------- | ------------------------------------------- | ------------------------------------------------------------ |
| is         | is 是判断两个标识符是不是引用自一个对象     | **x is y**, 类似 **id(x) == id(y)** , 如果是同一个对象则返回 True，否则返回 False |
| is not     | is not 是判断两个标识符是不是引用自不同对象 | **x is not y** ,类似 **id(a) != id(b)**。如果不是同一个对象则返回结果 True，否则返回 False。 |

**is 与 == 区别**：

is 用于判断两个变量引用对象是否为同一个(同一个内存空间)， == 用于判断引用变量的值是否相等。

```python
a = [1,2,3]			# 后面会学到，这是列表
b = a[:]			# 后面会学到，这是列表的切片
c = a
print(b is a)		# False
print(b == a)		# True

print(c is a)		# True
print(c == a)		# True
```



## 位运算符 (拓展)

大家还记得IP地址与子网掩码的二进制算法吗？

这里的python位运算符也是用于操作二进制的。

| 位运算符 | 说明                                             |
| -------- | ------------------------------------------------ |
| &        | 对应二进制位两个都为1，结果为1                   |
| \|       | 对应二进制位两个有一个1, 结果为1, 两个都为0才为0 |
| ^        | 对应二进制位两个不一样才为1,否则为0              |
| >>       | 去除二进制位最右边的位，正数上面补0, 负数上面补1 |
| <<       | 去除二进制位最左边的位，右边补0                  |
| ~        | 二进制位，原为1的变成0, 原为0变成1               |



## 运算符的优先级

常用的运算符中:  算术  >  比较  >  逻辑  > 赋值 

示例: 请问下面的结果是什么?

```python
result = 3 - 4 >= 0 and 4 * (6 - 2) > 15
print(result)

result = -1 >= 0 and 16 > 15     # 算术运算后
result = False and True			 # 比较运算后
result = False  				 # 逻辑运算后
```





# 八、判断语句(重点)

**生活中的判断**

![1541075593993](图片/1541075593993.png)



## shell里的判断语句格式

**shell单分支判断语句**:

```shell
if 条件;then
	执行动作一
fi
```

**shell双分支判断语句**:

```shell
if 条件;then
	执行动作一
else
	执行动作二
fi
```

**shell多分支判断语句**:

```shell
if 条件一;then
	执行动作一
elif 条件二;then
	执行动作二
elif 条件三;then
	执行动作三
else
	执行动作四
fi
```

shell里的case语句

```powershell
case "变量" in 
	值1 )
		  执行动作一
		  ;;
	值2 )
		 执行动作二
		  ;;
	值3 )
		 执行动作三
		  ;;
	* )
		 执行动作四
esac
```

------

## python里的判断语句格式

**python单分支判断语句**:

```python
if 条件:					# 条件结束要加:号(不是;号)
	执行动作一			  # 这里一定要缩进（tab键或四个空格)，否则报错
    					 # 没有fi结束符了，就是看缩进
```

**python双分支判断语句**:

```python
if 条件:
	执行动作一			
else:					# else后面也要加:
	执行动作二
```

**python多分支判断语句**:

```python
if 条件一:
	执行动作一
elif 条件二:			  # elif 条件后面都要记得加:
	执行动作二
elif 条件三:
	执行动作三
else:
	执行动作四
```

shell里有个case语句, 也可以实现多分支判断。但是**python里没有case语句**.

------

## 实例

**示例: 基本格式练习**

```powershell
# 单分支判断
if True:
    print("真")				# 前面一定要缩进(tab键或4个空格)

# 双分支判断
if True:
    print("真")				# 前面一定要缩进(tab键或4个空格)
else:
    print("假")				# 前面一定要缩进(tab键或4个空格)

# 多分支判断
num = 34
gnum = int(input("你猜:"))
if gnum > num:
    print("大了")				# 前面一定要缩进(tab键或4个空格)
elif gnum < num:
    print("小了")				# 前面一定要缩进(tab键或4个空格)
else:
    print("对了")				# 前面一定要缩进(tab键或4个空格)
```

**示例:看看下面语句有什么错误**:

```python
if 1 > 0:
    print("yes")
else:
    print("no")
print("haha")
    print("hehe")
```

**示例:通过年龄是否成年与性别来判断对一个人的称呼**

男的大于等于18  叫  sir

男的小于18  叫boy

女的大于等于18 叫lady

女的小于18  叫girl

```python
name = input("输入你的名字:")
sex = input("输入你的性别:")
age = int(input("输入你的年龄:"))

if sex == "男" and age >= 18:
    print("{},sir".format(name))
elif sex == "男" and age < 18:
    print("{},boy".format(name))
elif sex == "女" and age >= 18:
    print("{},lady".format(name))
elif sex == "女" and age < 18:
    print("{},girl".format(name))
else:
    print("错误")
```



**练习**: input输入一个年份,判断是否为闰年(能被4整除但不能被100整除的是闰年，或者能被400整除的也是闰年) 

```python
year = int(input("输入一个年份:"))

if year % 4 == 0 and year % 100 != 0:
    print("{}是闰年".format(year))
elif year % 400 == 0:
    print("{}是闰年".format(year))
else:
    print("{}是平年".format(year))
```



(拓展)

运维中常见的判断场景:

* 判断文件的类型
* 判断文件是否存在
* 判断软件包是否已经安装
* 判断磁盘空间是否足够
* 判断服务是否OK
* 等等

~~~python
import os

if os.path.exists("D:/python_project_day1/1.py"):
    print("存在")
else:
    print("不存在")
~~~



## if嵌套

**if嵌套**也就是if里还有if，你可以无限嵌套下去，但层次不宜过多（嵌套层次过多的话程序逻辑很难读，也说明你的程序思路不太好，应该有很好的流程思路来实现）

比如下面的格式:

```python
if 条件一:
    if 条件二:
		执行动作一		# 条件一，二都为True，则执行动作一
    else:
        执行动作二		# 条件一True，条件二False，则执行动作二
    执行动作三			# 条件一True，条件二无所谓，则执行动作三
else:
    if 条件三:
        执行动作四		# 条件一False，条件三True，则执行动作四
    else:
        执行动作五		# 条件一False,条件三False,则执行动作五
	执行动作六			# 条件一False,条件二，三无所谓，则执行动作六
执行动作七				# 与if里的条件无关，执行动作七
```

**示例:**

```python
name = input("输入你的名字:")
sex = input("输入你的性别:")
age = int(input("输入你的年龄:"))

if sex == "男":
    if age >= 18:
        print("{},sir".format(name))
    else:
        print("{},boy".format(name))
elif sex == "女":
    if age >= 18:
        print("{},lady".format(name))
    else:
        print("{},girl".format(name))
else:
    print("性别有误")
```



**拓展:  如果输入的年龄不为纯数字,怎么判断**

shell里判断age变量的值是否为纯数字的做法

~~~powershell
echo $age |grep -E ^[0-9]+$

if [ $? -eq 0 ];then
	echo "纯数字"
else
	echo "不是纯数字"
fi
~~~

python中判断是否为纯数字

~~~powershell
name = input("输入你的名字:")
sex = input("输入你的性别:")
age = input("输入你的年龄:")


if not age.isdigit():					# 判断是否纯数字
    print("输入的年龄不是数字")
    exit()								# 类似shell里的exit,退出整个程序
else:
    age = int(age)
    
if sex == "男":
    if age >= 18:
        print("{},sir".format(name))
    else:
        print("{},boy".format(name))
elif sex == "女":
    if age >= 18:
        print("{},lady".format(name))
    else:
        print("{},girl".format(name))
else:
    print("性别有误")
~~~







# 九、循环语句(重点)

**生活中的循环**

![1541074178192](图片/1541074178192.png)



![1541074846394](图片/1541074846394.png)

**软件开发中循环**

```
新手村村长:print("啊，今天天气真好啊")
新手村村长:print("啊，今天天气真好啊")
新手村村长:print("啊，今天天气真好啊")
......
新手村村长:print("看在你陪我说话100次的份上，小伙子不错，给你一把屠龙刀吧!")
```

一般情况下，需要多次重复执行的代码，都可以用循环的方式来完成



## while循环

**只要满足while指定的条件，就循环**。

### while 循环的基本格式

~~~python
while 条件:
      条件满足时候:执行动作一
	  条件满足时候:执行动作二
      ......
~~~

**注意:** 没有像shell里的do..done来界定**循环体**，所以要看缩进。



**示例: 打印1-10**

 ~~~python
i = 1
while i < 11:
    print(i, end=" ")
    i += 1
 ~~~

**示例:打印1-100的奇数**

~~~powershell
i = 1
while i < 101:
    if i % 2 == 1:
        print(i, end=" ")
    i += 1
~~~



### 跳出循环语句

~~~powershell
continue		跳出本次循环，直接执行下一次循环    
break			退出循环，执行循环体外的代码　
exit()			退出python程序，可以指定返回值
~~~

**示例: 猜数字小游戏**

~~~python
import random				# 导入随机数模块(后面会专门讲模块的使用，这里先拿来用用)

num = random.randint(1, 100)	# 取1-100的随机数（包括1和100)

while True:
    gnum = int(input("你猜:"))
    if gnum > num:
        print("猜大了")
    elif gnum < num:
        print("猜小了")
    else:
        print("猜对了")
        break
        
print("领奖")
~~~

**练习: 用while循环实现1-100中的所有偶数之和**

~~~powershell
i = 2
sum = 0

# 方法一
while i <= 100:
    sum += i
    i += 2
print(sum)

# 方法二
while i <= 100:
    if i % 2 == 0:
        sum += i
    i += 1
print(sum)

# 方法三(了解)
while i <= 100:
    if i % 2 == 1:
        i += 1
        continue
    else:
        sum += i
        i += 1
print(sum)
~~~



## for循环

**for循环遍历一个对象（比如数据序列，字符串，列表，元组等）,根据遍历的个数来确定循环次数。**

for循环可以看作为**定循环**，while循环可以看作为**不定循环**。 

如:  

6点-18点，每个小时整点循环（定了次数，每天都会有6点-18点） 

当有太阳，每个小时整点循环（不定次数，天气和季节都会影响是否有太阳）

### for循环的基本格式

~~~python
for 变量  in  数据:
    重复执行的代码
~~~

**示例:**

~~~python
for i in 1, 2, 3, 4, 5:
    print(i, end=" ")
print()

for i in range(1, 6):		# range()函数，这里是表示1，2，3，4，5（不包括6）
    print(i)
    
for i in range(6):			# range()函数，这里是表示0，1，2，3，4，5（不包括6，默认从0开始）
    print(i)    

for i in range(1, 100, 2):	# 循环1-100的奇数
    print(i, end=" ")
print()

for i in range(100, 1, -2):
    print(i, end=" ")
~~~



**练习**: **用for循环来实现1-100之间能被5整除,同时为奇数的和**

~~~powershell
sum = 0
for i in range(1, 101):
    if i % 5 == 0 and i % 2 == 1:
        sum += i
print(sum)
~~~

~~~powershell
sum = 0

for i in range(1, 101, 2):
    if i % 5 == 0:
        sum += i

print(sum)
~~~



## **循环嵌套(了解)**

前面在讲if时解释过嵌套是什么，这里我们再来做一个总结: **if,while,for都可以互相嵌套**。



**示例: 打印九九乘法表**

~~~powershell
1*1=1  					
1*2=2 2*2=4  
1*3=3 2*3=6 3*3=9 
1*4=4 2*4=8 3*4=12 4*4=16 
1*5=5 2*5=10 3*5=15 4*5=20 5*5=25 
1*6=6 2*6=12 3*6=18 4*6=24 5*6=30 6*6=36 
1*7=7 2*7=14 3*7=21 4*7=28 5*7=35 6*7=42 7*7=49 
1*8=8 2*8=16 3*8=24 4*8=32 5*8=40 6*8=48 7*8=56 8*8=64 
1*9=9 2*9=18 3*9=27 4*9=36 5*9=45 6*9=54 7*9=63 8*9=72 9*9=81 
~~~

思路: 先简单化成下面的图形

~~~powershell
* 
* * 
* * * 
* * * * 
* * * * * 
* * * * * * 
* * * * * * * 
* * * * * * * * 
* * * * * * * * * 
~~~

再简单化成下面的图形

~~~powershell
* 
* *
* * * 
~~~

打印1:

~~~powershell
for line in range(1, 4):
    for field in range(1, 4):
        print("*", end=" ")
    print()
    
* * * 
* * * 
* * * 
~~~

打印2:

~~~powershell
for line in range(1, 4):
    for field in range(1, line+1):
        print("*", end=" ")
    print()
    
* 
* * 
* * * 
~~~

打印3:

~~~powershell
for line in range(1, 10):
    for field in range(1, line+1):
        print("*", end=" ")
    print()
* 
* * 
* * * 
* * * * 
* * * * * 
* * * * * * 
* * * * * * * 
* * * * * * * * 
* * * * * * * * * 
~~~

打印4:

~~~powershell
for line in range(1, 10):
    for field in range(1, line+1):
        print("{}*{}={}".format(field, line, field*line), end="\t")
    print()
~~~

~~~powershell
1*1=1	
1*2=2	2*2=4	
1*3=3	2*3=6	3*3=9	
1*4=4	2*4=8	3*4=12	4*4=16	
1*5=5	2*5=10	3*5=15	4*5=20	5*5=25	
1*6=6	2*6=12	3*6=18	4*6=24	5*6=30	6*6=36	
1*7=7	2*7=14	3*7=21	4*7=28	5*7=35	6*7=42	7*7=49	
1*8=8	2*8=16	3*8=24	4*8=32	5*8=40	6*8=48	7*8=56	8*8=64	
1*9=9	2*9=18	3*9=27	4*9=36	5*9=45	6*9=54	7*9=63	8*9=72	9*9=81	
~~~



**扩展语法:**

for也可以结合else使用，如下面判断质数(**只能被1和自己整除的数**)的例子

~~~python
num = int(input("输入一个大于2的整数"))

for i in range(2, num):
    if num % i == 0:
        print("不是质数")
        break
else:						# 这里的else是与for在同一列上,不与if在同一列。
   	print("是质数")
~~~



# 课后练习

**示例:使用getpass模块使用密码隐藏输入(拓展)**

隐藏输入密码(类似shell里的read -s )，但**在pycharm执行会有小bug,会卡住** (卡住后，用ps -ef |grep pycharm，然后kill -9 杀掉所有pycharm相关进程)；在bash下用python命令执行就没问题

~~~python
import getpass					# 这是一个用于隐藏密码输入的模块
			
username = input("username:")
password = getpass.getpass("password:")

if username == "daniel" and password == "123":
    print("login success")		
else:
    print("login failed")
~~~

bash下执行方法

~~~powershell
# /usr/local/bin/python3.6 /项目路径/xxx.py
~~~



**练习: 一个袋子里有3个红球，3个绿球，6个黄球，一次从袋子里取6个球，列出所有可能组合**

~~~python

~~~

**练习: 改写猜数字游戏，最多只能猜5次，5次到了没猜对就退出**

~~~python

~~~

**练习: 打印1-1000的质数（只能被1和自己整除的数)**

~~~powershell

~~~

**练习:(有难度，想挑战的可以尝试)**

 **使用input输入一个字符串，判断是否为强密码:  长度至少8位,包含大写字母,小写字母,数字和下划线这四类字符则为强密码**

~~~python
提示:因为没有学python的正则，你可以使用这样来判断  if 字符 in "abcdefghijklmnopqrstuvwxyz":

答:
~~~