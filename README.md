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

Hope this helps...

@bbaassssiiee
