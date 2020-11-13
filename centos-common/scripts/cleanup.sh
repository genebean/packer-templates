major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";





echo
if [ "$major_version" -ge 8 ]; then
  echo 'removing old kernels...'
  dnf remove --oldinstallonly --setopt installonly_limit=1 kernel -y

  echo 'removing unneeded files and cache...'
  dnf -y clean all
  rm -rf /var/cache/dnf
else
  echo 'removing old kernels...'
  package-cleanup --oldkernels --count 1 -y

  echo 'removing unneeded files and cache...'
  yum -y clean all
  rm -rf /var/cache/yum
fi

find / -iname VBoxGuestAdditions.iso -delete
rm -rf /tmp/rubygems-*
rm -f /tmp/vars.sh

echo
echo 'removing persistent net rules from udev...'
rm -rf /etc/udev/rules.d/70*

echo
echo 'removing MAC and UUID from network startup script...'
sed -i '/^HWADDR=.*$/d' /etc/sysconfig/network-scripts/ifcfg-*
sed -i '/^UUID=.*$/d' /etc/sysconfig/network-scripts/ifcfg-*

if [ "$major_version" -ge 8 ]; then
  nmcli connection reload
fi

echo
echo 'removing ssh keys'
rm -rf /etc/ssh/ssh_host_*

echo
echo 'finishing up...'
cat /etc/motd
sync
