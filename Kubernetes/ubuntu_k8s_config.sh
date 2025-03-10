# 本地DNS
192.168.8.8 k8s-master01 k8s-master01
192.168.8.9 k8s-worker01 k8s-worker01
192.168.8.10 k8s-worker02 k8s-worker02
192.168.8.11 k8s-worker03 k8s-worker03


# 安装chrony
apt-get update
apt-get install chrony

# chonry时间同步 vi /etc/chrony/chrony.conf
server ntp1.aliyun.com iburst

# 时间同步
ln -sf /usr/share/zoneinfo/Asia/Shanghai > /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

# 重启时间同步服务
systemctl start chronyd


# 关闭防火墙
service ufw stop
update-rc.d ufw defaults-disabled


# 关闭swap
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

# 系统优化
cat > /etc/sysctl.d/k8s_better.conf << EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF
modprobe br_netfilter
lsmod | grep conntrack
modprobe ip_conntrack
sysctl -p /etc/sysctl.d/k8s_better.conf

# 系统依赖包
apt-get install -y conntrack ipvsadm ipset jq iptables curl sysstat wget vim net-tools git

# 开启ipvs转发
modprobe br_netfilter

mkdir -p /etc/sysconfig/modules
cat > /etc/sysconfig/modules/ipvs.modules << EOF

#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules

bash /etc/sysconfig/modules/ipvs.modules

lsmod | grep -e ip_vs -e nf_conntrack

# 安装docker
# 安装系统依赖
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

# 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce 

# 创建docker配置文件
mkdir -p /etc/docker

# 配置docker
cat > /etc/docker/daemon.json << EOF
{
	"exec-opts":["native.cgroupdriver=systemd"],
	"registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
	],
	"max-concurrent-downloads": 10,
	"log-level": "warn",
	"log-opts": {
		"max-size": "10m",
		"max-file": "3"
	},
	"data-root": "/var/lib/docker"
}
EOF

# 启动docker-ce
service docker restart
update-rc.d docker defaults

# 安装cri-dockerd
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd-0.3.15.amd64.tgz

tar -zxvf cri-dockerd-0.3.15.amd64.tgz

cp cri-dockerd/cri-dockerd /usr/bin
chmod +x /usr/bin/cri-dockerd

# 写入启动配置文件
cat > /etc/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

StartLimitBurst=3

StartLimitInterval=60s

LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# 写入socket配置文件
cat > /etc/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SockerGroup=docker

[Install]
WantedBy=sockets.target
EOF

# 进行启动cri-docker
systemctl daemon-reload; systemctl enable cri-docker --now

# 安装k8s 1.30
apt-get update && apt-get install -y apt-transport-https

curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl

# 关闭自动更新
apt-mark hold kubelet kubeadm kubectl

# 修改cgroup-driver
vi /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"

# 设置kubelet为开机自启动即可，由于没有生成配置文件，集群初始化自动启动
systemctl enable kubelet

# 准备k8s 1.30所需要的镜像
kubeadm config images list --kubernetes-version=v1.30.6

# 下载镜像
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers --cri-socket=unix:///var/run/cri-dockerd.sock

# kubeadm初始化
kubeadm init --kubernetes-version=v1.30.6 --pod-network-cidr=10.223.0.0/16 --apiserver-advertise-address=192.168.8.8 --image-repository registry.aliyuncs.com/google_containers --cri-socket=unix:///var/run/cri-dockerd.sock

kubeadm join 192.168.1.8:6443 --token zqgjjd.qoj64eq66p3uk74r \
	--discovery-token-ca-cert-hash sha256:d4370a069807877a1f8b56393d0c6de5c65d3288d308bcdaf0db3205873e7072 --cri-socket=unix:///var/run/cri-dockerd.sock

# 下载cilium
# wget https://github.com/cilium/cilium-cli/releases/download/v0.16.19/cilium-linux-amd64.tar.gz
# tar -zxvf cilium-linux-amd64.tar.gz
# mv cilium /usr/bin/

# 下载helm
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar -zxvf helm-v3.16.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/

helm repo add cilium https://helm.cilium.io/
helm repo add harbor  https://helm.goharbor.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add gitlab https://charts.gitlab.io/

helm install cilium cilium/cilium --version 1.16.3 --namespace kube-system

helm upgrade cilium cilium/cilium --version 1.16.3 --namespace kube-system \
   --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true

# 启动本地路由
helm upgrade cilium cilium/cilium --version 1.16.3 --namespace kebe-system \
  -- reuse-values \
  -- set tunnel=disabled \
  --set autoDirectNodeRoutes=true \
  --set ipv4NativeRoutingCIDR=10.0.0.0/22

# 安装gitlab
helm upgrade --install gitlab gitlab/gitlab --version 8.5.1 --namespace gitlab-system\
  --timeout 600s \
  --set global.hosts.domain=gitlab.local.com \
  --set global.hosts.externalIP=192.168.8.8 \
  --set certmanager-issuer.email=guangyongluo@outlook.com

# 安装nfs服务
sudo apt update
sudo apt install nfs-kernel-server

mkdir -p /data/nfs

chown nobody:nogroup /data/nfs

vi /etc/exports

/data/nfs 192.168.8.0/24(rw,sync,no_subtree_check)

sudo exportfs -ra
sudo systemctl restart nfs-kernel-server

# 安装nfs-common工具包
sudo apt update
sudo apt install nfs-common

mkdir -p /mnt/nfs
mount 192.168.8.12:/data/nfs /mnt/nfs

# 安装nfs-client-provisioner
helm repo add https://charts.kubesphere.io/main

helm pull kubesphere/nfs-client-provisioner --version=4.0.11

vi nfs-client-provisioner/values.yaml

kubectl create ns kubesphere

helm install nfs-client ./nfs-client-provisioner -namespace kubesphere

# 安装harbor, 在所有worker节点导入harbor所需的镜像
mv /home/vagrant/harbor-offline-installer-v2.12.0.tgz ./harbor

cd ./harbor/

docker load -i ./harbor/harbor.v2.12.0.tar.gz


# 在master节点开始安装harbor
kubectl create ns harbor

mkdir harbor

cd harbor



# 安装gitlab
kubectl create ns gitlab

helm repo update



