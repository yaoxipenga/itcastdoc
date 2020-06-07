**学习目标:**

- [ ] 掌握函数自定义格式
- [ ] 掌握函数调用方法
- [ ] 掌握函数的传参
- [ ] 能够说出函数返回值的作用
- [ ] 理解函数的变量作用域
- [ ] 能够说出python模块的定义
- [ ] 能够说出python分为哪三类模块
- [ ] 能够查找python的模块存放路径
- [ ] 掌握python模块的导入方法
- [ ] 掌握os模块的基本使用




# 十六、函数

使用函数的优点: **功能模块化,代码重用**(编写的代码可以重复调用)

## 回顾下shell里的函数

~~~powershell
# service sshd start
# /etc/init.d/sshd start
在centos6里，上面两条命令里的start都是最终调用/etc/init.d/sshd服务脚本里的start()函数
~~~

~~~shell
function start() {						# 定义函数名start，前面可以加function也可以不加
	/usr/sbin/sshd
}

stop() {
	kill -15 `cat /var/run/sshd/sshd.pid`
}

reload() {
	kill -1 `cat /var/run/sshd/sshd.pid`
}

restart() {
    stop
    start									# 函数里调函数就是函数的嵌套	
}

case "$1" in
	start )
		start								# 调用start函数
		;;
	stop )
		stop
		;;
	restart )
		restart
		;;
	reload )
		reload
		;;
	* )
		echo "参数错误"
esac
~~~

## python里的函数

python里函数分为**内置函数**与**自定义函数**

**内置函数**: 如int(), str(), len(), range(), id(), max(), print(),type()等,所有的内置函数参考

https://docs.python.org/3/library/functions.html



### **自定义函数的定义与调用(重点)**

~~~python
def funct1():				  # 函数名(),括号里面可以写参数，也可以不写
    """函数说明或注释"""		  # 说明或注释可以不写，大型程序为了程序可读性最好写
    print("进水")				 # 函数代码主体
    print("洗衣服")		    # 函数代码主体
    print("脱水")				 # 函数代码主体
    return 0				  # 函数返回值,可有可无

funct1()				 	# 调用函数的方式(调用函数也就是执行函数内部的代码)
~~~



### 函数传参数(重点)

> 为什么要传参?
>
> 答: 把自动洗衣机比喻成生活中的函数，我们不同的使用者也要告诉洗衣机加多少水,放什么衣服,洗衣的模式,脱水多久等，这些都可以看作是给洗衣机传参。
>
> 同样,给空调调模式和温度，给电视调频道与音量都可以看作是传参。

~~~powershell
def test(a, b, c):                		# 定义函数，传3个参数，分别为a,b,c
    print("进水{}升".format(a))			# 调用a的值
    print("洗{}".format(b))				 # 调用b的值	
    print("脱水{}分钟".format(c))          # 调用c的值

test(3, "毛衣", 10)                   # 将值3赋值给a变量,值"毛衣"赋值给b变量,值10赋值给c变量
~~~



**示例: 形参,实参,位置参数,关键字参数**

~~~python
def test(a, b):		# a,b是形参(形式上的参数,就是占位置用的)
    print(a + b)

    
test(1, 2)			# 1,2在这里是实参(实际的参数),实参也可以传变量,个数要与形参个数对应,也会按顺序来传参（位置参数);
# test(1)			# 执行的话会报错,位置参数要与形参一一对应,个数不能少
# test(1, 2, 3)		# 执行的话会报错,位置参数要与形参一一对应,个数也不能多
test(b=4, a=3)		# 这里是关键字调用,那么就与顺序无关了(关键字参数)

# test(5, b=6)		# 混用的话，就比较怪了，结果可以自行测试一下(结论:位置参数必须写在关键字参数的前面)
~~~

**示例: 默认参数或者叫默认值参数再或者叫缺省参数**

