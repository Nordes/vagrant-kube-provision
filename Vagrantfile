# vi: set ft=ruby :

n = 2

# Should do a dictionary/hash https://docs.ruby-lang.org/en/2.0.0/Hash.html
NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2
IP_NW = "192.168.5."
MASTER_IP_START = 100
NODE_IP_START = 200
LB_IP_START = 50
SHARED_KUBE_FOLDER = "./shared-vm-folder/"
SHARED_VM_KUBE_FOLDER = "/opt/k8s-cluster/shared/"

def add_basenode_settings(node, ipEnd)
        node.vm.synced_folder "#{SHARED_KUBE_FOLDER}", "#{SHARED_VM_KUBE_FOLDER}", create: true, group: "root", owner: "root"
        node.vm.network :private_network, ip: IP_NW + "#{ipEnd}"
        node.vm.network "forwarded_port", guest: 22, host: "#{4000 + ipEnd}"

        node.vm.provision "allow-bridge-nf-traffic", :type => "shell", :path => "ubuntu/base/allow-bridge-nf-traffic.sh"
        node.vm.provision "setup-hosts",             :type => "shell", :path => "ubuntu/base/update-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.provision "setup-dns",      type: "shell", :path => "ubuntu/base/update-dns.sh"
#        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/k8s-base/install-k8s-req.sh"
        node.vm.provision "setup-ip-route", type: "shell", :path => "ubuntu/k8s-base/setup-ip-route.sh" do |s|
          s.args = [IP_NW + "#{ipEnd}"]
        end
end

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  #config.vm.box = "ubuntu/bionic64"
  config.vm.box = "Slach/kubernetes-docker"

  # config.ssh.username = "kube"
  # consig.ssh.password = "kube"
 
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  ###################################################

  config.vm.define "kube-lb" do |loadbalancer|
    loadbalancer.vm.provider "virtualbox" do |vb|
        vb.name = "kube-lb"
        vb.memory = 512
        vb.cpus = 1
    end

    loadbalancer.vm.box = 'ubuntu/bionic64'
    loadbalancer.vm.hostname = "kube-lb"
    loadbalancer.vm.network :private_network, ip: IP_NW + "#{LB_IP_START}"
    loadbalancer.vm.network "forwarded_port", guest: 22, host: 2701    

    loadbalancer.vm.provision "setup-dns",     type: "shell", :path => "ubuntu/base/update-dns.sh"
    loadbalancer.vm.provision "setup-haproxy", type: "shell", :path => "ubuntu/loadbalancer/install-haproxy.sh"

    loadbalancer.vm.network "forwarded_port", guest: 9000, host: 9000
    loadbalancer.vm.network "forwarded_port", guest: 6443, host: 6443
    loadbalancer.vm.network "forwarded_port", guest: 443, host: 443
    loadbalancer.vm.network "forwarded_port", guest: 80, host: 80
  end

  ###################################################
  # Provision Master Nodes
  (1..NUM_MASTER_NODE).each do |i|
      config.vm.define "kube-master-#{i}" do |node|
        # Name shown in the GUI
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kube-master-#{i}"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kube-master-#{i}"
        add_basenode_settings node, MASTER_IP_START + i

      end
  end

  config.vm.define "kube-master-1" do |prime|
      prime.vm.provision "setup-cluster", type: "shell", :path => "ubuntu/k8s-master/install-kubeadm-prime.sh" do |s|
        s.args = [IP_NW + "#{MASTER_IP_START + 1}", "#{SHARED_VM_KUBE_FOLDER}"]
      end
      
      # Need to do ip route stuff if we use the weave, otherwise with flannel: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#vagrant
      prime.vm.provision "setup-weave-cni", type: "shell",     :path => "ubuntu/k8s-master/install-weave-cni.sh"
      prime.vm.provision "setup-nginx-ingress", type: "shell", :path => "ubuntu/k8s-master/install-nginx-ingress.sh"
  end

  (2..NUM_MASTER_NODE).each do |i|
      config.vm.define "kube-master-#{i}" do |master|
        master.vm.provision "shell" do |s|
           s.inline = "/bin/bash #{SHARED_VM_KUBE_FOLDER}kubeadm-master.sh #{IP_NW}#{MASTER_IP_START + i}"
        end
      end
  end

  ###################################################
  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "kube-worker-#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kube-worker-#{i}"
            vb.memory = 2024
            vb.cpus = 1
        end
        node.vm.hostname = "kube-worker-#{i}"

        add_basenode_settings node, NODE_IP_START + i

        node.vm.provision "shell" do |s|
           s.inline = "/bin/bash #{SHARED_VM_KUBE_FOLDER}kubeadm-node.sh"
        end
    end
  end

end
