sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum -y install yum-presto
yum -y install binutils fuse-libs gcc gcc-c++ kernel-devel-`uname -r` make perl yum-utils

yum -y upgrade
reboot
sleep 60
