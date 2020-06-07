# **学习目标**

- [ ] 能够说出面向对象的三大特性

- [ ] 了解类与对象的概念

- [ ] 能够创建类

- [ ] 能够通过类实例化对象

- [ ] 能够给类加上属性

- [ ] 能够给类加上方法

- [ ] 能够区分类变量与实例变量

- [ ] 了解继承的用法




# 十九、面向对象编程

## 面向**过程**编程思想与面向**对象**编程思想

事例：一个宿舍的电脑菜鸟要配新电脑

第一种方式: (宿舍里每个人都大概要走下面几步）

> 1, 查找电脑相关资料和学习相关知识
>
> 2, 根据预算和所学知识定好了要配置的电脑各硬件
>
> 3, 带着钱去电脑城选购
>
> 4, 导购推荐你这样，那样，超出预算了
>
> 5, 咬牙买了，成交

第二种方式: 

> 1, 大家找了一位靠谱的老师（电脑高手）
>
> 2, 给钱这位老师,老师根据不同人的预算配置合适的电脑

第一种方式强调的是**==过程==**，每个人都一步一步地参与了自己的买电脑的步骤。（面向过程的思想）

第二种方式强调的是电脑高手这个**==对象==**, 步骤不用亲自一步一步做，由对象来搞定。（面向对象的思想）



**封装**

**函数 -》 类(面向对象) -》 模块**





我为什么在上事例中要强调是一个宿舍的人，而不是一个人？因为如果用程序来实现的话，一个人一步一步的好写，很多人就难了（不是循环，因为每人的动作不是完全一样的）。

---

事例:

两个人一天干以下几件事：

1. 张三:  起床---吃饭---工作---吃饭---工作---吃饭---工作---回家---睡觉
2. 李四:  起床---吃饭---学习---吃饭---学习---回家---玩耍---睡觉

再如: 使用函数来代码复用

~~~python
def get_up(name):
    print("{}起床".format(name))
    
def eat(name):
    print("{}吃饭".format(name))

def go_to_work(name):
    print("{}工作中".format(name))
   
def go_to_school(name):
    print("{}学习中".format(name))
    
def go_to_play(name):
    print("{}玩耍中".format(name))

def go_home(name):
    print("{}回家".format(name))
    
def go_to_bed(name):
    print("{}睡觉".format(name))
    

get_up("zhangsan")
eat("zhangsan")
go_to_work("zhangsan")
eat("zhangsan")
go_to_work("zhangsan")
eat("zhangsan")
go_to_work("zhangsan")
go_home("zhangsan")
go_to_bed("zhangsan")

get_up("lisi")
eat("lisi")
go_to_school("lisi")
eat("lisi")
go_to_school("lisi")
go_home("lisi")
go_to_play("lisi")
go_to_bed("lisi")


# 如果吃，上班，去玩的动作再多一些，人除了张三,李四,王五外也再多一些，这样写还是感觉代码不够精简。
~~~

面向对象三大特性: 

1. **==封装==**   
2. **==继承==**
3. **==多态==**





## 类与对象

**==类==**与**==对象==**是面向对象两个非常重要的概念。

**类是总结事物特征的抽象概念,是创建对象的模板。对象是按照类来具体化的实物。**

![1541337437065](图片/类与对象1.png)

![1541337644677](图片/类与对象2.png)



### 类的构成

**类的名称**: 类名

**类的属性**: 一组参数数据

**类的方法**: 操作的方式或行为



如: 为人设计一个类:

名称 : people

属性: name,sex,age,weight,height等

方法: eat,drink,walk,run等



为王者荣耀里的英雄设计一个类:

名称: hero

属性: HP,MP,attack,armor,speed等

方法: 普攻,暴击, Q技能, W技能,E技能,R技能等



为笔记本设计一个类:

名称: laptop

属性: cpu,mem,disk,屏幕大小,显卡等

方法: 开机，关机等



### 类的创建

~~~python
# class People(object): 新式类    class People(): 经典类

class People(object): 	 # 类名python建议使用大驼峰命名(每一个单词的首字母都采用大写字母);				   
	pass
~~~



### 创建对象（类的实例化)

~~~python
class People(object):
    pass


p1 = People()  		# 创建第一个对象p1，这个过程也叫类的实例化
p2 = People()		# 创建第二个对象p2，这个过程也叫类的实例化

print(p1)
print(p2)
print(People())		# 得到的内存地址都不同,也就是说类和类的实例都是生成的内存对象(类和不同的实例占不同的内存地址)

print(id(p1))
print(id(p2))
print(id(People()))	# 用id函数来看也不同
~~~



### 给对象加上属性

比较下面两段代码的传参方式:

~~~python
class People(object):
    pass


p1 = People()
p2 = People()

p1.name = "张三"  			# 给实例p1赋于属性name和值"张三"
p1.sex = "男"	    	 	# 给实例p1赋于属性sex和值"男"

p2.name = "李四"				# 给实例p2赋于属性name和值"李四”
p2.sex = "女"			 	# 给实例p2赋于属性sex和值"女"

print(p1.name, p1.sex)
print(p2.name, p2.sex)		# 可以打印出赋值的数据
~~~

~~~python
class People(object):

    def __init__(self, name, sex):  # 第一个参数一定是self,代表实例本身.其它要传的参数与函数传参一样(可以传位置参数,关键字参数,默认参数,不定长参数等);__init__为构造函数
        self.name = name		      # 此变量赋给了实例,也就是实例变量
        self.sex = sex

        
p1 = People("张三", "男")		  # 实例化的时候直接传参数
p2 = People("李四", "女")

print(p1.name, p1.sex)
print(p2.name, p2.sex)			  # 也可以打印出传入的值
~~~



### 给类加上方法

比较上面代码和下面这段代码

~~~python
class People(object):

    def __init__(self, name, sex):
        self.name = name
        self.sex = sex

    def info(self):					# 定义类的方法,就是一个封装的函数
        print(self.name, self.sex)	# 此方法就是打印对象的name和sex

p1 = People("张三", "男")		  	
p2 = People("李四", "女")

p1.info()
p2.info()							# 对象调用类的方法
~~~



### 类的变量

> 类的变量是做什么用的？

先来看几个例子：

**示例:类变量可以被类调用，也可以被实例调用**

~~~python
class People(object):
    country = "中国"			# 类变量

    def __init__(self, name, sex):
        self.name = name	# 实例变量
        self.sex = sex

    def info(self):
        print(self.name, self.sex)


p1 = People("张三", "男")

print(People.country)		# 可以看到可以打印类变量的值(值为"中国")
print(p1.countryc)			# 也可以打印实例化后的类变量的值(值为"中国")
~~~

**示例: 类变量与实例变量同名时，实例变量优先于类变量（就好像后赋值的会覆盖前面赋值的)**

