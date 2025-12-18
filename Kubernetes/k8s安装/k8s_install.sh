#!/bin/bash

# 变量声明

MASTER01_IP="192.168.140.129"
WORKER01_IP="192.168.140.130"
WORKER02_IP="192.168.140.131"
POD_NETWORK_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"
HOSTS_FILE="/etc/hosts.bak.$(date +%Y%m%d%H%M%S)"
FSTAB_BACKUP_FILE="/etc/fstab.backup.$(date +%Y%m%d%H%M%S)"
CHRONY_BACKUP_FILE="/etc/chrony/chrony.conf.backup.$(date +%Y%m%d%H%M%S)"

K8S_VERSION="1.33.6"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "请使用 sudo 或以 root 用户运行此脚本"
        exit 1
    fi
}

# 系统环境准备
setup_basic() {

    print_info "配置基础环境..."
    
    #设置hosts
    cp /etc/hosts "$HOSTS_FILE"
    cat >> /etc/hosts << EOF 
$MASTER01_IP k8s-master01
$WORKER01_IP k8s-worker01
$WORKER02_IP k8s-worker02
EOF
    
    # 关闭 swap
    # 禁用 swap
    log_info "禁用 swap..."
    swapoff -a
    if grep -q swap /etc/fstab; then
        cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d%H%M%S)"
        sed -i '/swap/s/^/#/' /etc/fstab
    fi
    
    # 关闭防火墙
    log_info "禁用防火墙..."
    ufw disable 2>/dev/null || true
    systemctl stop ufw 2>/dev/null || true
    systemctl disable ufw 2>/dev/null || true
    
    
    log_info "设置时区..."
    apt-get install -y chrony 2>/dev/null || true
    cp /etc/chrony/chrony.conf "$CHRONY_BACKUP_FILE"
    sed -i '/^server /d' /etc/chrony/chrony.conf
    sed -i '/^pool /d' /etc/chrony/chrony.conf
    sed -i '1 a\\n# 阿里云 NTP 服务器配置\nserver ntp1.aliyun.com iburst\nserver ntp2.aliyun.com iburst\nserver ntp3.aliyun.com iburst' /etc/chrony/chrony.conf
    systemctl enable chrony
    systemctl restart chrony
    
    log_info "设置时间同步..."
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    
    # 系统依赖包
    apt-get install -y conntrack ipvsadm ipset jq iptables curl sysstat wget vim net-tools git
    
    # 开启ipvs转发
    modprobe br_netfilter
    modprobe bridge
    
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
    
    # 内核参数
    cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_syncookies = 1
vm.swappiness = 0
vm.overcommit_memory = 1
vm.panic_on_oom = 0
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
fs.file-max = 52706963
fs.nr_open = 52706963
net.ipv6.conf.all.disable_ipv6 = 1
net.netfilter.nf_conntrack_max = 2310720
EOF

    sysctl -p /etc/sysctl.d/k8s.conf

}

# 安装软件包和加载内核模块
install_containerd() {
    
    #下载containerd
    wget https://github.com/containerd/containerd/releases/download/v1.7.28/cri-containerd-cni-1.7.28-linux-amd64.tar.gz
    
    tar -zxvf cri-containerd-cni-1.7.28-linux-amd64.tar.gz -C /
    
    # 生成配置文件
    mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml
    
    # 修改containerd的配置文件
    sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
     
    old_image='sandbox_image = "registry.k8s.io/pause:3.8"'
    new_image='sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.10"'
    sed -i "s|$old_image|$new_image|" /etc/containerd/config.toml
    
    sed -i '/\[plugins\."io\.containerd\.grpc\.v1\.cri"\.registry\]/{n;s/.*/      config_path = "\/etc\/containerd\/certs.d"/;}' /etc/containerd/config.toml
    
    # 配置镜像加速
    mkdir /etc/containerd/certs.d/docker.io -pv
    
    cat > /etc/containerd/certs.d/docker.io/host.toml << EOF
server = "htpps://docker.1panel.live"
[host."https://docker.m.daocloud.io"]
  capabilities = ["pull", "recolve"]
EOF

    # 设置containerd开机自启动
    systemctl enable containerd
    systemctl start containerd
    
    # 加载containerd所需的内核模块
    cat > /etc/modules-load.d/containerd.conf << EOF 
overlay
br_netfilter
EOF
    
    modprobe overlay
    modprobe br_netfilter

}

# 安装k8s工具
install_k8s() {
    
    # 安装下载工具
    apt-get update && apt-get install -y apt-transport-https
    
    
    curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
    
    # 安装kubelet kubeadm kubectl
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    # 锁定版本
    apt-mark hold kubelet kubeadm kubectl
    
    # 查看版本信息
    # apt-cache policy kubeadm
    # 查看依赖信息
    # apt-cache showpkg kubeadm
    # 查看软件版本
    # apt-cache madison kubeadm
    
    echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"' > /etc/sysconfig/kubelet
    
    systemctl enable kubelet
    
    # 查看kubernetes的安装列表
    # kubeadm config images list --kubernetes-version=v1.33.6
    
    # 下载kubernetes的镜像
    kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers
    
    # 查看下载镜像
    # ctr -n k8s.io images ls
    # crictl image ls
    
    # 初始化kubernetes
    kubeadm init --kubernetes-version=$K8S_VERSION --pod-network-cidr=$POD_NETWORK_CIDR --service-cidr=$SERVICE_CIDR --apiserver-advertise-address=$MASTER01_IP --image-repository registry.aliyuncs.com/google_containers --cri-socket=unix:///run/containerd/containerd.sock
    
    # 去除k8s的控制面污点
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
}

install_cilium(){
   
    # 安装helm
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    
    # 添加cilium仓库
    helm repo add cilium https://helm.cilium.io/
    ß
    # 安装cilium网络插件
    helm install cilium cilium/cilium --version 1.18.4 --namespace kube-system
}

install_ceph(){

    # 查看磁盘
    lsblk -f

    # 清除文件系统
    wipefs --all --force /dev/sda*
    
    # 下载rook-ceph仓库
    git clone --single-branch --branch v1.18.8 https://github.com/rook/rook.git
    
    # 安装ceph
    cd rook/deploy/examples
    kubectl create -f crds.yaml -f common.yaml -f csi-operator.yaml -f operator.yaml
    
    kubectl create -f cluster.yaml
    
    kubectl create -f toolbox.yaml
    
    
}

# 主函数
main() {
    check_root
    
    log_step "开始安装 Kubernetes Master 节点 (v$K8S_VERSION) with Cilium..."
    
    # 执行安装步骤
    setup_basic
    install_containerd
    install_k8s
    install_cilium
    install_ceph
}

# 捕获中断信号
trap 'log_error "安装被中断"; exit 1' INT TERM

main "$@"




    

