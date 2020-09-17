VAGRANT_DEFAULT_PROVIDER=virtualbox
DOWNLOADS=downloads
FLAVOR=centos7

.PHONY: help
help:
	@echo 'Usage:'
	@echo "    'make check' to verify dependencies"
	@echo "    'make prepare' to set up local tools"
	@echo "    'make build' to create a ${FLAVOR} box"
	@echo "    'make test' to test the box"
	@echo "    'make clean' to start all over again"
	@echo


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

virtualvm: packer/virtualbox-${FLAVOR}.box
	vagrant box remove dockpack/${FLAVOR} --provider=virtualbox || true
	packer validate dockpack-${FLAVOR}.json
	packer build -only=virtualbox-iso dockpack-${FLAVOR}.json
box:
	vagrant box add --force dockpack/${FLAVOR} packer/virtualbox-${FLAVOR}.box
	vagrant up ${FLAVOR}

vmwarevm: packer/vmware-${FLAVOR}.box
	vagrant box add --force dockpack/${FLAVOR} packer/vmware-${FLAVOR}.box

build:
	packer build -only=virtualbox-iso dockpack-${FLAVOR}.json

# ---------------------------------------------------------

# ---------------------------------------------------------
fedora:
	vagrant up fedora

ubuntu:
	vagrant up ubuntu14

coreos:
	vagrant up coreos

# ---------------------------------------------------------

up:
	vagrant up ${FLAVOR}

virtualbox: ${FLAVOR}



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
