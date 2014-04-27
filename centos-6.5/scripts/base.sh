sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
yum -y install binutils gcc gcc-c++ kernel-devel-`uname -r` make perl yum-presto yum-utils

