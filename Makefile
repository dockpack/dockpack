VAGRANT_DEFAULT_PROVIDER=virtualbox
DOWNLOADS=downloads

help:
	@echo 'Usage:'
	@echo '    make download'
	@echo '    make install'
	@echo '    make demo'
	@echo '    make all'


install:
	(cd ansible && ansible-galaxy install -p roles --force -r requirements.yml)
	@echo installing python extensions for provisioning
	pip install --upgrade -r ansible/requirements.pip
	cp downloads/* /tmp
audit:
	ansible-playbook --private-key=pki/vagrant.rsa -vv -i ansible/inventory/ansible.ini -l centos6 ansible/security_audit.yml
	open rhel-stig-report.html

# ---------------------------------------------------------

packer/virtualbox-centos7.box:
	packer validate dockpack-centos7.json
	packer build -only=virtualbox-iso dockpack-centos7.json

packer/vmware-centos7.box:
	packer validate dockpack-centos7.json
	packer build --only=vmware-iso dockpack-centos7.json

virtualvm7: packer/virtualbox-centos7.box
	vagrant box add --force dockpack/centos7 packer/virtualbox-centos7.box

vmwarevm7: packer/vmware-centos7.box
	vagrant box add --force dockpack/centos7 packer/vmware-centos7.box

# ---------------------------------------------------------

packer/virtualbox-centos6.box:
	packer validate dockpack-centos6.json
	packer build -only=virtualbox-iso dockpack-centos6.json

packer/vmware-centos6.box:
	packer validate dockpack-centos6.json
	packer build --only=vmware-iso dockpack-centos6.json

virtualvm6: packer/virtualbox-centos6.box
	vagrant box add --force dockpack/centos6 packer/virtualbox-centos6.box

vmwarevm6: packer/vmware-centos6.box
	vagrant box add --force dockpack/centos6 packer/vmware-centos6.box

# ---------------------------------------------------------

packer/virtualbox-fedora22.box:
	packer validate dockpack-fedora22.json
	packer build -only=virtualbox-iso dockpack-fedora22.json

packer/vmware-fedora22.box:
	packer validate dockpack-fedora22.json
	packer build --only=vmware-iso dockpack-fedora22.json


virtualfedora: packer/virtualbox-fedora22.box
	vagrant box add --force fedora22 packer/virtualbox-fedora22.box

vmfedora: packer/vmware-fedora22.box
	vagrant box add --force fedora22 packer/vmware-fedora22.box

# ---------------------------------------------------------
fedora:
	vagrant up fedora22

ubuntu:
	vagrant up ubuntu14

coreos:
	vagrant up coreos

# ---------------------------------------------------------

centos7:
	vagrant up centos7

centos6:
	vagrant up centos6

virtualbox: centos6

vmware: vmwarevm


boxes:
	packer build -only=virtualbox-iso dockpack-centos6.json
	packer build -only=virtualbox-iso dockpack-centos7.json
	packer build -only=virtualbox-iso dockpack-fedora22.json


up: virtualbox

clean:
	rm -rf output-virtualbox-iso
	rm -rf packer/*

realclean:
	vagrant destroy -f centos6 || true
	vagrant destroy -f centos7 || true
	vagrant box remove dockpack/centos6 --provider=virtualbox || true
	vagrant box remove dockpack/centos6 --provider=vmware_desktop || true
	vagrant box remove dockpack/centos7 --provider=virtualbox || true
	vagrant box remove dockpack/centos7 --provider=vmware_desktop || true
	rm -rf .vagrant/
	rm -f crash.log || true
	rm -f packer/virtualbox-centos6.box || true
	rm -f packer/virtualbox-centos7.box || true
	rm -f packer/vmware-centos6.box || true
	rm -rf packer_cache

# dockpack uses packer to build Centos and Windows. Create a local cache in downloads
download:
	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --no-clobber \
	http://www.mirrorservice.org/sites/mirror.centos.org/6/isos/x86_64/CentOS-6.7-x86_64-netinstall.iso \
	|| mv ${DOWNLOADS}/CentOS-6.7-x86_64-netinstall.iso ${DOWNLOADS} || true

	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --no-clobber \
	http://www.mirrorservice.org/sites/mirror.centos.org/7.1.1503/isos/x86_64/CentOS-7-x86_64-DVD-1503-01.iso \
	|| mv ${DOWNLOADS}/CentOS-6.7-x86_64-netinstall.iso ${DOWNLOADS} || true

	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --no-clobber \
	http://www.mirrorservice.org/sites/download.fedora.redhat.com/pub/fedora/linux/releases/21/Server/x86_64/iso/Fedora-Server-netinst-x86_64-21.iso \
	&& mv ${DOWNLOADS}/Fedora-Server-netinst-x86_64-21.iso ${DOWNLOADS} || true

demo: centos6 audit
all: clean install virtualvm6 centos6 

