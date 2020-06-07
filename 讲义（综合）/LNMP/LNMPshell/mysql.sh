#!/usr/local/bin
id mysql
if [ $? -eq 0 ];then
        echo "mysql用户已经存在，无需再次添加"
else
	groupadd -g 27 mysql
        useradd -u 27 -g mysql -s /sbin/nologin mysql
        sleep 1
        echo "mysql用户已经添加成功"
fi
sleep 2

mkdir /usr/local/mysql
tar -zxvf /root/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz 
sleep 1
echo "解压完成"

cd mysql-5.6.35-linux-glibc2.5-x86_64/
cp -a ./* /usr/local/mysql/
sleep 1
echo "文件拷贝完成"


chown -R mysql.mysql  /usr/local/mysql/
sleep 1
echo "权限修改完毕"

echo "正在移除依赖，请耐心等待"
yum -y remove mariadb-libs

if [ -e /etc/my.cnf ];then
       rm -rf /etc/my.cnf
       sleep 1
       echo "文件存在并且已经删除"

else
        echo "文件不存在"
fi
sleep 1

cd /usr/local/mysql
scripts/mysql_install_db --user=mysql
sleep 1
echo "数据库初始化完成"

cp support-files/mysql.server /etc/init.d/mysql
sleep 1
echo "启动文件已经拷贝到服务列表"

echo "服务正在启动，请稍后"
service mysql start
sleep 1

ss -anput | grep mysql
if [ $? -eq 0 ];then
          sleep 1
          echo "mysql服务已经启动"
else
	  sleep 1
          echo "mysql服务启动失败"
fi

echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile
sleep 1
echo "环境变量已经添加"

echo "正在登陆数据库，请耐心等待。。。"
sleep 3
mysql -uroot

