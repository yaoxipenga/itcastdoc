## 调用图形

```powershell
# virt-manager
```

## 命令安装虚拟机

```powershell
# virt-install  --name "kvm2" --memory 2048,maxmemory=4096 --vcpus 2,maxvcpus=4 --disk=/var/lib/libvirt/images/kvm2.qcow2,size=50 -l /share/iso/CentOS-7-x86_64-DVD-1810.iso --network bridge=virbr0
```

```powershell
网卡配置:
BOOTPROTO="static"
NAME="eth0"
DEVICE="eth0"
ONBOOT="yes"
IPADDR=192.168.122.13
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
```

## 命令帮助

```powershell
# virsh help
# virsh help domain	  (一个虚拟机就称为一个domain)
# virsh help network
# virsh help monitor
```

## 查看虚拟机列表

```powershell
# virsh  list
# virsh list --all
```

## 启动,关闭,重启

```powershell
# virsh  start kvm1   (正常启动一个虚拟机)
# virsh shutdown kvm1 (正常关闭一个虚拟机)
# virsh reboot kvm1   (正常重启一个虚拟机)
# virsh destroy kvm1  (强制关闭一个虚拟机)
# virsh  reset kvm1   (reset相当于是先destroy,再start)
```

## 保存,暂停

```powershell
把kvm1关闭，并把当前状态保存为一个文件,这个不是快照。
# virsh save kvm1 /etc/libvirt/qemu/kvm1.save

通过保存的文件，恢复当时save时的状态
# virsh restore /etc/libvirt/qemu/kvm1.save

暂停kvm1的状态
# virsh suspend kvm1

由暂停切换为继续的状态
# virsh resume kvm1
```

## 连接

```powershell
方法一:宿主机打开管理器，双击你要连接的虚拟机(需要宿主机图形环境)
# virt-manager

方法二:宿主机连接一个已经启动的虚拟机，并使用图形查看(需要宿主机图形环境)
# virt-viewer kvm1

方法三:非图形环境就可以连接，只要网络OK
# ssh x.x.x.x

方法四:在宿主机上直接console连接（此方法不需要虚拟机配置ip都行,但需要配置授权)
虚拟机里配置授权重启
# grubby --update-kernel=ALL --args="console=ttyS0"
# reboot
# virsh console kvm1
```

## 远程连接

```powershell
# virt-viewer -c qemu+ssh://root@192.168.2.105/system kvm1
```

## 查看配置文件

```powershell
方法一
# vim /etc/libvirt/qemu/kvm1.xml

方法二
# virsh edit kvm1
```

```powershell
设置vim的软链接						
# which vi							
/usr/bin/vi							
# which vim							
/usr/bin/vim						
# mv /usr/bin/vi /usr/bin/vi.bak	
# ln -s /usr/bin/vim /usr/bin/vi
```

## 命令删除虚拟机

```powershell
先关闭虚拟机
# virsh destroy kvm3  

undefine就是取消定义的意思，但此命令只会删除配置文件,不会删除磁盘文件
# virsh undefine kvm3 

使用rm -rf删除磁盘文件
# rm -rf /var/lib/libvirt/images/kvm3.qcow2 
```

## 命令管理快照

```powershell
查看相关帮助
# virsh help snapshot

查看kvm1这个虚拟机的快照 
# virsh snapshot-list kvm1

为kvm1当前状态创建一个快照，名称为snap1;后面的描述信息自定义
# virsh snapshot-create-as --domain kvm1 snap1 --description "my first test snapshot"

恢复kvm1的快照snap1
# virsh snapshot-revert kvm1 snap1

删除kvm1的快照snap1
# virsh snapshot-delete kvm1 snap1
```

## 命令克隆

```powershell
把kvm1克隆成kvm3,指定磁盘路径为/var/lib/libvirt/images/kvm3.qcow2
# virt-clone -o kvm1 -n kvm3 -f /var/lib/libvirt/images/kvm3.qcow2 
```

## 手动克隆

```powershell
拷贝配置文件和磁盘文件
# cp /etc/libvirt/qemu/kvm1.xml /etc/libvirt/qemu/kvm4.xml
# cp /var/lib/libvirt/images/kvm1.qcow2 /var/lib/libvirt/images/kvm4.qcow2

修改拷贝后的配置文件
# vim /etc/libvirt/qemu/kvm4.xml
第一步:虚拟机名称改为克隆后的名称kvm4
第二步:uuid随便改几个字符,和以前不一样就行	
第三步:磁盘文件路径要改
第四步:MAC地址后三位改1个字符就行(但不要改成f之后的字符)

保存后,使用virsh list --all查看不到的,需要define一下
# virsh define /etc/libvirt/qemu/kvm4.xml
再查就可以查看到kvm4
# virsh list --all		
可以启动验证使用了
# virsh start kvm4

```

