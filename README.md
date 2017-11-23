## dockpack

This project uses packer and vagrant to create an agile lab, a secure devops
environment where ansible is used to spawn all systems from code.

Secure from the start.

The first secured artifact is a DISA-STIG compliant Centos6 linux.
The hardened Centos6 box can be used separately in other projects using vagrant:

    vagrant init -m dockpack/centos6
    vagrant up

That will download the box for VirtualBox or VMWare from Vagrant Cloud.


Development cycle for centos7
-----------------------------
Check the Makefile

Export these in the environment so packer can validate the dockpack-centos7.json file:
```
export ARM_RESOURCE_GROUP=you_group_it
export ARM_SUBSCRIPTION_ID=your_bogus
export ARM_STORAGE_ACCOUNT=you_store_it
export ARM_CLIENT_SECRET=your_bogus
export ARM_TENNANT_ID=your_bogus
export ARM_CLIENT_ID=your_bogus
```

@bbaassssiiee