~~~python
def connect_ssh(host, user, password, port=22):		# port=22为默认参数
    pass							     # pass就类似一个占位符，保证函数完整，没有语法错误


host = input("input host:")
user = input("input user:")
password = input("password")

connect_mysql(host, user, password，33)	 # 不用再传port的值的,默认就是22;也可以传一个新的值替代22
~~~

**示例:**

~~~powershell
def ssh(ip, port=22):
    print("ssh {} -p {}".format(ip, port))

ssh("10.1.1.15", 2222)
~~~



~~~powershell
def ssh_connect(host, user="root", port=22 ):
    print("ssh {} -l {} -p {}".format(host, user, port))


for i in range(11, 16):
    if i == 15:
        ssh_connect("10.1.1.{}".format(i), "aaa", 2222)
    else:
        ssh_connect("10.1.1.{}".format(i))
~~~

**一句话小结:** 默认值参数就是不传值就用默认的，传了值就用传的值。

**示例:可变长参数**

~~~python
def funct1(*args):		# 参数名前面加*(变量名可以自定义)就可以定义为可变长参数
    for i in args:
        print(i, end=" ")
    print()

    
funct1(1, 2, 3, 4, 5, 6, 7, 8)
~~~

~~~python
定义一个函数，传多个整数，实现求和
def add_num(*args):
    sum = 0
    for i in args:
        if isinstance(i, int):		# 判断是整数类型才求和，或者使用if type(i) == int:
            sum += i
    print(sum)

add_num(1, 4, 3, "a")
~~~



**小结:**

**为什么要传参?**

~~~powershell
每次调用函数可能会有不同的需求,传参就相当于是和函数做交互，传不同的值给函数来实现不同的需求
~~~

**形参,实参**

**位置参数**:  实参与形参按顺序一一对应

**关键字参数:**  在实参里也要写上形参的名字，这样做可以改变顺序

**默认值参数:** 大部分情况下值不变, 极少数值不一样的情况下可以使用默认值参数。

​                     默认值参数就是不传值就用默认的，传了值就用传的值

**可变长参数:**  参数个数不确定的情况就用可变长参数



**示例: 多个关键字参数转字典(拓展)**

~~~python
def test(**kwargs):			# **两个后面加变量(变量名可以自定义)，这样后面传多个值(需要传关键字参数)，并且结果为字典
    print(kwargs)

test(name="zhangsan", age=18, gender="M")

def people(name, *args, age=18, **kwargs):
    print(name)
    print(args)
    print(age)
    print(kwargs)
    
people("zhangsan", "man", 25, salary=20000, department="IT")
people("zhangsan", "man", 180, age=25, salary=20000, department="IT")
people("zhangsan", "man", 180, 25, salary=20000, department="IT")
~~~





### 函数返回值(重点)

**函数的功能要专一, 一个函数只完成一个功能。**

**理解函数返回值的作用:** **==把函数的执行结果返回给需要调用的地方==**。

**函数return返回的是一个==值==，所以要赋值给一个变量,然后通过调用变量得到返回值。**

**函数返回值写在函数体的最后，因为函数返回值意味着函数的结束。**

**不用return指定函数返回值，则返回值默认为None**

**示例:**

~~~python
def test(a, b):
    c = a + b
    return c
	print("haha")	# 返回值后面的代码不执行,也就是说函数执行到return就结束了

test(1, 2)		# 再回顾一下，这是函数的调用，执行函数体内的代码，但这样得不到函数返回值

d = test(1, 2)
print(d)			# 这样终于得到函数的返回值了

print(test(1,2))	# 不赋值给变量，直接打印也是可以得到函数的返回值
~~~



比较下面两段(目前看不出来返回值的优势)

~~~powershell
def test1(a, b):
    print(a + b)

def test2(a ,b):
    c = a + b
    return c

test1(1, 2)

print(test2(2, 3))
~~~

**实例说明返回值的应用**

