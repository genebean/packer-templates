yum install -y fuse-libs
mkdir -p /mnt/vmware
mount -o loop /home/vagrant/linux.iso /mnt/vmware || exit 1

cd /tmp
tar xzf /mnt/vmware/VMwareTools-*.tar.gz

umount /mnt/vmware
rm -fr /home/vagrant/linux.iso

/tmp/vmware-tools-distrib/vmware-install.pl -d || exit 1
rm -fr /tmp/vmware-tools-distrib
