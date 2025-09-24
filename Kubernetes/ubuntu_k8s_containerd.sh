# 安装containerd
apt update && apt install -y containerd

# 查看containerd的版本
containerd -v

# 生成配置文件
mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml

# 修改/etc/containerd/config.toml文件中的内容
SystemdCgroup = false 改为 true
sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.10"

[plugins."io.containerd.grpc.v1.cri".registry.mirrors]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]
endpoint = ["registry.aliyuncs.com/google_containers"]

# 下载用于k8s软件包仓库的公共签名密钥。所有仓库都使用相同的签名密钥，因此你可以忽略URL中的版本
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                                                                                 signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg                      

# 添加k8s apt仓库。请注意，此仓库仅包含适用于k8s 1.32的软件包；对于其他k8s次要版本，则需要更改URL中的k8s次要
# 版本以匹配所需的次要版本（你还应该检查正在阅读的安装文档是否为你计划安装的k8s版本的文档）
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 更新apt包索引，安装kubelet、kubeadm和kubectl，并锁定其版本：
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadmin kubectl

# 设置开机启动
systemctl enable --now kubelet

# 查看版本
kubeadm version

# 主节点初始化
kubeadm init --apiserver-advertise-address=172.27.87.98 --image-repository registry.aliyuncs.com/google_containers --control-plane-endpoint=k8s-master --kubernetes-version v1.32.9 --service-cidr=10.50.0.0/16 --pod-network-cidr=10.60.0.0/16 --cri-socket=unix:///run/containerd/containerd.sock
