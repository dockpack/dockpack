#!/bin/bash -eux
# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/root}";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)

    yum install -y gcc cpp bzip2 libstdc++-devel kernel-devel kernel-headers

    mkdir -p /tmp/vbox;
    ver="`cat /root/.vbox_version`";
    mount -o loop $HOME_DIR/VBoxGuestAdditions.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;
esac

if [[ "$PACKER_BUILDER_TYPE" == virtualbox* ]]; then
  ## https://access.redhat.com/site/solutions/58625 (subscription required)
  # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
  echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
  echo 'Slow DNS fix applied (single-request-reopen)'
else
  echo 'Slow DNS fix not required for this platform, skipping'
fi
