# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # provision.yml runs on a vagrant up, packer.yml runs on packer build.
  config.vm.provision "ansible" do |ansible|
    ansible.inventory_path = "ansible/ansible.ini"
    ansible.playbook = "ansible/provision.yml"
    ansible.verbose = "vv"
   end  
  
  # Prefer VirtualBox before VMware Fusion  
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"
  
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

  # Apple OS X: Get a life, get a Mac! Implementation details for osx packer boxes:
  # https://github.com/boxcutter/osx

  # Windows: You need to create a temporarily licenced Windows box with 'packer build win7ie10.json'
  config.vm.define :windows_7, autostart: true do |windows_7_config|
    windows_7_config.vm.box = "dockpack/windows_7"
    windows_7_config.vm.communicator = "winrm"
  
    windows_7_config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    windows_7_config.vm.network :forwarded_port, guest: 22, host: 2200, id: "ssh", auto_correct: true

    # Admin user name and password
    windows_7_config.winrm.username = "vagrant"
    windows_7_config.winrm.password = "vagrant"

    windows_7_config.vm.guest = :windows
    windows_7_config.windows.halt_timeout = 15

    windows_7_config.vm.provider :virtualbox do |vb, override|
        vb.gui = true
        vb.name = "dockpack/windows_7"
        vb.customize ["modifyvm", :id, "--memory", 2048]
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    windows_7_config.vm.provider :vmware_fusion do |vm, override|
        #vm.gui = true
        vm.vmx["memsize"] = "2048"
        vm.vmx["numvcpus"] = "2"
        vm.vmx["ethernet0.virtualDev"] = "vmxnet3"
        vm.vmx["RemoteDisplay.vnc.enabled"] = "false"
        vm.vmx["RemoteDisplay.vnc.port"] = "5900"
        vm.vmx["scsi0.virtualDev"] = "lsisas1068"
    end

    windows_7_config.vm.provider :vmware_workstation do |vm, override|
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
    centos6_config.vm.box = "dockpack/centos6"  # to delete: 'vagrant destroy; box remove centos6'
    centos6_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2201, auto_correct: true
    
    centos6_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    centos6_config.vm.provider "virtualbox" do |vb|
      vb.name = "dockpack/centos6"
    end
  end

  ## Ubuntu Official: https://cloud-images.ubuntu.com/vagrant/
  config.vm.define :ubuntu14, autostart: true do |ubuntu14_config|
    ubuntu14_config.vm.box = "ubuntu14"
    ubuntu14_config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/20150506/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    ubuntu14_config.vm.box_download_checksum = "f6438c4155fb9c02d642fb8bbdda5d021cc529d8f85b0aad0f6be820293a11d3" 
    ubuntu14_config.vm.box_download_checksum_type = "sha256"
    ubuntu14_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2203, auto_correct: true
    
    ubuntu14_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    ubuntu14_config.vm.provider "virtualbox" do |virtualbox|
      virtualbox.name = "ubuntu14"
    end
  end

  ## Chef's Bento project on Hashicorp Atlas: Bento project https://github.com/chef/bento
  # Just an example of a linux from this project
  config.vm.define :fedora21, autostart: true do |fedora21_config|
    fedora21_config.vm.box = "chef/fedora-12"
    fedora21_config.vm.box_url = "https://atlas.hashicorp.com/chef/boxes/fedora-21"
    fedora21_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2202, auto_correct: true
    
    fedora21_config.vm.provider "vmware_fusion" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end
    fedora21_config.vm.provider "virtualbox" do |vb|
      vb.name = "fedora21"
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
  
  ## RancherOS Official: https://github.com/rancherio/os
  config.vm.define :rancheros, autostart: true do |rancheros_config|
    rancheros_config.vm.box  = "rancheros"
    
    rancheros_config.vm.network "forwarded_port", id: 'ssh', guest: 22, host: 2205, auto_correct: true
    rancheros_config.ssh.username = "rancher"
  
    rancheros_config.vm.provider "virtualbox" do |virtualbox, override|
      override.vm.box_url = "http://cdn.rancher.io/vagrant/x86_64/prod/rancheros_virtualbox.box"  
      virtualbox.name = "rancheros"
    end
  end
end
