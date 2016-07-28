if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  echo 'removing old kernels...'
  package-cleanup --oldkernels --count 1 -y
fi

echo
echo 'removing unneeded files and cache...'
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso
rm -rf /tmp/rubygems-*

echo
echo 'removing persistent net rules from udev...'
rm -f /etc/udev/rules.d/70*

echo
echo 'removing MAC and UUID from network startup script...'
sed -i '/^HWADDR=.*$/d' /etc/sysconfig/network-scripts/ifcfg-*
sed -i '/^UUID=.*$/d' /etc/sysconfig/network-scripts/ifcfg-*

echo
echo 'finishing up...'
cat /etc/motd
