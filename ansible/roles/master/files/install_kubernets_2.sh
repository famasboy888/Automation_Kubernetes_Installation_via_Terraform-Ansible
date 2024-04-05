#!/bin/bash

sudo kubeadm config images pull --cri-socket /run/cri-dockerd.sock --image-repository registry-1.docker.io/famasboy888 --kubernetes-version 1.29.3

sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-cert-extra-sans 192.168.2.225,192.168.2.172 --cri-socket /run/cri-dockerd.sock


sudo mkdir -p /root/.kube
echo 'y' | sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
