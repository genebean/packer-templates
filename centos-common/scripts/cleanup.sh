echo 'removing old kernels...'
package-cleanup --oldkernels --count 1 -y

echo
echo 'removing unneeded files and cache...'
yum -y clean all
rm -rf /var/cache/yum
find / -iname VBoxGuestAdditions.iso -delete
rm -rf /tmp/rubygems-*
rm -f /tmp/vars.sh

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
sync
