#!/bin/bash -eux
# prepare centos virtual machine for use of ansible

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
yum update -y ca-certificates
yum install --assumeyes epel-release
yum install --assumeyes libcurl-devel git python-devel python-pyasn1 python-crypto python-cryptography python-pip

pip install setuptools
pip install --upgrade --force pip
pip install ansible
