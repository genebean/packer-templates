sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum -y install yum-presto ntpdate

# Ensure date is correct so that yum does not fail due to the time being off
ntpdate -s time.nist.gov

yum -y install binutils fuse-libs gcc gcc-c++ kernel-devel-`uname -r` make perl yum-utils

yum -y upgrade
reboot
sleep 60
