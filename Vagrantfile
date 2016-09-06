# -x- mode: ruby -x-
# vi: set ft=ruby :

boxes = [
    {
        :name => "controller",
        :mgmt_ip => "10.0.0.11",
        :hostname => "controller.example.com",
    },
    {
        :name => "network",
        :mgmt_ip => "10.0.0.21",
        :tunnel_ip => "10.0.1.21",
        :hostname => "network.example.com",
    },
    {
        :name => "compute1",
        :mgmt_ip => "10.0.0.31",
        :tunnel_ip => "10.0.1.31",
        :data_ip => "10.0.2.31",
        :hostname => "compute1.example.com",
    },
    {
        :name => "compute2",
        :mgmt_ip => "10.0.0.32",
        :tunnel_ip => "10.0.1.32",
        :data_ip => "10.0.2.32",
        :hostname => "compute2.example.com",
    },
    {
        :name => "block1",
        :mgmt_ip => "10.0.0.41",
        :data_ip => "10.0.2.41",
        :hostname => "block1.example.com",
    },
    {
        :name => "object1",
        :mgmt_ip => "10.0.0.51",
        :data_ip => "10.0.2.51",
        :hostname => "object1.example.com",
    },
    {
        :name => "object2",
        :mgmt_ip => "10.0.0.52",
        :data_ip => "10.0.2.52",
        :hostname => "object2.example.com",
    },
    {
        :name => "share1",
        :mgmt_ip => "10.0.0.61",
        :data_ip => "10.0.2.61",
        :hostname => "share1.example.com",
    },
    {
        :name => "share2",
        :mgmt_ip => "10.0.0.62",
        :data_ip => "10.0.2.62",
        :hostname => "share2.example.com",
    },
]


Vagrant.configure(2) do |config|
  boxes.each do |opts|
    config.vm.define opts[:name] do |box|
      box.vm.box = "centos/7"
      box.vm.hostname = opts[:hostname]
      box.vm.provision :shell, path: "bootstrap.sh"

      if opts[:name] == 'controller'
         box.vm.network :private_network, :ip => opts[:mgmt_ip]
      end


      if opts[:name] == 'network'
         box.vm.network :private_network, :ip => opts[:mgmt_ip]
         box.vm.network :private_network, :ip => opts[:tunnel_ip]
      end

      if opts[:name] == 'compute1'  ||  opts[:name] == 'compute2'
         box.vm.network :private_network, :ip => opts[:mgmt_ip]
         box.vm.network :private_network, :ip => opts[:tunnel_ip]
         box.vm.network :private_network, :ip => opts[:data_ip]
      end

      if opts[:name] == 'block1' || opts[:name] == 'object1'
         box.vm.network :private_network, :ip => opts[:mgmt_ip]
         box.vm.network :private_network, :ip => opts[:data_ip]
      end

      box.vm.provider :libvirt do |lv|
        lv.uri = 'qemu+unix:///system'
        lv.driver = 'kvm'
        lv.storage_pool_name = 'default'
        #controller
        if opts[:name] == 'controller'  
          lv.memory = 4096
          lv.cpus = 4
          lv.storage :file, :size => '30G', :type => 'raw'
        end
        if opts[:name] == 'compute1'  ||  opts[:name] == 'compute2' 
          lv.memory = 8192
          lv.driver = 'kvm'
          lv.cpu_mode = 'host-passthrough'
          lv.nested = true
          lv.cpus = 8
        end
        #neutron node
        if opts[:name] == 'network'  
          lv.memory = 2048
          lv.cpus = 1
        end
        #cinder node
	if opts[:name] == 'block1' 
	  lv.memory = 2048
          lv.cpus = 1
          lv.storage :file, :size => '20G'
          lv.storage :file, :size => '20G'
        end
        #swift node
	if opts[:name] == 'object1' || opts[:name] == 'object2'
	        lv.memory = 2048
          lv.cpus = 1
          lv.storage :file, :size => '20G'
          lv.storage :file, :size => '20G'
          lv.storage :file, :size => '20G'
        end
        #manila node
	if opts[:name] == 'share1' || opts[:name] == 'share2'
	  lv.memory = 2048
          lv.cpus = 1
          lv.storage :file, :size => '20G'
          lv.storage :file, :size => '20G'
        end
      end
    end
  end
end
