#!/bin/bash

control_node=""

while [ -z "$control_node" ]; do
    read -p "Would you like this to be a control node? (y/n) " yn
    case $yn in
        [Yy]* ) control_node="yes";;
        [Nn]* ) control_node="no";;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ "$control_node" = "no" ]; then
    read -p "Please provide the join string printed from your control-node: " join_str
fi

wget https://go.dev/dl/go1.21.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.profile
source ~/.profile
git clone https://github.com/Mirantis/cri-dockerd.git
pushd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket
popd
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
if [ "$join_str" != "" ]; then
sudo kubeadm $join_str --cri-socket /var/run/cri-dockerd.sock
    exit
fi
sudo apt-mark hold kubelet kubeadm kubectl
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config