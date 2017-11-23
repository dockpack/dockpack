VAGRANT_DEFAULT_PROVIDER=virtualbox
DOWNLOADS=downloads
FLAVOR=centos7

#export ARM_STORAGE_ACCOUNT=you_store_it
#export ARM_RESOURCE_GROUP=you_group_it

# Generated
PASSPRHASE:=$(shell openssl rand --hex 8)

.PHONY: help
help:
	@echo 'Usage:'
	@echo "    'make check' to verify dependencies"
	@echo "    'make prepare' to set up local tools"
	@echo "    'make box' to create a ${FLAVOR} box for VirtualBox"
	@echo "    'make vm' to create a ${FLAVOR} for VMWare Desktop/Fusion"
	@echo "    'make azure-arm' to create a ${FLAVOR} image in Azure"
	@echo "    'make test' to test the box"
	@echo "    'make clean' to start all over again"
	@echo


# Create the ssh certificate signing key.
pki/ca_key.pub:
	ssh-keygen -f pki/ca_key -C dockpack -N "${PASSPRHASE}"
	@echo ${PASSPRHASE} > pki/.ca_passphrase

.PHONY: ssh_ca
ssh_ca: pki/ca_key.pub

# Create a ssh key pair for ansible
pki/ansible.pub:
	@ssh-keygen -N ${PASSPRHASE} -C ansible -f pki/ansible

# CA sign the public key with the publice key of the CA
pki/ansible-cert.pub: pki/ansible.pub pki/ca_key.pub
	cat pki/.ca_passphrase
	ssh-keygen -s pki/ca_key -I ansible -n ansible pki/ansible.pub

.PHONY: ssh_key
ssh_key: pki/ansible-cert.pub


.PHONY: check
check:
	test -x /usr/local/bin/virtualbox
	test -x /usr/local/bin/vagrant
	test -x /usr/local/bin/packer
	test -x /usr/local/bin/ansible-lint
	vagrant validate
	packer validate dockpack-${FLAVOR}.json
	packer inspect dockpack-${FLAVOR}.json > /dev/null 2>&1

.PHONY: prepare
prepare:
	(cd ansible && ansible-galaxy install -p roles --force -r requirements.yml)
	@echo installing python extensions for provisioning
	pip install --upgrade -r ansible/requirements.pip
	cp downloads/* /tmp

.PHONY: clean
clean:
	@vagrant halt > /dev/null 2>&1
	@vagrant destroy -f
	vagrant box remove dockpack/${FLAVOR} --provider=virtualbox || true
	vagrant box remove dockpack/${FLAVOR} --provider=vmware_desktop || true
	rm -rf .vagrant/
	rm -f crash.log || true
	rm -f packer/virtualbox-centos*.box || true
	rm -f packer/vmware-centos*.box || true
	rm -rf packer_cache
	rm -rf output-virtualbox-iso
	rm -rf packer/*

.PHONY: test
test: check
	vagrant box list
	vagrant up --no-provision
	vagrant ssh -c 'ls /vagrant/Makefile'
	vagrant halt
	@echo test OK
# ---------------------------------------------------------

packer/virtualbox-${FLAVOR}.box:
	packer validate dockpack-${FLAVOR}.json
	packer build -only=virtualbox-iso dockpack-${FLAVOR}.json

packer/vmware-${FLAVOR}.box:
	packer validate dockpack-${FLAVOR}.json
	packer build --only=vmware-iso dockpack-${FLAVOR}.json

virtualbox: packer/virtualbox-${FLAVOR}.box
	vagrant box remove dockpack/${FLAVOR} --provider=virtualbox || true
	vagrant box add --force dockpack/${FLAVOR} packer/virtualbox-${FLAVOR}.box
	vagrant up --provider=virtualbox ${FLAVOR}

vmware: packer/vmware-${FLAVOR}.box
	vagrant box remove dockpack/${FLAVOR} --provider=vmware_desktop || true
	packer validate dockpack-${FLAVOR}.json
	packer build -only=vmware_desktop dockpack-${FLAVOR}.json
	vagrant box add --force dockpack/${FLAVOR} packer/vmware-${FLAVOR}.box
	vagrant up --provider=vmware_desktop ${FLAVOR}

box: check pki/ansible-cert.pub
	packer build -only=virtualbox-iso dockpack-${FLAVOR}.json

vm: check pki/ansible-cert.pub
	packer build -only=vmware-iso dockpack-${FLAVOR}.json

azure-arm: check pki/ansible-cert.pub
	packer build -only=azure-arm dockpack-${FLAVOR}.json

up:
	vagrant up ${FLAVOR}
# ---------------------------------------------------------

# ---------------------------------------------------------
fedora:
	vagrant up fedora

ubuntu:
	vagrant up ubuntu14

coreos:
	vagrant up coreos

# ---------------------------------------------------------

# dockpack uses packer to build Centos and Windows. Create a local cache in downloads
download:
	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --continue \
	http://www.mirrorservice.org/sites/mirror.centos.org/6/isos/x86_64/CentOS-6.7-x86_64-netinstall.iso \
	|| mv ${DOWNLOADS}/CentOS-6.7-x86_64-netinstall.iso ${DOWNLOADS} || true

	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --continue \
	http://www.mirrorservice.org/sites/mirror.centos.org/7.1.1503/isos/x86_64/CentOS-7-x86_64-DVD-1503-01.iso \
	|| mv ${DOWNLOADS}/CentOS-6.7-x86_64-netinstall.iso ${DOWNLOADS} || true

	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --continue \
	http://www.mirrorservice.org/sites/download.fedora.redhat.com/pub/fedora/linux/releases/21/Server/x86_64/iso/Fedora-Server-netinst-x86_64-21.iso \
	&& mv ${DOWNLOADS}/Fedora-Server-netinst-x86_64-21.iso ${DOWNLOADS} || true

	@wget --limit-rate=10m --tries=10 --retry-connrefused --waitretry=180 --directory-prefix=${DOWNLOADS} --continue \
	http://cdimage.kali.org/kali-1.1.0a/kali-linux-1.1.0a-amd64.iso \
	|| mv ${DOWNLOADS}/kali-1.1.0a/kali-linux-1.1.0a-amd64.iso ${DOWNLOADS} || true
