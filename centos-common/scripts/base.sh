source /tmp/vars.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

if [ "$major_version" -ge 8 ]; then
  # clean up cache that can cause errors later
  dnf clean all
  rm -rf /var/cache/dnf/*

  # install deltarpm so to reduce the size of updates downloaded
  dnf -y install drpm epel-release tuned $extra_packages

  echo 'configure tuned as virtual-guest'
  tuned-adm profile virtual-guest

  # get new entries for the cache that includes epel
  dnf makecache

  # Ensure date is correct so that yum does not fail due to the time being off
  systemctl stop chronyd
  chronyd -q 'server time.nist.gov iburst'
  systemctl start chronyd

  dnf -y install binutils dkms figlet fuse-libs gcc gcc-c++ kernel-devel make net-tools perl policycoreutils-python-utils redhat-lsb-core vim dnf-utils

  dnf -y upgrade
else
  # clean up cache that can cause errors later
  yum clean all
  rm -rf /var/cache/yum/*

  # install deltarpm so to reduce the size of updates downloaded
  yum -y install deltarpm epel-release ntpdate tuned yum-presto $extra_packages

  echo 'configure tuned as virtual-guest'
  tuned-adm profile virtual-guest

  # get new entries for the cache that includes epel
  yum makecache fast

  # Ensure date is correct so that yum does not fail due to the time being off
  ntpdate -s time.nist.gov

  yum -y install binutils dkms figlet fuse-libs gcc gcc-c++ kernel-devel make net-tools perl policycoreutils-python redhat-lsb-core vim yum-utils

  yum -y upgrade
fi
# Setup MOTD
motd='/etc/motd'
motd_first_row="CentOS ${os_version} Base"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by ${vagrant_user}" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd

echo "rebooting..."
reboot
echo "Sleeping for 60 seconds..."
sleep 60

