# k8s企业项目

## 一、企业k8s及架构

### 1.自建型k8s架构

利用公司自己的服务器（云服务器）采用k8s相关软件自己搭建集群。

优势：k8s集群组件可以根据公司业务自我部署搭建，服务自定义，灵活可扩展能新组件，在应用过程中可以积累一套完整的k8s架构经验，成为公司的技术壁垒。

缺点：搭建集群繁琐，对运维人员k8s知识要求高，运维成本高，容器是一个系统性工程，涉及网络、存储、操作系统、编排等各种技术，需要专门的人员投入。容器技术一直在不断发展，版本迭代快，需要不断的采坑、升级、测试。



### 2.容器服务架构

购买阿里腾讯等云服务的容器服务kubernetes版集群

优势：k8s集群架构统一使用第三方提供的架构，完全托管，只需要按需求购买增加node节点数量即可。

阿里云的容器服务 K8S 提供升级方案，通过镜像滚动升级，且有完整的元数据备份策略。支持node节点弹性扩缩容。

缺点：k8s集群架构不可控，按照第三方的现有架构服务使用，无法积累完整K8S架构运维经验，受制于人。



## 二、自建k8s架构

### 1.master和etcd高可用

kubernetes集群主要有两种类型的节点：Master和Worker。
Master则是集群领导。
Worker是工作者节点。
K8S集群要的工作在Master节点，Worker节点根据具体需求随意增减就好了。

### 2.etcd高可用

etcd的高可用拓补官方给出了两种方案。

1. Stacked etcd topology（堆叠etcd）
2. External etcd topology（外部etcd）

**可以看出最主要的区别在于etcd的部署方式。**
第一种方案是所有k8s Master节点都运行一个etcd在本机组成一个etcd集群。

![img](图片/1.png)

第二种方案则是使用外部的etcd集群（额外搭建etcd集群）。
我们采用的是第二种，外部etcd，拓补图如下：

![](图片/2.png)

### 3.Master集群

1. apiserver
2. controller-manager
3. scheduler

一个master节点主要含有上面3个组件
**apiserver**: 一个api服务器，所有外部与k8s集群的交互都需要经过它。（可水平扩展）
**controller-manager**: 执行控制器逻辑（循环通过apiserver监控集群状态做出相应的处理）（一个master集群中只会有一个节点处于激活状态）
**scheduler**: 将pod调度到具体的节点上（一个master集群中只会有一个节点处于激活状态）

除了apiserver外都只允许一个 实例处于激活状态运行于其它节点上的实例属于待命状态，只有当激活状态的实例不可用时才会尝试将自己设为激活状态。

k8s依赖etcd所以不存在数据一致性的问题（把数据一致性压到了etcd上），所以k8s master不需要采取投票的机制来进行选举，而只需节点健康就可以成为leader。

master并不要求奇数，偶数也是可以的。
那么master高可用至少需要2个节点，失败容忍度是1，也就是只要有一个是健康的k8s master集群就属于可用状态。（**这边需要注意的是master依赖etcd，如果etcd不可用那么master也将不可用**）

### 4.高可用性测试

![](图片/3.png)

## 三、kubeasz搭建高可用集群

1.kubeasz介绍

kubeasz是一套基于kubernetes原生部署方式通过ansible实现所有部署过程使用playbook+roles完成的自动化部署方案，本身支持集群高可用方案，可同时部署多台master与ETCD。



2.kubeasz获取

使用Ansible脚本安装K8S集群，介绍组件交互原理，方便直接，不受国内网络环境影响

 https://github.com/easzlab/kubeasz



3.高可用集群部署规划

![](../../k8s%E5%88%86%E4%BA%AB/%E5%9B%BE%E7%89%87/%E5%9B%BE%E7%89%87/4.png)