~~~python
class People(object):
    name = "中国"			# 类变量与实例变量同名

    def __init__(self, name, sex):
        self.name = name	# 实例变量
        self.sex = sex

    def info(self):
        print(self.name, self.sex)

p1 = People("张三", "男")		  	
p2 = People("李四", "女")

print(People.name)		# 结果为"中国"
print(p1.name)			# 结果为zhangsan。说明变量重名时,实例变量优先于类变量
~~~

**示例: 类变量,实例1,实例2都是独立的内存空间，修改互不影响**

~~~python
class People(object):
    name = "中国"				# 类变量

    def __init__(self, name, sex):
        self.name = name
        self.sex = sex

    def info(self):
        print(self.name, self.sex)

p1 = People("张三", "男")		  	
p2 = People("李四", "女")

p1.name = "美国"			# 对p1实例的类变量赋值"美国"
print(p1.name)			 # 结果为"美国"
print(p2.name)			 # 结果仍为"中国",说明p1的修改不影响p2
print(People.name)		 # 结果仍为"中国",说明p1的修改是在p1的内存地址里改的,也不影响类变量本身
~~~



**小结:**

1. 类变量是对所有实例都生效的，对类变量的增，删，改也对所有实例生效（前提是不要和实例变量同名冲突，同名冲突的情况下，实例变量优先）
2. 类和各个实例之间都是有独立的内存地址，在实例里（增，删，改）只对本实例生效，不影响其它的实例。



