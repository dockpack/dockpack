DOWNLOADS=./downloads

help:
	@echo 'Usage:'
	@echo '    make install'
	@echo '    make all'


install:
	(cd ansible && ansible-galaxy install --force -r requirements.yml)

stig: install
	ansible-playbook --private-key=vagrant.rsa -i ansible/ansible.ini -l centos6 ansible/RHEL-STIG1.yml ansible/RHEL-STIG2.yml

audit:	
	ansible-playbook --private-key=vagrant.rsa -i ansible/ansible.ini -l centos6 ansible/security_audit.yml

packer/virtualbox-centos6.box:
	packer validate dockpack-centos6.json
	packer build -only=virtualbox-iso dockpack-centos6.json

packer/vmware-centos6.box: 
	packer validate dockpack-centos6.json
	packer build --only=vmware-iso dockpack-centos6.json

packer/qemu-centos6.box: 
	packer build --only=qemu dockpack-centos6.json

virtualvm: packer/virtualbox-centos6.box
	vagrant box add --force centos6 packer/virtualbox-centos6.box

vmwarevm: packer/vmware-centos6.box
	vagrant box add --force centos6 packer/vmware-centos6.box

packer/virtualbox-win7ie10.box:
	packer validate dockpack-win7ie10.json
	packer build -only=virtualbox-iso dockpack-win7ie10.json

packer/vmware-win7ie10.box: 
	packer validate dockpack-win7ie10.json
	packer build --only=vmware-iso dockpack-win7ie10.json

virtualwinvm: packer/virtualbox-win7ie10.box
	vagrant box add --force centos6 packer/virtualbox-centos6.box

windows: virtualwinvm
	vagrant up windows_7

centos6: virtualvm
	vagrant up centos6

virtualbox: windows centos6

vmware: vmwarevm

up: virtualbox

realclean:
	vagrant destroy -f centos6 || true
	vagrant box remove centos6 --provider=virtualbox || true
	vagrant box remove centos6 --provider=vmware_desktop || true
	rm -f packer/virtualbox-centos6.box || true
	rm -f packer/vmware-centos6.box || true
	rm -rf packer_cache

# dockpack uses packer to build Centos and Windows. Create a local cache in downloads
download:
	wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --no-clobber http://care.dlservice.microsoft.com/dl/download/evalx/win7/x64/EN/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso && ln -fs downloads/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso /tmp/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso || /bin/false
	wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --no-clobber http://www.mirrorservice.org/sites/mirror.centos.org/6/isos/x86_64/CentOS-6.6-x86_64-netinstall.iso && ln -fs downloads/CentOS-6.6-x86_64-netinstall.iso /tmp/CentOS-6.6-x86_64-netinstall.iso || /bin/false


all: download up audit