~~~powershell
def add_num(*args):
    sum = 0
    for i in args:

        if type(i) == int:
            sum += i
#   print(sum)			# 函数体内打印的结果,只能在调用函数时执行一次，不能被其它地方调用
    return sum			# 将print(sum)换成return sum就能将结果给其它地方调用了

add_num_sum = add_num(1, 4, 3, "a")	# 返回值赋值给一个变量,那么这个变量可以被其它多个地方调用了

if  add_num_sum > 5:		# 这里使用了add_num_sum变量，其实也就是调用了add_num函数的返回值
    print("好大啊")
else:
    print("好小啊") 
~~~



**小结:** 

**函数的结果要被其它地方调用,就不要在函数里用print打印,而是用return做成返回值, 再把这个返回值赋值给一个变量，让调用者使用这个变量就是在使用这个函数的结果。**






### 嵌套函数

还记得前面的if,while,for嵌套吗？再总结一下: if,while,for,函数都可以嵌套，也可以互相嵌套。

请问: 下面的两段代码结果是否一样?

~~~python
def aaa():
    print("aaa")
def bbb():
    print("bbb")
    aaa()
bbb()


def bbb():
    print("bbb")
    aaa()
def aaa():
    print("aaa")
bbb()
~~~

请问: 下面的代码有没有问题

~~~python
def bbb():
    print("bbb")
    aaa()
bbb()
def aaa():
    print("aaa")  
~~~

**小结:** 

* ==函数要先定义, 才能调用==
* ==函数类似一个变量, 定义函数就是把函数体内的代码在内存开辟一个空间存放进去,然后可以通过函数名来调用==
* ==调用函数其实就是执行函数体内的代码==



请问:下面的代码能看明白吗? 并想想return能不能换成print直接打印?

~~~python
def max_num2(a, b):
    if a > b:
        return a
    else:
        return b
    
def max_num3(n1, n2, n3):
    aaa = max_num2(n1, n2)
    bbb = max_num2(aaa, n3)
    return bbb

print(max_num3(1, 2, 3))
~~~




### 函数的变量作用域: 全局变量，局部变量

**示例:**

~~~python
name = "zhangsan"   	# 全局变量

def change_name():
    name = "lisi"	# 这个变量只能在函数内生效，也就是局部变量(可以说这个函数就是这个变量的作用域)
    gender = "male"

    
change_name()		
print(name)			# 结果为zhangsan
print(gender)		# 这句会报错，因为它是局部变量，在外面调用不了
~~~

**示例:**

~~~python
name = "zhangsan"   	# 全局变量

def change_name():
    global name,gender     # 这句可以把name改为全局变量，但不建议这样用，如果多次调用函数，这样很容易混乱，容易与外部的变量冲突
    name = "lisi"
    gender = "male"
    print(name)

    
change_name()		# 这句结果为lisi，调用函数内部的print(name)得到的结果
print(name)			# 这句结果为lisi
print(gender)		# 可以调用gender变量了，能打印出结果
~~~



### 递归函数(拓展)

函数可以调用其它函数，也可以调用自己；如果**一个函数自己调用自己，就是递归函数**,但递归也有次数上限（保护机制），所以递归需要有一个结束条件

在计算机中，函数调用是通过栈（stack）这种数据结构实现的，每当进入一个函数调用，栈就会加一层栈帧，每当函数返回，栈就会减一层栈帧。由于栈的大小不是无限的，所以，递归调用的次数过多，会导致栈溢出

**示例: 下面代码就可以看到最高可以递归近1000次**

~~~python
def aaa():
    print("aaa")
    aaa()

aaa()
~~~

**示例:**

