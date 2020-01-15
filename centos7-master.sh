#!/bin/bash
sysctl net.bridge.bridge-nf-call-iptables=1
yum update -y
yum install -y docker-ce docker-ce-cli containerd.io

update-alternatives --set iptables /usr/sbin/iptables-legacy
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd --permanent --add-port=6783-6784/udp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250-10252/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
#  "insecure-registries": ["ip/subnet", "name:port"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl enable docker
systemctl start docker

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

lsmod | grep br_netfilter

modprobe br_netfilter

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm config images pull
kubeadm init
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
wget https://get.helm.sh/helm-v3.0.0-rc.3-linux-amd64.tar.gz
tar -xzf helm-v3.0.0-rc.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
rm -f helm-v3.0.0-rc.3-linux-amd64.tar.gz
