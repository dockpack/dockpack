#!/bin/bash -eux

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /home/vagrant/VBoxGuestAdditions_*.iso


if [[ "$PACKER_BUILDER_TYPE" == virtualbox* ]]; then
  ## https://access.redhat.com/site/solutions/58625 (subscription required)
  # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
  echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
  service network restart
  echo 'Slow DNS fix applied (single-request-reopen)'
else
  echo 'Slow DNS fix not required for this platform, skipping'
fi
