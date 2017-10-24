# -*- mode: ruby -*-
# vi: set ft=ruby :
# To use these virtual machine install Vagrant and VirtuaBox or VMWare.
# vagrant up [centos6|fedora|kali|ubuntu14|coreos|windows]

Vagrant.configure(2) do |config|

  # provision.yml runs on a vagrant up, packer.yml runs on packer build.
  config.vm.provision "ansible" do |ansible|
    ansible.inventory_path = "ansible/inventory/ansible.ini"
    ansible.playbook = "ansible/provision.yml"
    ansible.verbose = "vv"
   end

  # Prefer VirtualBox before VMware Fusion
  #config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"
  config.vbguest.auto_update = false
  config.ssh.insert_key = false
  config.vm.provider "virtualbox" do |virtualbox|
    virtualbox.gui = false
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.provider "vmware_fusion" do |vmware|
    vmware.gui = true
    vmware.vmx["memsize"] = "2048"
    vmware.vmx["numvcpus"] = "2"
  end

  config.ssh.insert_key = false
  config.vm.box_check_update = false
  # disable guest additions
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  config.vm.define :centos7, primary: true, autostart: true do |centos7_config|
    centos7_config.vm.box = "dockpack/centos7"
    centos7_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2207, auto_correct: true

    centos7_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    centos7_config.vm.provider "virtualbox" do |vb|
      vb.name = "centos7"
    end
  end

  # Windows: You need to create a temporarily licenced Windows box with 'packer build windows.json'
  config.vm.define :windows, autostart: true do |windows_config|
    windows_config.vm.network "public_network", use_dhcp_assigned_default_route: true
    windows_config.vm.box = "windows"
    windows_config.vm.box_url = "https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip"
    windows_config.vm.communicator = "winrm"
    windows_config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    windows_config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: false

    # Admin user name and password
    windows_config.winrm.username = "IEUser"
    windows_config.winrm.password = "Passw0rd!"

    windows_config.vm.guest = :windows
    windows_config.windows.halt_timeout = 15

    windows_config.vm.provider :virtualbox do |vb, override|
        vb.gui = false
        vb.name = "windows"
        vb.customize ["modifyvm", :id, "--memory", 4096]
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    windows_config.vm.provider :vmware_fusion do |vm, override|
        #vm.gui = true
        vm.vmx["memsize"] = "2048"
        vm.vmx["numvcpus"] = "2"
        vm.vmx["ethernet0.virtualDev"] = "vmxnet3"
        vm.vmx["RemoteDisplay.vnc.enabled"] = "false"
        vm.vmx["RemoteDisplay.vnc.port"] = "5900"
        vm.vmx["scsi0.virtualDev"] = "lsisas1068"
    end

    windows_config.vm.provider :vmware_workstation do |vm, override|
        #vm.gui = true
        vm.vmx["memsize"] = "2048"
        vm.vmx["numvcpus"] = "2"
        vm.vmx["ethernet0.virtualDev"] = "vmxnet3"
        vm.vmx["RemoteDisplay.vnc.enabled"] = "false"
        vm.vmx["RemoteDisplay.vnc.port"] = "5900"
        vm.vmx["scsi0.virtualDev"] = "lsisas1068"
    end
  end


  # Centos 6: Create the DISO STIG hardened centos6 box with 'packer build centos6.json'
  config.vm.define :centos6, autostart: true do |centos6_config|
    centos6_config.vm.box = "dockpack/centos6"
    centos6_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2201, auto_correct: true
		centos6_config.vm.hostname = "centos6"
    centos6_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    centos6_config.vm.provider "virtualbox" do |vb|
      vb.name = "centos6"
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
  end

  ## Ubuntu Official: https://cloud-images.ubuntu.com/vagrant/
  config.vm.define :ubuntu14, autostart: true do |ubuntu14_config|
    ubuntu14_config.vm.box = "ubuntu14"
    ubuntu14_config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    ubuntu14_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2202, auto_correct: true

    ubuntu14_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    ubuntu14_config.vm.provider "virtualbox" do |virtualbox|
      virtualbox.name = "ubuntu14"
      virtualbox.gui = true
    end
  end

  config.vm.define :fedora, autostart: true do |fedora_config|
    fedora_config.vm.box = "fedora/26-atomic-host"
    fedora_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2203, auto_correct: true

    fedora_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    fedora_config.vm.provider "virtualbox" do |vb|
      vb.name = "fedora"
    end
  end

  ## CoreOS Official: https://github.com/coreos/coreos-vagrant
  config.vm.define :coreos, autostart: true do |coreos_config|
    coreos_config.vm.box = "coreos-box"  # to delete: 'vagrant destroy; box remove coreos-box'

    coreos_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2204, auto_correct: true
    coreos_config.vm.provider "vmware_fusion" do |vmware, override|
      override.vm.box_url = "http://stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.box"
    end
    coreos_config.vm.provider "virtualbox" do |virtualbox, override|
      override.vm.box_url = "http://stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.box"
      virtualbox.name = "coreos"
    end
  end

  ## Kali linux
  config.vm.define "kali", autostart: false do |kali_config|
    kali_config.vm.box = "Sliim/kali-linux-2.0-amd64"
    kali_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2205, auto_correct: true

    kali_config.vm.provider "vmware_fusion" do |vmware|
      vmware.gui = true
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    kali_config.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.name = "kali"
    end
  end

end
