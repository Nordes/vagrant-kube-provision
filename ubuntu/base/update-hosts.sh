#!/bin/bash

set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

cat >> /etc/hosts <<EOF

192.168.5.101  kube-master-1
192.168.5.102  kube-master-2
192.168.5.201  kube-worker-1
192.168.5.202  kube-worker-2
192.168.5.50   kube-lb
EOF