## 查看网络

```powershell
只查看与网络有关的帮助参数
# virsh help network

查看所有的网络
# virsh net-list --all
# virsh net-info default

注:virbr0是在宿主机上产生的一张网卡名,这张网卡就是连接到default网络上。如果虚拟机的网卡也连接到default网络,则与宿主机的virbr0属于同一个物理网络上
```

## 网络配置文件

```powershell
# vim /etc/libvirt/qemu/networks/default.xml
# virsh net-edit default
```

## 网络的停止与启动

```powershell
停掉default网络，用`virsh net-list --all`去查看，状态变为inactive
# virsh net-destroy default

启动default网络，状态变为active
# virsh net-start default
```

## 命令增加网络

```powershell
拷贝配置文件并修改
# cp /etc/libvirt/qemu/networks/network1.xml /etc/libvirt/qemu/networks/network2.xml

# vim /etc/libvirt/qemu/networks/network2.xml
<network>
  <name>network2</name>									名称由network1改为network2
  <uuid>d1203347-bc49-40dc-bd26-d25dfb47647a</uuid>   	uuid随便改几个字符
  <bridge name='virbr2' stp='on' delay='0'/>			由virbr1改为virbr2
  <mac address='52:54:00:53:59:df'/>					MAC后三位随便改1个字符就OK了
  <domain name='network2'/>								由network1改为network2
  <ip address='192.168.101.1' netmask='255.255.255.0'>	换一个没用过的网段192.168.101.0/24
    <dhcp>
      <range start='192.168.101.128' end='192.168.101.254'/>  dhcp范围也要改成对应网段
    </dhcp>
  </ip>
</network>

定义修改好的网络配置文件
# virsh net-define /etc/libvirt/qemu/networks/network2.xml
# virsh net-list --all

启动网络
# virsh net-start network2
# virsh net-list --all
# ifconfig virbr2 |head -3

设置网络为开机自动启动
# virsh net-autostart network2
# virsh net-list --all
```

## 修改私有网络

```powershell
打开网络配置文件并修改网段
# virsh net-edit default
<network>
  <name>default</name>
  <uuid>ad878490-5da7-44a7-8e27-1979a3802024</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:06:18:19'/>
  <ip address='10.1.1.1' netmask='255.255.255.0'>	修改
    <dhcp>
      <range start='10.1.1.2' end='10.1.1.254'/>	修改
    </dhcp>
  </ip>
</network>

停止网络
# virsh net-destroy default

启动网络
# virsh net-start default
# virsh net-start default
error: Failed to start network default
error: internal error: Network is already in use by interface enp2s0
报错: 网络已经被宿主机的网卡enp2s0占用
解决方法:
# ifconfig enp2s0 down
# virsh net-start default
Network default started
# ifconfig enp2s0 up

验证成功
# ifconfig virbr0
```

## 命令删除网络

```powershell
先停掉要删除的网络
# virsh net-destroy default2

用net-undefine删除网络,网络配置文件也会被删除
# virsh net-undefine default2
```

## 增加bridge网络

```powershell
在宿主机上确认NetworkManager服务关闭
# systemctl stop NetworkManager
# systemctl disable NetworkManager
# systemctl status NetworkManager

配置网卡配置文件
原物理网卡enp2s0里的配置只留下这三句就可以了
# vim /etc/sysconfig/network-scripts/ifcfg-enp0s25
DEVICE="enp0s25"
ONBOOT="yes"
BRIDGE=br0

新建一个br0网卡的配置文件
# vim /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0					--名字对应好
TYPE=Bridge					--这里的Birdge,B要大写,后面的irdge要小写
BOOTPROTO=static
IPADDR=192.168.X.X			--把原来enp2s0物理网卡的IP写在这里
NETMASK=255.255.255.0
GATEWAY=192.168.X.X			--把原来enp2s0物理网卡的网关写在这里
DNS1=114.114.114.114
ONBOOT=yes

重启网络
# systemctl restart network

下面命令查看相应的IP
# ifconfig br0         --有IP
# ifconfig enp2s0	   --没有IP了，这是正常的	
```