**练习: 在原来的name,sex两个属性的基础上再加上一个country属性(大部分人国籍是中国, 少部分是外国人的情况 )**

方法1: 使用实例变量来实现

~~~powershell
class People(object):

    def __init__(self, name, sex, country):
        self.name = name      		# 实例变量  
        self.sex = sex
        self.country = country

    def info(self):
        return "{} {} {}".format(self.name, self.sex, self.country)

p1 = People("张三", "男", "中国")				# 每次实例1个人都需要传值给country

print(p1.info())
~~~

方法2: 使用默认值参数来实现

~~~powershell
class People(object):

    def __init__(self, name, sex, country="中国"):	# 默认值参数
        self.name = name      		
        self.sex = sex
        self.country = country

    def info(self):
        return "{} {} {}".format(self.name, self.sex, self.country)

p1 = People("张三", "男", "美国")			# 不传国籍,默认为中国;传了美国则为美国

print(p1.info())
~~~

方法3: 使用类变量来实现

~~~powershell
class People(object):

    country = "中国"              # 类变量

    def __init__(self, name, sex):
        self.name = name        
        self.sex = sex

    def info(self):
        return "{} {} {}".format(self.name, self.sex, self.country)

p1 = People("张三", "男")				# 不用传值给country,默认为中国
p1.country = "美国"					 # 如果p1为外国人,则赋值替换就OK
print(p1.info())
~~~



### \_\_str\_\_与\_\_del_\_\_(了解)

~~~python
class Hero(object):

    def __init__(self, name):
        self.name = name

    def __str__(self):		# print(对象)会输出__str__函数的返回值
        return "我叫{},我为自己代言".format(self.name)

    def __del__(self):		# 对象调用完销毁时,会调用此函数
        print("......我{}还会回来的......".format(self.name))

hero1 = Hero("亚瑟")
hero2 = Hero("后羿")

print(hero1)
print(hero2)		

# del hero1
# del hero2			# 把这两句del注释分别打开，会有不同的效果

print("="*30)
~~~

**小结:**

| 方法                   | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| def \_\_init\_\_(self) | 创建对象的时候自动调用此方法                                 |
| def \_\_str_\_(self)   | print(对象)时调用此方法                                      |
| def \_\_del_\_(self)   | 对象被销毁的时候自动调用该方法,做一些收尾工作，如关闭打开的文件，释放变量等 |



### 私有属性与私有方法(拓展)

一般情况下，私有的属性、方法都是不对外公布的，往往用来做内部的事情，起到安全的作用。

python没有像其它语言那样有public,private等关键词来修饰，而是在变量前加__来实现私有。

**示例:**

~~~python
class People(object):

    __country = "中国"		# 前面加上__，那么就做成了私有属性，就不能被类的外部直接调用

    def __init__(self, name, sex):
        self.name = name
        self.__sex = sex		# 前面加上__，那么就做成了私有属性，就不能被类的外部直接调用

    def info(self):		# 前面加上__，那么就做成了私有方法，就不能被类的外部直接调用
        print(self.name, self.sex)

        
p1 = People("张三", "男")
# print(p1.sex)		
# print(p1.__sex)		
# print(p1.country)
# print(p1.__country)		
# p1.info()
# p1.__info()					# 这六句单独打开注释验证，都会报错。不能调用私有属性和私有方法
~~~

**示例: 如果类的外部需要调用到私有属性的值，可以对私有属性单独定义一个类的方法，让实例通过调用此方法来调用私有属性(私有方法同理)**

~~~python
class People(object):

    __country = "中国"

    def __init__(self, name, sex):
        self.name = name
        self.__sex = sex		
        
    def __info(self):
        print(self.name, self.__sex)

    def show_sex(self):
        print(self.__sex)

    def show_country(self):
        print(self.__country)

    def show_info(self):
        People.__info(self)

p1 = People("张三", "男")

p1.show_sex()
p1.show_country()
p1.show_info()		
~~~

**小结:** 内部属性不希望被外部调用与修改,就可以做成私有的.





## 继承

### 继承介绍

> 什么是继承？

![1541353218731](图片/继承.png)

~~~python
class  人
	吃
	喝	
	玩
	拉
	睡
class 老师
	上课
    备课
