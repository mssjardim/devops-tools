# Ubuntu 16.04
```sh
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common vim
```

# Install Docker 18.06
```sh
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get update
apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu
```

# Load modules
```sh
vim /etc/modules-load.d/k8s.conf
br_netfilter
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
ip_vs
# save and close
```

```sh
vim /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
# save and close
```

```sh
modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs
sysctl --system
```

# Install Kubernetes
```sh
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
```

# define same cgroup between kubernetes and docker
```sh
sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet
```

# Turn off swap
```sh
swapoff -a

vim /etc/fstab
# comment swap line save and close /etc/fstab
```

# Initialize Cluster (only in node master)
```sh
kubeadm init --apiserver-advertise-address $(hostname -i)

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network addons
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

# Join Works (only in nodes works)
```sh
kubeadm join --token 39c341.a3bc3c4dd49758d5 IP_OF_MASTER:6443 --discovery-token-ca-cert-hash sha256:37092 
```

# Install Weave Scope
```sh
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get services -n weave
```
