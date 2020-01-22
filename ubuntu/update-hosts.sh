#!/bin/bash

cat >> /etc/hosts <<EOF

192.168.5.101  kube-master-1
192.168.5.102  kube-master-2
192.168.5.201  kube-worker-1
192.168.5.202  kube-worker-2
192.168.5.50   kube-lb
EOF
