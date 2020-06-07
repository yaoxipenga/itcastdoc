#!/usr/bin/bash
mount /dev/sr0 /mnt
echo "光盘已经挂载"
sleep 1
yum -y install pcre-devel zlib-devel openssl-devel
echo "nginx依赖已经安装完成"
sleep 1
useradd -r -s /sbin/nologin www
echo "www用户已经增加"
sleep 1
tar xvf /root/nginx-1.12.2.tar.gz
echo "解压完成"
sleep 1
cd /root/nginx-1.12.2
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module

make && make install
sleep 1
echo "nginx安装完成"

cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=Nginx Web Server
After=network.target
  
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
  
[Install]
WantedBy=multi-user.target
EOF

systemctl start nginx.service
systemctl enable nginx.service

ss -anput | grep nginx &> /dev/null
if [ $? -eq 0 ];then 
	echo "nginx服务已经启动"
else 
	echo "nginx服务启动失败"
fi

sleep 2
echo "所有操作已经完成，可以正常使用nginx"