- 注意1：请确保各节点时区设置一致、时间同步。 如果你的环境没有提供NTP 时间同步，推荐集成安装[chrony](https://github.com/easzlab/kubeasz/blob/master/docs/guide/chrony.md)
- 注意2：在公有云上创建多主集群，请结合阅读[在公有云上部署 kubeasz](https://github.com/easzlab/kubeasz/blob/master/docs/setup/kubeasz_on_public_cloud.md)
- 注意3：建议操作系统升级到新的稳定内核，请结合阅读[内核升级文档](https://github.com/easzlab/kubeasz/blob/master/docs/guide/kernel_upgrade.md)



## 三、高可用集群部署

| 角色       | 数量 | 描述                                                         |
| ---------- | ---- | ------------------------------------------------------------ |
| 管理节点   | 1    | 运行ansible/easzctl脚本，可以复用master，建议使用独立节点（1c1g） |
| etcd节点   | 3    | 注意etcd集群需要1,3,5,7...奇数个节点，一般复用master节点     |
| master节点 | 2    | 高可用集群至少2个master节点                                  |
| node节点   | 3    | 运行应用负载的节点，可根据需要提升机器配置/增加节点数        |

在 kubeasz 2x 版本，多节点高可用集群安装可以使用2种方式

- 1.先部署单节点集群 [AllinOne部署](https://github.com/easzlab/kubeasz/blob/master/docs/setup/quickStart.md)，然后通过 [节点添加](https://github.com/easzlab/kubeasz/blob/master/docs/op/op-index.md) 扩容成高可用集群
- 2.按照如下步骤先规划准备，直接安装多节点高可用集群

## 部署步骤

按照`example/hosts.multi-node`示例的节点配置，准备4台虚机，搭建一个多主高可用集群。

### 1.基础系统配置

- 推荐内存2G/硬盘30G以上
- 最小化安装`Ubuntu 16.04 server`或者`CentOS 7 Minimal`
- 配置基础网络、更新源、SSH登录等

### 2.在每个节点安装依赖工具

Ubuntu 16.04 请执行以下脚本:

```
# 文档中脚本默认均以root用户执行
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
# 安装python2
apt-get install python2.7
# Ubuntu16.04可能需要配置以下软连接
ln -s /usr/bin/python2.7 /usr/bin/python
```

CentOS 7 请执行以下脚本：

```
# 文档中脚本默认均以root用户执行
yum update
# 安装python
yum install python -y
```

### 3.在ansible控制端安装及准备ansible

- 3.1 pip 安装 ansible（如果 Ubuntu pip报错，请看[附录](https://github.com/easzlab/kubeasz/blob/master/docs/setup/00-planning_and_overall_intro.md#Appendix)）

```
# Ubuntu 16.04 
apt-get install git python-pip -y
# CentOS 7
yum install git python-pip -y
# pip安装ansible(国内如果安装太慢可以直接用pip阿里云加速)
pip install pip --upgrade -i https://mirrors.aliyun.com/pypi/simple/
pip install ansible==2.6.18 netaddr==0.7.19 -i https://mirrors.aliyun.com/pypi/simple/
```

- 3.2 在ansible控制端配置免密码登录

```
# 更安全 Ed25519 算法
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519
# 或者传统 RSA 算法
ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa

ssh-copy-id $IPs #$IPs为所有节点地址包括自身，按照提示输入yes 和root密码

```

### 4.在ansible控制端编排k8s安装

- 4.0 下载项目源码
- 4.1 下载二进制文件
- 4.2 下载离线docker镜像

推荐使用 easzup 脚本下载 4.0/4.1/4.2 所需文件；运行成功后，所有文件（kubeasz代码、二进制、离线镜像）均已整理好放入目录`/etc/ansible`

```
# 下载工具脚本easzup，举例使用kubeasz版本2.0.2
export release=2.0.2
curl -C- -fLO --retry 3 https://github.com/easzlab/kubeasz/releases/download/${release}/easzup
chmod +x ./easzup
或者
export release=2.0.2
git clone https://github.com/easzlab/kubeasz/releases/download/${release}/easzup
chmod +x ./easzup

# 使用工具脚本下载
./easzup -D
```

- 4.3 配置集群参数
  - 4.3.1 必要配置：`cd /etc/ansible && cp example/hosts.multi-node hosts`, 然后实际情况修改此hosts文件
  - 4.3.2 可选配置，初次使用可以不做修改，详见[配置指南](https://github.com/easzlab/kubeasz/blob/master/docs/setup/config_guide.md)
  - 4.3.3 验证ansible 安装：`ansible all -m ping` 正常能看到节点返回 SUCCESS
- 4.4 开始安装 如果你对集群安装流程不熟悉，请阅读项目首页 **安装步骤** 讲解后分步安装，并对 **每步都进行验证**

```
# 分步安装
ansible-playbook 01.prepare.yml
ansible-playbook 02.etcd.yml
ansible-playbook 03.docker.yml
ansible-playbook 04.kube-master.yml
ansible-playbook 05.kube-node.yml
ansible-playbook 06.network.yml
ansible-playbook 07.cluster-addon.yml
# 一步安装
#ansible-playbook 90.setup.yml
```

- [可选]对集群所有节点进行操作系统层面的安全加固 `ansible-playbook roles/os-harden/os-harden.yml`，详情请参考[os-harden项目](https://github.com/dev-sec/ansible-os-hardening)



## 四。K8S项目CICD

### 1.CICD流程

![](图片/6.png)

ci/cd demo

1. 开发人员提交代码到 Gitlab 代码仓库
2. 通过 Gitlab 配置的 Jenkins Webhook 触发 Pipeline 自动构建
3. Jenkins 触发构建构建任务，根据 Pipeline 脚本定义分步骤构建
4. 先进行代码静态分析，单元测试
5. 然后进行 Maven 构建（Java 项目）
6. 根据构建结果构建 Docker 镜像
7. 推送 Docker 镜像到 Harbor 仓库
8. 触发更新服务阶段，使用 Helm 安装/更新 Release
9. 查看服务是否更新成功。

### 2、配置jenkins任务

然后新建一个名为`polling-app-server`类型为`流水线(Pipeline)`的任务：

#### 2.1、项目名

![new pipeline task](图片/7.png)new pipeline task

#### 2.2、触发器

然后在这里需要勾选`触发远程构建`的触发器，其中令牌可以随便写一个字符串，然后记住下面的 URL，将 JENKINS_URL 替换成 Jenkins 的地址,这里的地址就是：`http://jenkins.qikqiak.com/job/polling-app-server/build?token=server321`

![trigger](图片/8.png)trigger

#### 2.3、pipline-SCM配置

然后在下面的`流水线`区域可以选择`Pipeline script`然后在下面测试流水线脚本，这里选择`Pipeline script from SCM`，意思就是从代码仓库中通过`Jenkinsfile`文件获取`Pipeline script`脚本定义，然后选择 SCM 来源为`Git`，在出现的列表中配置上仓库地址`http://git.qikqiak.com/course/polling-app-server.git`，由于是在一个 Slave Pod 中去进行构建，所以如果使用 SSH 的方式去访问 Gitlab 代码仓库的话就需要频繁的去更新 SSH-KEY，所以这里采用直接使用用户名和密码的形式来方式：

![pipeline scm](图片/9.png)pipeline scm

#### 2.4、凭据配置

在`Credentials`区域点击`添加`按钮添加访问 Gitlab 的用户名和密码：

![gitlab auth](图片/10.png)gitlab auth

#### 2.5、分支配置

然后需要配置用于构建的分支，如果所有的分支都想要进行构建的话，只需要将`Branch Specifier`区域留空即可，一般情况下不同的环境对应的分支才需要构建，比如 master、develop、test 等，平时开发的 feature 或者 bugfix 的分支没必要频繁构建，这里就只配置 master 和 develop 两个分支用户构建：

![gitlab branch config](图片/11.png)gitlab branch config

#### 2.6、触发器地址

然后前往 Gitlab 中配置项目`polling-app-server` Webhook，settings -> Integrations，填写上面得到的 trigger 地址：

![webhook](图片/12.png)webhook

保存后，可以直接点击`Test` -> `Push Event`测试是否可以正常访问 Webhook 地址，这里需要注意的是需要配置下 Jenkins 的安全配置，否则这里的触发器没权限访问 Jenkins，系统管理 -> 全局安全配置：取消`防止跨站点请求伪造`，勾选上`匿名用户具有可读权限`：

![security config](图片/13.png)security config

如果测试出现了`Hook executed successfully: HTTP 201`则证明 Webhook 配置成功了，否则就需要检查下 Jenkins 的安全配置是否正确了。

配置成功后只需要往 Gitlab 仓库推送代码就会触发 Pipeline 构建了。接下来直接在服务端代码仓库根目录下面添加`Jenkinsfile`文件，用于描述流水线构建流程。首先定义最简单的流程，要注意这里和前面课程的不同之处，这里使用`podTemplate`来定义不同阶段使用的的容器，有哪些阶段呢？

Clone 代码 -> 代码静态分析 -> 单元测试 -> Maven 打包 -> Docker 镜像构建/推送 -> Helm 更新服务。

2.7配置pipline流水线

![](图片/5.png)

##### 第一步，Clone 代码

```shell
stage('Clone') {
    echo "1.Clone Stage"
    git url: "https://github.com/cnych/jenkins-demo.git"
}
```

##### 第二步，测试

git clone https://github.com/cnych/jenkins-demo.git

##### 第三步，构建镜像

```shell
stage('Build') {
    echo "3.Build Docker Image Stage"
    sh "docker build -t cnych/jenkins-demo:${build_tag} ."
}
```

我们平时构建的时候是不是都是直接使用`docker build`命令进行构建就行了，那么这个地方呢？我们上节课给大家提供的 Slave Pod 的镜像里面是不是采用的 `Docker In Docker` 的方式，也就是说我们也可以直接在 Slave 中使用 docker build 命令，所以我们这里直接使用 sh 直接执行 docker build 命令即可，但是镜像的 tag 呢？如果我们使用镜像 tag，则每次都是 latest 的 tag，这对于以后的排查或者回滚之类的工作会带来很大麻烦，我们这里采用和**git commit**的记录为镜像的 tag，这里有一个好处就是镜像的 tag 可以和 git 提交记录对应起来，也方便日后对应查看。但是由于这个 tag 不只是我们这一个 stage 需要使用，下一个推送镜像是不是也需要，所以这里我们把这个 tag 编写成一个公共的参数，把它放在 Clone 这个 stage 中，这样一来我们前两个 stage 就变成了下面这个样子：

```shell
stage('Clone') {
    echo "1.Clone Stage"
    git url: "https://github.com/cnych/jenkins-demo.git"
    script {
        build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    }
}
stage('Build') {
    echo "3.Build Docker Image Stage"
    sh "docker build -t cnych/jenkins-demo:${build_tag} ."
}
```

##### 第四步，推送镜像

镜像构建完成了，现在我们就需要将此处构建的镜像推送到镜像仓库中去，当然如果你有私有镜像仓库也可以，我们这里还没有自己搭建私有的仓库，所以直接使用 docker hub 即可。

> 在后面的课程中我们学习了私有仓库 Harbor 的搭建后，再来更改成 Harbor 仓库

我们知道 docker hub 是公共的镜像仓库，任何人都可以获取上面的镜像，但是要往上推送镜像我们就需要用到一个帐号了，所以我们需要提前注册一个 docker hub 的帐号，记住用户名和密码，我们这里需要使用。正常来说我们在本地推送 docker 镜像的时候，是不是需要使用**docker login**命令，然后输入用户名和密码，认证通过后，就可以使用**docker push**命令来推送本地的镜像到 docker hub 上面去了，如果是这样的话，我们这里的 Pipeline 是不是就该这样写了：

```shell
stage('Push') {
    echo "4.Push Docker Image Stage"
    sh "docker login -u cnych -p xxxxx"
    sh "docker push cnych/jenkins-demo:${build_tag}"
}
```

如果我们只是在 Jenkins 的 Web UI 界面中来完成这个任务的话，我们这里的 Pipeline 是可以这样写的，但是我们是不是推荐使用 Jenkinsfile 的形式放入源码中进行版本管理，这样的话我们直接把 docker 仓库的用户名和密码暴露给别人这样很显然是非常非常不安全的，更何况我们这里使用的是 github 的公共代码仓库，所有人都可以直接看到我们的源码，所以我们应该用一种方式来隐藏用户名和密码这种私密信息，幸运的是 Jenkins 为我们提供了解决方法。在首页点击 Credentials -> Stores scoped to Jenkins 下面的 Jenkins -> Global credentials (unrestricted) -> 左侧的 Add Credentials：添加一个 Username with password 类型的认证信息，如下：

![](图片/14.png)

输入 docker hub 的用户名和密码，ID 部分我们输入**dockerHub**，注意，这个值非常重要，在后面 Pipeline 的脚本中我们需要使用到这个 ID 值。

有了上面的 docker hub 的用户名和密码的认证信息，现在我们可以在 Pipeline 中使用这里的用户名和密码了：

```shell
stage('Push') {
    echo "4.Push Docker Image Stage"
    withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
        sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
        sh "docker push cnych/jenkins-demo:${build_tag}"
    }
}

stage(k8s-master)
      image-new=jenkins-demo:${build_tag};
      sad -i s/image/image-new/k8s1.yaml
    
```

注意我们这里在 stage 中使用了一个新的函数**withCredentials**，其中有一个`credentialsId`值就是我们刚刚创建的 ID 值，然后我们就可以在脚本中直接使用这里两个变量值来直接替换掉之前的登录 docker hub 的用户名和密码，现在是不是就很安全了，我只是传递进去了两个变量而已，别人并不知道我的真正用户名和密码，只有我们自己的 Jenkins 平台上添加的才知道。

##### 第五步，更改 YAML

上面我们已经完成了镜像的打包、推送的工作，接下来我们是不是应该更新 Kubernetes 系统中应用的镜像版本了，当然为了方便维护，我们都是用 YAML 文件的形式来编写应用部署规则，比如我们这里的 YAML 文件：(k8s.yaml)

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: jenkins-demo
spec:
  template:
    metadata:
      labels:
        app: jenkins-demo
    spec:
      containers:
      - image: cnych/jenkins-demo:<BUILD_TAG>
        imagePullPolicy: IfNotPresent
        name: jenkins-demo
```

对于 Kubernetes 比较熟悉的同学，对上面这个 YAML 文件一定不会陌生，我们使用一个 Deployment 资源对象来管理 Pod，该 Pod 使用的就是我们上面推送的镜像，唯一不同的地方是 Docker 镜像的 tag 不是我们平常见的具体的 tag，而是一个 的标识，实际上如果我们将这个标识替换成上面的 Docker 镜像的 tag，是不是就是最终我们本次构建需要使用到的镜像？怎么替换呢？其实也很简单，我们使用一个**sed**命令就可以实现了：

```shell
stage('YAML') {
    echo "5. Change YAML File Stage"
    sh "sed -i 's/<BUILD_TAG>/${build_tag}/' k8s.yaml"
}
```

上面的 sed 命令就是将 k8s.yaml 文件中的 标识给替换成变量 build_tag 的值。

##### 第六步，部署

Kubernetes 应用的 YAML 文件已经更改完成了，之前我们手动的环境下，是不是直接使用 kubectl apply 命令就可以直接更新应用了啊？当然我们这里只是写入到了 Pipeline 里面，思路都是一样的：

```shell
stage('Deploy') {
    echo "6. Deploy Stage"
    sh "kubectl apply -f k8s.yaml"
}
```

这样到这里我们的整个流程就算完成了。我们最终的 Pipeline 脚本如下：

```shell
node('haimaxy-jnlp-docker') {
    stage('Clone') {
        echo "1.Clone Stage"
        git url: "https://github.com/cnych/jenkins-demo.git"
        script {
            build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
        }
    }
    stage('Test') {
      echo "2.Test Stage"
    }
    stage('Build') {
        echo "3.Build Docker Image Stage"
        sh "docker build -t cnych/jenkins-demo:${build_tag} ."
    }
    stage('Push') {
        echo "4.Push Docker Image Stage"
        withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
            sh "docker push cnych/jenkins-demo:${build_tag}"
        }
    }
node('k8s-master')     
    stage('Deploy') {
    echo "6. Deploy Stage"
    image-new=jenkins-demo:${build_tag};
    sh sad -i s/image/image-new/k8s1.yaml    
    sh "kubectl apply -f k8s1.yaml"
}
```

现在我们在 Jenkins Web UI 中重新配置 jenkins-demo 这个任务，将上面的脚本粘贴到 Script 区域，重新保存，然后点击左侧的 Build Now，触发构建，然后过一会儿我们就可以看到 Stage View 界面出现了暂停的情况：

![](图片/15.png)



```shell
$ kubectl get deployment -n kube-ops
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
jenkins        1         1         1            1           7d
jenkins-demo   1         1         1            0           1m
$ kubectl get pods -n kube-ops
NAME                           READY     STATUS      RESTARTS   AGE
jenkins-7c85b6f4bd-rfqgv       1/1       Running     4          7d
jenkins-demo-f6f4f646b-2zdrq   0/1       Completed   4          1m
$ kubectl logs jenkins-demo-f6f4f646b-2zdrq -n kube-ops
Hello, Kubernetes！I'm from Jenkins CI！
```

我们可以看到我们的应用已经正确的部署到了 Kubernetes 的集群环境中了。