## 命令修改网卡连接网络

```powershell 
# virsh edit kvm1

    <interface type='network'>
      <mac address='52:54:00:f0:71:92'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>

改成下面的样子

    <interface type='bridge'>		--network改成了bridge
      <mac address='52:54:00:f0:71:92'/>
      <source bridge='br0'/>		--network改成了bridge;default改成了br0
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>

# virsh shutdown kvm1
# virsh start kvm1
```

## 创建磁盘镜像

```powershell 
创建raw格式磁盘镜像
# qemu-img create disk1.raw 1G
# qemu-img info disk1.raw

创建qcow2格式磁盘镜像
# qemu-img create disk2.qcow2 -f qcow2 1G
# qemu-img info disk2.qcow2
# ll disk*
```

## 磁盘镜像格式转换

```powershell 
raw转qcow2格式
# qemu-img convert -p -f raw -O qcow2 disk1.raw disknew1.qcow2

qcow2格式转raw格式
# qemu-img convert -p -f qcow2 -O raw disk2.qcow2 disknew2.raw
```

## 后备镜像转差量镜像

```powershell 
格式为:
# qemu-img create -f qcow2 -b 后备镜像路径 差量镜像路径

实例:
# qemu-img create -f qcow2 -b /var/lib/libvirt/images/kvm2.qcow2 kvm2.bak.qcow2
```

## 编写虚拟机快速创建脚本

```powershell 
准备模板配置和虚拟机磁盘文件(这里以安装并优化OK的kvm1虚拟机为拷贝模板)
# mkdir /share/kvm -p
# cp /etc/libvirt/qemu/kvm1.xml /share/kvm/centos7.6.xml
# cp /var/lib/libvirt/images/kvm1.qcow2 /share/kvm/centos7.6.qcow2
```

```powershell 
修改配置文件里的名称,uuid,disk路径,mac分别为vmname,vmuuid,vmdisk,vmmac这4个名称
# vim /share/kvm/centos7.6.xml

<domain type='kvm'>
  <name>vmname</name>											修改为vmname
  <uuid>vmuuid</uuid>											修改为vmuuid
......
......
......
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='vmdisk'/>									修改为vmdisk
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
......
......
......
    <interface type='network'>
      <mac address='vmmac'/>									修改为vmmac
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
......
......
......
```

```powershell 
编写脚本(可以自由修改)
/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"


read -p "请输入要创建的kvm虚拟机名称:" name
vmname=/etc/libvirt/qemu/$name
vmdisk=/var/lib/libvirt/images/$name.qcow2

# 拷贝模板到对应的路径位置,磁盘文件使用的是差量镜像
cp /share/kvm/centos7.6.xml $vmname.xml
qemu-img create -f qcow2 -b /share/kvm/centos7.6.qcow2 $vmdisk &> /dev/null


# 将上面产生好的变量值使用sed修改配置文件,并define使之生效(sed使用#,因为路径为/,用#替换不用转义)
sed -ri "s#vmname#$name#"   $vmname.xml
sed -ri "s#vmuuid#$vmuuid#" $vmname.xml
sed -ri "s#vmdisk#$vmdisk#" $vmname.xml
sed -ri "s#vmmac#$vmmac#"   $vmname.xml

virsh define $vmname.xml

echo "$name创建完成"
virsh list --all
```

```powershell 
执行测试
# sh /share/kvm/create_kvm.sh
```

```powershell 
参考另外一种产生mac地址后4位的脚本
#!/bin/bash

array=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

for i in `seq 8`
do
        if [ $[$i%2] -eq 1 ];then
                echo -n ":"${array[$[$RANDOM%16]]}
        else
                echo -n ${array[$[$RANDOM%16]]}
        fi
done
```

```powershell 
脚本另一种写法参考
#!/bin/bash

uuid=$(uuidgen)
vmmac="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
read -p "输入你要创建的虚拟机名称:" name

configname=/etc/libvirt/qemu/${name}.xml
diskpath=/var/lib/libvirt/images/${name}.qcow2

cp /share/kvm/centos7.6.xml  $configname

qemu-img create -f qcow2 -b /share/kvm/centos7.6.qcow2 $diskpath


sed -i 's/vmname/'$name'/' $configname
sed -i 's/vmuuid/'$uuid'/' $configname
sed -ri 's#vmdisk#'$diskpath'#' $configname
sed -ri 's#vmmac#'$vmmac'#' $configname

virsh define $configname
echo "$name创建成功"
virsh list --all
```

