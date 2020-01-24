#!/bin/bash

sudo apt update
sudo apt -y install haproxy

cat << EOF >> /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Configure HAProxy for Kubernetes API Server
#---------------------------------------------------------------------

listen stats
  bind    *:9000
  mode    http
  stats   enable
  stats   hide-version
  stats   uri       /stats
  stats   refresh   30s
  stats   realm     Haproxy\ Statistics
  stats   auth      Admin:Password

############## Configure HAProxy Secure Frontend #############
frontend k8s-api-https-proxy
    bind :6443
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    default_backend k8s-api-https

############## Configure HAProxy SecureBackend #############
backend k8s-api-https
    balance roundrobin
    mode tcp
    option tcplog
    option tcp-check
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-master-1 192.168.5.101:6443 check
    server kube-master-2 192.168.5.102:6443 check

############## Configure HAProxy Secure Frontend #############
frontend k8s-api-http-proxy-nginx-ingress
    bind :80
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    default_backend k8s-api-http-nginx-ingress

############## Configure HAProxy SecureBackend #############
backend k8s-api-http-nginx-ingress
    balance roundrobin
    mode tcp
    option tcplog
    option tcp-check
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-worker-1 192.168.5.201:32014 check
    server kube-worker-2 192.168.5.202:32014 check

############## Configure HAProxy Secure Frontend #############
frontend k8s-api-https-proxy-nginx-ingress
    bind :443
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    default_backend k8s-api-https-nginx-ingress

############## Configure HAProxy SecureBackend #############
backend k8s-api-https-nginx-ingress
    balance roundrobin
    mode tcp
    option tcplog
    option tcp-check
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-worker-1 192.168.5.201:32015 check
    server kube-worker-2 192.168.5.202:32015 check

############## Configure HAProxy Unsecure Frontend #############
#frontend k8s-api-http-proxy
#    bind :80
#    mode tcp
#    option tcplog
#    default_backend k8s-api-http

############## Configure HAProxy Unsecure Backend #############
#backend k8s-api-http
#    mode tcp
#    option tcplog
#    option tcp-check
#    balance roundrobin
#    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
#    server k8s-api-1 192.168.1.101:8080 check
#    server k8s-api-2 192.168.1.102:8080 check
#    server k8s-api-3 192.168.1.103:8080 check
EOF

haproxy -c -V -f /etc/haproxy/haproxy.cfg
systemctl restart haproxy

