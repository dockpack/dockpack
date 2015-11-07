## dockpack

This project uses packer and vagrant to create an agile lab, a secure devops
environment where ansible is used to spawn all systems from code.

Secure from the start.

The first secured artifact is a DISA-STIG compliant Centos6 linux.

    Run 'make demo' to see the oscap security audit.

Secure Vagrant base box

The hardened Centos6 box can be used separately in other projects using vagrant:

    vagrant init -m dockpack/centos6
    vagrant up

That will download the box for VirtualBox or VMWare from:
https://atlas.hashicorp.com/dockpack/boxes/centos6

Development cycle for centos7
-----------------------------
vagrant halt centos7
vagrant destroy centos7
vagrant box remove dockpack/centos7
rm -rf packer/virtualbox-centos7.box
make packer/virtualbox-centos7.box
make virtualvm7
vagrant up centos7
vagrant ssh centos7

Hope this helps...

@bbaassssiiee
