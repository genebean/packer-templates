sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# remove unneeded firmware packages
yum -y remove iwl*

# install deltarpm so to reduce the size of updates downloaded
yum -y install deltarpm ntpdate

ntpdate -s time.nist.gov

yum -y install binutils fuse-libs gcc gcc-c++ kernel-devel-`uname -r` make perl yum-utils

yum -y upgrade
reboot
sleep 60
