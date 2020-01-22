# vi: set ft=ruby :

n = 2

# Should do a dictionary/hash https://docs.ruby-lang.org/en/2.0.0/Hash.html
NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2
IP_NW = "192.168.5."
MASTER_IP_START = 100
NODE_IP_START = 200
LB_IP_START = 50
SHARED_HOST_LOGS_FOLDER = "./logs/"
SHARED_VM_LOGS_FOLDER = "/opt/kubeadm/logs/"


Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  config.vm.box = "ubuntu/bionic64"
 
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
      loadbalancer.vm.network "forwarded_port", guest: 22, host: 2730    

    loadbalancer.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
    loadbalancer.vm.provision "setup-haproxy", type: "shell", :path => "ubuntu/install-haproxy.sh"

    loadbalancer.vm.network "forwarded_port", guest: 9000, host: 9000
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
        node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"

        node.vm.provision "allow-bridge-nf-traffic", :type => "shell", :path => "ubuntu/allow-bridge-nf-traffic.sh"
        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/update-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.synced_folder "#{SHARED_HOST_LOGS_FOLDER}", "#{SHARED_VM_LOGS_FOLDER}", create: true, group: "root", owner: "root"
        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/install-docker.sh"
        node.vm.provision "setup-kubeadm", type: "shell", :path => "ubuntu/install-kubeadm.sh"

      end
  end

  config.vm.define "kube-master-1" do |prime|
      prime.vm.provision "setup-cluster", type: "shell", :path => "ubuntu/install-kubeadm-prime.sh" do |s|
        s.args = [IP_NW + "#{MASTER_IP_START + 1}", "#{SHARED_VM_LOGS_FOLDER}"]
      end
  end


  ###################################################
  # Provision Worker Nodes
#  (1..NUM_WORKER_NODE).each do |i|
#    config.vm.define "worker-#{i}" do |node|
#        node.vm.provider "virtualbox" do |vb|
#            vb.name = "kube-worker-#{i}"
#            vb.memory = 512
#            vb.cpus = 1
#        end
#        node.vm.hostname = "kube-worker-#{i}"
#        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
#		node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

#        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/update-hosts.sh" do |s|
#          s.args = ["enp0s8"]
#        end

#        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
#        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/install-docker.sh"
#        node.vm.provision "allow-bridge-nf-traffic", :type => "shell", :path => "ubuntu/allow-bridge-nf-traffic.sh"

#    end
#  end


# for worker: node.vm.provision "allow-bridge-nf-traffic", :type => "shell", :path => "ubuntu/allow-bridge-nf-traffic.sh"

#  n.times do |i|
#    config.vm.define "app-#{i+1}" do |app|
#      app.vm.box = 'deryrahman/rails-minimal'
#      app.vm.hostname = "app-#{i+1}"
#      app.vm.network :private_network, ip: "192.168.10.#{10+i+1}"
#    end
#  end
end
