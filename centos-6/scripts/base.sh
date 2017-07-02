sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# remove unneeded firmware packages
yum -y remove iwl*

yum -y install epel-release ntpdate yum-presto

# Ensure date is correct so that yum does not fail due to the time being off
ntpdate -s time.nist.gov

yum -y install binutils figlet fuse-libs gcc gcc-c++ make net-tools perl vim yum-utils

if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  yum -y install dkms kernel-devel-`uname -r`
fi

yum -y upgrade

# Setup MOTD
motd='/etc/motd'
motd_first_row="CentOS 6 Base"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd

if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  echo "rebooting..."
  reboot
  echo "Sleeping for 60 seconds..."
  sleep 60
fi
