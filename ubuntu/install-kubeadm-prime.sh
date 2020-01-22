#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo kubeadm init --control-plane-endpoint kube-lb --apiserver-advertise-address $1 --pod-network-cidr=192.168.0.0/16 --upload-certs --service-dns-domain kube.local > $2/kubeadm-install.log
sudo mkdir /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo mkdir /home/vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

sleep 10
sudo kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

sudo grep 'kubeadm\ join' $2/kubeadm-install.log -A 2 -m 1  > $2/kubeadm-master.sh
sudo sed -i '1 i\#/bin/bash' $2/kubeadm-master.sh
sudo sed -i.bck '$s/$/ \\/' $2/kubeadm-master.sh
sudo cat << EOF >> $2/kubeadm-master.sh
--apiserver-advertise-address \$1
EOF

sudo chmod +x $2/kubeadm-master.sh
