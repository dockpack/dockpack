#!/bin/bash -eux

yum -y erase gcc cpp libstdc++-devel kernel-devel kernel-headers perl
# For STIG compliance audit, openswan removed by line above
yum -y install openswan 

yum -y clean all
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?

# Unlock vagrant user after applying the RHEL-STIG role.
passwd -u vagrant
restorecon -R -v /home/vagrant/.ssh

echo "==> Cleaning up temporary network addresses"
# Make sure udev doesn't block our network
if grep -q -i "release 6" /etc/redhat-release ; then
    rm -f /etc/udev/rules.d/70-persistent-net.rules
    mkdir /etc/udev/rules.d/70-persistent-net.rules
    rm /lib/udev/rules.d/75-persistent-net-generator.rules
fi
rm -rf /dev/.udev/
if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then
    sed -i "/^HWADDR/d" /etc/sysconfig/network-scripts/ifcfg-eth0
    sed -i "/^UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0
fi

# Whiteout the swap partition to reduce box size 
# Swap is disabled till reboot 
readonly swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
readonly swappart=$(readlink -f /dev/disk/by-uuid/"$swapuuid")
/sbin/swapoff "$swappart"
dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed" 
/sbin/mkswap -U "$swapuuid" "$swappart"

# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# WORKAROUND: remove myself: https://github.com/mitchellh/packer/issues/1536
rm -f /tmp/script.sh

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync
