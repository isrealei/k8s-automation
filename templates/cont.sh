#!/bin/bash
sudo apt update
sudo swapoff -a


# prerequsite for installing container runtime 

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# installing container runtime

wget https://github.com/containerd/containerd/releases/download/v1.6.2/containerd-1.6.2-linux-amd64.tar.gz

sudo tar Czxvf /usr/local containerd-1.6.2-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

sudo mv containerd.service /usr/lib/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.1.1/runc.amd64

sudo install -m 755 runc.amd64 /usr/local/sbin/runc

sudo mkdir -p /etc/containerd/

containerd config default | sudo tee /etc/containerd/config.toml


sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
