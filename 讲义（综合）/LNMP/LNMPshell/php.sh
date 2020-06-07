#!/usr/local/bin
#php源码安装
yum -y install libxml2-devel libjpeg-devel libpng-devel freetype-devel curl-devel openssl-devel
echo "依赖安装完成"
sleep 2

id www
if [ $? -eq 0 ];then
	echo "www用户已经安装"
else 
	useradd -r -s /sbin/nologin www
	sleep 2
	echo "用户创建完成"
fi 



tar -zxf /root/php-7.2.12.tar.gz
echo "解压完成"
sleep 2

cd /root/php-7.2.12
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --enable-ftp --with-gd --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --with-libzip --enable-soap --without-pear --with-gettext --disable-fileinfo --enable-maintainer-zts
echo "源码配置完成"
sleep 2
make && make install
echo "编译以及安装完成"
sleep 2


cp /root/php-7.2.12/php.ini-development /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
echo "php-fpm配置文件已经修改完毕"
sleep 2

cp /root/php-7.2.12/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
service php-fpm start
sleep 2
echo "php已经启动"


echo 'PATH=/usr/local/php/bin:$PATH' >> /etc/profile
source /etc/profile
echo "环境变量已经添加"

