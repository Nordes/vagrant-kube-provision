#/bin/bash
echo "Adding kube user" 
useradd -m -s /bin/bash -U kube -u 666 --groups docker
cp -pr /home/vagrant/.ssh /home/kube/
cp -pr /home/vagrant/.bashrc /home/kube/
mkdir -p /home/kube/.kube
cp /etc/kubernetes/admin.conf /home/kube/.kube/config
cat >> /home/kube/.bashrc << 'EOF'
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
EOF

chown -R kube:kube /home/kube
echo "%kube ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/kube
