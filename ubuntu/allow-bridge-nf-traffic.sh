#!/bin/bash

cat << EOF >> /etc/sysctl.conf

# Allow ip tables
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF

# sysctl net.bridge.bridge-nf-call-iptables=1
modprobe br_netfilter
sudo sysctl -p
