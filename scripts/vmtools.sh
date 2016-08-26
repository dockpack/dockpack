#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/root}";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)

    yum install -y gcc cpp bzip2 libstdc++-devel kernel-devel kernel-headers

    mkdir -p /tmp/vbox;
    ver="`cat /root/.vbox_version`";
#    wget #http://download.virtualbox.org/virtualbox/${ver}/VBoxGuestAdditions_${ver}.iso
    mount -o loop $HOME_DIR/VBoxGuestAdditions.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;

vmware-iso|vmware-vmx)
		yum install -y open-vm-tools
    ;;

parallels-iso|parallels-pvm)
    mkdir -p /tmp/parallels;
    mount -o loop $HOME_DIR/prl-tools-lin.iso /tmp/parallels;
    /tmp/parallels/install --install-unattended-with-deps \
      || (code="$?"; \
          echo "Parallels tools installation exited $code, attempting" \
          "to output /var/log/parallels-tools-install.log"; \
          cat /var/log/parallels-tools-install.log; \
          exit $code);
    umount /tmp/parallels;
    rm -rf /tmp/parallels;
    rm -f $HOME_DIR/*.iso;
    ;;

qemu)
    echo "Don't need anything for this one"
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac