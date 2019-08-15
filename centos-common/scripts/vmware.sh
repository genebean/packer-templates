yum install -y fuse-libs open-vm-tools

# install VMware Tools from iso to get hgfs driver
mkdir -p /mnt/vmware
mount -o loop /home/vagrant/linux.iso /mnt/vmware || exit 1
cd /tmp
tar xzf /mnt/vmware/VMwareTools-*.tar.gz
umount /mnt/vmware
rm -rf /mnt/vmware
rm -rf /home/vagrant/linux.iso
/tmp/vmware-tools-distrib/vmware-install.pl -d
rm -fr /tmp/vmware-tools-distrib

# Customize the initramfs
pushd /etc/dracut.conf.d
# Enable VMware PVSCSI support for VMware Fusion guests.
echo 'add_drivers+=" vmw_pvscsi "' > vmware-fusion-drivers.conf
echo 'add_drivers+=" hv_netvsc hv_storvsc hv_utils hv_vmbus hid-hyperv "' > hyperv-drivers.conf
popd
# Fix the SELinux context of the new files
restorecon -f - <<EOF
/etc/dracut.conf.d/vmware-fusion-drivers.conf
/etc/dracut.conf.d/hyperv-drivers.conf
EOF

dracut -f /boot/initramfs-`uname -r`.img `uname -r`

echo "rebooting..."
reboot
echo "Sleeping for 60 seconds..."
sleep 60