~~~python
def abc(n):
    print(n)
    if n//2 > 0:
       abc(n//2)
    
abc(100)
~~~

### 匿名函数(拓展)

python 使用 lambda 来创建匿名函数。

所谓匿名，意即不再使用 def 语句这样标准的形式定义一个函数。

	lambda 只是一个表达式，函数体比 def 简单很多。
	
	lambda的主体是一个表达式，而不是一个代码块。仅仅能在lambda表达式中封装有限的逻辑进去。
	
	lambda 函数拥有自己的命名空间，且不能访问自有参数列表之外或全局命名空间里的参数。

**示例: 比较下面的两段**

~~~python
# 自定义函数
def caclulate(a, b):
	print(a + b)

    
caclulate(2, 5)

# 匿名函数
caclulate = lambda a,b:a+b

print(caclulate(2, 5))
~~~



### 列表推导式(拓展)

匿名函数常用于写有行为的列表或字典,按照要求执行相应的动作

**示例:把一个列表的值x2**

~~~python
# 方法一:
list1=[1,2,3,4,5]

list2=[]
for i in list1:
    i*=2
    list2.append(i)

print(list2)

# 方法二:
list1=[1,2,3,4,5]

for i,j in enumerate(list1):
    j=j*2
    list1[i]=j

print(list1)

# 方法三:列表推导式
list1=[i*2 for i in range(1,6)]
print(list1)

list2=list(map(lambda i:i+1,list1))
print(list2)
~~~



### 高阶函数(拓展)

高阶函数特点:

* 把函数名当做实参传给另外一个函数(变量可以传参，函数就是变量，所以函数也可以传参)
* 返回值中包含函数名

**示例：普通的函数，里面会用到abs这种内置函数来做运算**

```python
def higher_funct1(a,b):
        print(abs(a)+abs(b))

higher_funct1(-3,-5)
```

**示例: 高阶函数，像abs(),len(),sum()这些函数都当做了实参传给了另外一个函数**

~~~python
def higher_funct1(a,b,c):
        print(c(a)+c(b))

higher_funct1(-3,-5,abs)
higher_funct1("hello","world",len)
higher_funct1([1,2,3],[4,5,6],sum)

def higher_funct1(a,b,c):
		return c(a)+c(b)

print(higher_funct1(-3,-5,abs))
print(higher_funct1("hello","world",len))
print(higher_funct1([1,2,3],[4,5,6],sum))
~~~



### 装饰器(拓展)

装饰器(语法糖) 用于装饰其他函数（相当于是为其他函数提供附加功能)

不能去修改被装饰的函数的源代码和调用方式（如果业务已经线上运行，现在想新加一个功能，改源代码就会产生影响）

**示例:**

假设我的程序假设有三个复杂函数逻辑

~~~python
import time

def complex_funct1():
    time.sleep(2)
    print("哈哈，我不复杂!")

def complex_funct2():
    time.sleep(3)
    print("哈哈，我也不复杂!")

def complex_funct3():
    time.sleep(4)
    print("哈哈，我还是不复杂!")

complex_funct1()
complex_funct2()
complex_funct3()
~~~

假设我现在想加一个计算复杂函数时间的功能，下面的做法太麻烦，一个个的加，并且还修改了原函数的代码

```python
import time

def complex_funct1():
    start_time=time.time()
    time.sleep(2)
    print("哈哈，我不复杂!")
    end_time=time.time()
    print("此函数一共费时{}".format(end_time-start_time))

def complex_funct2():
    start_time=time.time()
    time.sleep(3)
    print("哈哈，我也不复杂!")
    end_time=time.time()
    print("此函数一共费时{}".format(end_time-start_time))

def complex_funct3():
    start_time = time.time()
    time.sleep(4)
    print("哈哈，我还是不复杂!")
    end_time=time.time()
    print("此函数一共费时{}".format(end_time-start_time))

complex_funct1()
complex_funct2()
complex_funct3()
```

我这里把计算时间的功能定义成一个函数，把被计算的复杂函数当做参数传进来进行计算（高阶函数），但后面的函数调用方式却需要改变

~~~python
import time

