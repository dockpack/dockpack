#!/bin/bash -eux
# prepare centos virtual machine for use of ansible

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
yum update -y ca-certificates
yum install --assumeyes epel-release
yum install --assumeyes libcurl-devel git python-devel python-pyasn1 python-crypto python-cryptography python-pip

pip install setuptools
pip install --upgrade --force pip
pip install ansible

# create ansible user and group
/usr/sbin/groupadd ansible
/usr/sbin/useradd ansible -g ansible -G wheel -d /home/ansible -c "dockpack"

# add ssh signer's public key - user can ssh with signed certificate
echo 'TrustedUserCAKeys /etc/ssh/ca_key.pub' >> /etc/ssh/sshd_config

# give sudo access (grants all permissions to user ansible)
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
chmod 0440 /etc/sudoers.d/ansible

# set password
echo "ansible" | passwd --stdin ansible
