source /tmp/vars.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# clean up cache that can cause errors later
yum clean all
rm -rf /var/cache/yum/*

# remove unneeded firmware packages
yum -y remove iwl*

# install deltarpm so to reduce the size of updates downloaded
yum -y install deltarpm epel-release ntpdate yum-presto $extra_packages

# Ensure date is correct so that yum does not fail due to the time being off
ntpdate -s time.nist.gov

yum -y install binutils dkms figlet fuse-libs gcc gcc-c++ kernel-devel-`uname -r` make net-tools perl redhat-lsb-core vim yum-utils

yum -y upgrade

# Setup MOTD
motd='/etc/motd'
motd_first_row="CentOS ${os_version} Base"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd

echo "rebooting..."
reboot
echo "Sleeping for 60 seconds..."
sleep 60
