VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

# required for VirtualBox 4.3.26
yum install -y bzip2

cd /tmp
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt || exit 1
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /home/vagrant/VBoxGuestAdditions_*.iso

# Verify install
echo 'checking that the guest additions were installed...'
modprobe vboxguest || exit 1