class 工程师
	上班
    加班
~~~

**继承的作用**: ==**减少代码的冗余,便于功能的升级（原有的功能进行完善）与扩展（原没有的功能进行添加）**==

**示例:**

~~~python
class People(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def eat(self):
        print("{}正在吃".format(self.name))

    def drink(self):
        print("{}正在喝".format(self.name))

class Man(People):			# 表示Man类继承父类（基类，超类）People
    pass

class Woman(People):		# 表示Woman类继承父类（基类，超类）People
    pass

m1 = Man("张三", 16)
m1.eat()					# 继承了父类，就可以调用父类的方法
m1.drink()					# 继承了父类，就可以调用父类的方法

w1 = Woman("李四", 18)
w1.eat()					# 继承了父类，就可以调用父类的方法
w1.drink()					# 继承了父类，就可以调用父类的方法
~~~

### 方法重写(难点)

**示例: 在子类里重写父类的方法**

~~~python
class People(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def eat(self):
        print("{}正在吃".format(self.name))

    def drink(self):
        print("{}正在喝".format(self.name))


class Man(People):
    def eat(self):						# 在子类中重写父类的方法
        print("{}正在吃肉".format(self.name))

class Woman(People):
    def eat(self):						# 在子类中重写父类的方法
        print("{}正在吃素".format(self.name))

class Woman(People):
    pass

m1 = Man("张三", 16)
m1.eat()

w1 = Woman("李四", 18)
w1.eat()

~~~

示例: 子类中增加方法和方法中调用方法

~~~python
class People(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def eat(self):
        print("{}正在吃".format(self.name))

    def drink(self):
        print("{}正在喝".format(self.name))


class Man(People):
    def eat(self):
        print("{}正在吃肉".format(self.name))
    def work(self):					# 在子类中增加一个父类中没有的方法
        print("{}正在辛苦工作".format(self.name))
        self.eat()					# 在方法中调用方法
        self.drink()				# 也可以调用父类的方法

class Woman(People):
    def eat(self):
        print("{}正在吃素".format(self.name))


m1 = Man("张三", 20)
m1.work()
~~~



### 子类重新构造属性(难点)

**示例:在子类重新构造属性**

~~~python
class People(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def eat(self):
        print("{}正在吃".format(self.name))

    def drink(self):
        print("{}正在喝".format(self.name))


class Man(People):
    def eat(self):
        print("{}正在吃肉".format(self.name))
    def work(self):
        print("{}正在辛苦工作".format(self.name))
        self.eat()
        self.drink()

class Woman(People):
# 下面这段代码就是在父类原来的name,age两个属性的基础上加上了一个love_shopping属性
    def __init__(self, name, age, love_shopping):	
        super(Woman, self).__init__(name, age) # 这一句写法比较难记,对应父类的name,age属性
        self.love_shopping = love_shopping

    def eat(self):
        print("{}正在吃素".format(self.name))

    def shopping(self):
        if self.age >= 18 and self.love_shopping == True:
            print("{}，去逛街吧".format(self.name))
        else:
            print("{},不要去逛街，乖乖呆家里面!".format(self.name))


w1 = Woman("李四", 18, False)
w1.shopping()
~~~



### 多层继承(了解)

**示例: 多层继承例一**

~~~python
class Grandfather(object):

    def house(self):				# 爷爷类的方法
        print("a big house!")

class Father(Grandfather):			# 爸爸类继承爷爷类

    def car(self):
        print("a cool car!")

class child(Father):				# 孩子类继承爸爸类
    pass

p1 = child()						# 实例化一个孩子
p1.house()							# 这个孩子对象可以调用爷爷的方法
~~~



### 多重继承(了解)

支持面向对象编程的开发语言中，支持多重继承的语言并不多，像java,php这些都只支持单继承。支持多重继承的主要就是python,c++。

> 什么是多重继承？
>
> 答: 多重继承，即子类有多个父类(可以多于两个)，并且具有它们的特征。

![1541394674749](图片/多继承.png)

**示例: 多重继承例一**

~~~python
class Father(object):

    def sing(self):
        print("can sing")

class Mother(object):

    def dance(self):
        print("can dance")

class child(Father, Mother):			# 继承Father,Mother两个父类
    pass

p1 = child()
p1.sing()							# 可以用Father的方法
p1.dance()							# 也可以用Mother的方法
~~~



### **两个对象交互**

**单继承实现**

~~~powershell
class People(object):
    def __init__(self, name, sex):
        self.name = name
        self.sex = sex

    def fall_in_love(self, obj):
        if self.sex == "男":
            print("{}向{}求婚".format(self.name, obj.name))
        elif self.sex == "女":
            print("{}要给{}生猴子".format(self.name, obj.name))
        else:
            print("性别输入有误")

class Man(People):				
    pass
class Woman(People):
    pass

m1 = Man("张三", "男")
w1 = Woman("李四", "女")

m1.fall_in_love(w1)				# w1传参给fall_in_love里的ojb
w1.fall_in_love(m1)
~~~



**多层继承实现**

~~~powershell
class People(object):
    def __init__(self, name, sex):
        self.name = name
        self.sex = sex

class Love(People):
    def fall_in_love(self, obj):
        if self.sex == "男":
            print("{}向{}求婚".format(self.name, obj.name))
        elif self.sex == "女":
            print("{}要给{}生猴子".format(self.name, obj.name))
        else:
            print("性别输入有误")

class Man(Love):
    pass
class Woman(Love):
    pass

m1 = Man("张三", "男")
w1 = Woman("李四", "女")

m1.fall_in_love(w1)
w1.fall_in_love(m1)
~~~



**多重继承实现**

~~~python
class People(object):
    def __init__(self, name, sex):
        self.name = name
        self.sex = sex

class Love(object):
    def fall_in_love(self,obj):
        if self.sex == "男":			# 这里的sex变量在Love类里并没有定义
            print("{}向{}求婚".format(self.name, obj.name))
        elif self.sex == "女":
            print("{}要给{}生猴子".format(self.name, obj.name))
        else:
            print("性别输入有误")
            
class Man(People, Love):		# Love里没有sex变量,People里有sex变量,多重继承合到一起就OK
    pass

class Woman(People, Love):
    pass

m1 = Man("张三", "男")
w1 = Woman("李四", "女")

m1.fall_in_love(w1)
w1.fall_in_love(m1)
~~~





## 多态(拓展)

多态: 一类事物的有多种形态。如水蒸汽，水，冰。

回顾下我们前面讲过: Python是强类型的**==动态==**解释型语言,这里的动态其实就是多态。 

python是变量本身是没有类型的，变量的类型是由赋的值所决定的。值是int，变量就是int; 值是str，变量类型就是str。这其实就是一种多态。

python崇尚鸭子类型(ducking type):  鸭子类型是动态类型的一种风格。"当看到一只鸟走起来像鸭子、游泳起来像鸭子、叫起来也像鸭子，那么这只鸟就可以被称为鸭子。" 在鸭子类型中，关注的不是对象的类型本身，而是它是如何使用的。

==作用: 接口统一==



**示例:**

~~~python
class Animal(object):
   def jiao(self):
        pass

class Dog(Animal):
    def jiao(self):
        print("wang wang...")

class Cat(Animal):
    def jiao(self):
        print("miao miao...")

d1 = Dog()
c1 = Cat()

d1.jiao()		# 实例接类的方法来调用，结果是狗叫
c1.jiao()		# 实例接类的方法来调用，结果为猫叫
~~~

**示例:**

~~~python
class Animal(object):
   def jiao(self):
        pass

class Dog(Animal):
    def jiao(self):
        print("wang wang...")

class Cat(Animal):
    def jiao(self):
        print("miao miao...")

def jiao(obj):
     obj.jiao()

d1 = Dog()
c1 = Cat()

jiao(d1)		# 调用方式统一
jiao(c1)		# 调用方式统一
~~~

# **把类做成模块给别人调用**

假设下面的代码就是在当前项目目录下的一个模块，名为`sound.py`

~~~powershell
class Animal(object):
   def jiao(self):
        pass

class Dog(Animal):
    def jiao(self):
        print("wang wang...")

class Cat(Animal):
    def jiao(self):
        print("miao miao...")

def jiao(obj):
     obj.jiao()
~~~

当前项目目录另一个文件要调用上面的模块

~~~python
import sound

d1 = sound.Dog()			# 实例化一个对象叫d1

sound.jiao(d1)				# 把d1对象做为一个参数传给sound模块里的jiao函数
~~~



* 



# 课后示例与练习

**示例: 一个英雄与怪物互砍小游戏**

~~~python
import random

# 定义英雄类
class Hero(object):

    def __init__(self, name):
        self.name = name
        self.hp = 100  # 血量
        self.attack = random.randint(31, 100)  # 随机产生攻击值
        self.defense = 30

    # 显示英雄信息
    def __str__(self):
        return "名字:%s 血量:%s 攻击:%d 防御:%d" % (self.name, self.hp, self.attack, self.defense)

    # 攻击函数
    def fight(self, monster):
        # 计算怪物掉血多少
        mhp = self.attack - monster.defense
        # 减少怪物血量
        monster.hp = monster.hp - mhp
        # 提示信息
        print("英雄[%s]对怪物[%s]造成了%d伤害!" % (self.name, monster.name, mhp))

      
        
#  定义怪物类
class Monster(object):
    def __init__(self, name):
        self.name = name
        self.hp = 100  # 血量
        self.attack = random.randint(31, 100)  # 随机产生攻击值
        self.defense = 30

    # 显示怪物信息
    def __str__(self):
        return "名字:%s 血量:%s 攻击:%d 防御:%d" % (self.name, self.hp, self.attack, self.defense)

    # 攻击函数
    def fight(self, hero):
        # 计算怪物掉血多少
        mhp = self.attack - hero.defense
        # 减少怪物血量
        hero.hp = hero.hp - mhp
        # 提示信息
        print("怪物[%s]对英雄[%s]造成了%d伤害!" % (self.name, hero.name, mhp))


# 创建对象
hero = Hero("一刀满级")
# 创建怪物
monster = Monster("打死我爆好装备")
# 回合数
my_round = 1
# 开始回合战斗
while True:
    input()
    print(hero)
    print(monster)
    print("-"*50)
    print("当前第%d回合:" % my_round)
    hero.fight(monster)
    if monster.hp <= 0:
        print("英雄[%s]击败了怪物[%s],顺利通关!" % (hero.name, monster.name))
        break
    monster.fight(hero)
    if hero.hp <= 0:
        print("怪物[%s]仰天大笑，哈哈哈,弱鸡!" % monster.name)
        break

    my_round += 1

print("Game Over!")
~~~

**参考: 下例把paramiko的远程执行命令，上传，下载功能简单地做成了面向对象编程的方法。请解决相关bug或按此思路扩展写其它程序**

~~~python
import paramiko,sys

class Host(object):

	port = 22   

    def __init__(self, ip, port, username, password):
        self.ip = ip
        self.port = port
        self.username = username
        self.password = password

    def exec_cmd(self):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
        ssh.connect(hostname=self.ip, port=self.port, username=self.username, password=self.password)
        input_cmd = input("请输入你要执行的命令: ")
        stdin, stdout, stderr = ssh.exec_command(input_cmd)

        print(cor_res.read().decode())
        print(err_res.read().decode())
        ssh.close()

    def get_or_put(self):
        trans = paramiko.Transport((self.ip, int(self.port)))
        trans.connect(username=self.username, password=self.password)
        sftp = paramiko.SFTPClient.from_transport(trans)
        if choice == 2:
            get_remote_file = input("下载文件的路径: ")
            get_local_file = input("下载到本地的路径: ")
            sftp.get(get_remote_file,get_local_file)
        else:
            put_local_file = input("要上传的本地文件路径: ")
            put_remote_path = input("上传到远程的路径: ")
            sftp.put(put_local_file,put_remote_path)

print("菜单")
print("1-exec")
print("2-get")
print("3-put")
print("0-quit")


host1 = Host(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

choice=int(input("your choice: "))
if choice == 1:
    host1.exec_cmd()
elif choice == 2 or choice == 3:
    host1.get_or_put()
elif choice == 0:
    exit(1)

    
# python3.6 脚本名  10.1.1.12 22 root 123456
~~~