def timer(funct):
    start_time=time.time()
    funct()				# 这里funct后面不接()也可以，但下面的调用里就要写，比如timer(complex_funct1())
    end_time=time.time()
    print("此函数一共费时{}".format(end_time - start_time))

def complex_funct1():
    time.sleep(2)
    print("哈哈，我不复杂!")

def complex_funct2():
    time.sleep(3)
    print("哈哈，我也不复杂!")

def complex_funct3():
    time.sleep(4)
    print("哈哈，我还是不复杂!")
timer(complex_funct1)
timer(complex_funct2)
timer(complex_funct3)			# 这里改变了原有的调用方式
~~~

高阶函数+嵌套函数=装饰器，实现不修改原函数代码，也不改变原函数调用方式，就可以加上新功能

~~~python
def timer(funct):			# 把下面的多个复杂函数当做参数传给这个timer计时函数（高阶函数）
    def timer_proc():			# 函数里调函数（嵌套函数）
        start_time=time.time()
        funct()				# 执行调用的复杂函数(如complex_funct1()等)，函数的过程会消耗一定的时间
        end_time=time.time()
        print("此函数一共费时{}".format(end_time - start_time))	# 算出时间，也就是我们最终需要的结果，但写在里面这样并不能打印出来，需要在外函数作为返回值
    return timer_proc			# 把嵌套内部函数的值在外面作为返回值，这样就可以被显示

@timer							# 相当于timer(complex_funct1)
def complex_funct1():
    time.sleep(2)
    print("哈哈，我不复杂!")

@timer							# 相当于timer(complex_funct2)
def complex_funct2():
    time.sleep(3)
    print("哈哈，我也不复杂!")

@timer							# 相当于timer(complex_funct3)
def complex_funct3():
    time.sleep(4)
    print("哈哈，我还是不复杂!")


complex_funct1()
complex_funct2()
complex_funct3()			# 没有改变最原始的函数调用方式就能实现需求
~~~





# 课后示例与练习

**练习: 自定义一个函数, 实现文件字符串的查找功能(如:输入"/etc/passwd",再输入"abc",就是在/etc/passwd文件里查找所有以abc开头的行,并打印出来.还要求前面打印行号，后面打印行的字符串长度)**

~~~python

~~~

**练习:**  **本机(管理机)准备一个文件,记录你所管理的所有机器的IP与端口,如下面这种**

~~~powershell
# cat /tmp/1.txt
10.1.1.11:22
10.1.1.12:3333
10.1.1.13:22
10.1.1.14:2222
10.1.1.15:22
~~~

**要求: 写一个模块(包含2个函数),1个函数如下,另一个函数要求读取`/tmp/1.txt`文件的内容并传参给第1个函数**

~~~powershell
def ssh(ip, port=22):
    print("ssh {} -p {}".format(ip, port))
~~~

**写好上述模块后, 再写一个文件来调用上面的模块, 请写出调用的写法**

~~~powershell

~~~



**示例: 递归查找指定目录的空文件**

~~~powershell
shell里一条find命令搞定
find $dir -size 0 -exec rm -rf {} \;
~~~

~~~python
# python需要用到函数递归(也就是函数里再调用自己的嵌套函数);对于新手来说非常难理解，先学会看懂就好
import os

dir = input("input a directory: ")

def find_empty_file(dirname):
    file = os.listdir(dirname)
    for basename in file:
        absname = os.path.join(dirname, basename)
        if os.path.getsize(absname) == 0:
            os.remove(absname)
            print("{} is a empty file, delete it".format(absname))
        elif os.path.isdir(absname):
            find_empty_file(absname)


find_empty_file(dir)
~~~

**练习: 递归查找指定目录的死链接**(**是链接文件但同时不存在的就是死链接文件**)，按上例替代一下条件即可

~~~python

~~~

**练习: 递归查找指定目录的特定类型文件（如.avi,.mp4)**，按上例替代一下条件即可

~~~python

~~~

