yum -y install epel-release
if [ ! -f "/.dockerinit" ]; then
  yum -y install dkms
fi
