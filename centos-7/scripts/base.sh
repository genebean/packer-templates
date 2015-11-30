sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# remove unneeded firmware packages
yum -y remove iwl*

# install deltarpm so to reduce the size of updates downloaded
yum -y install deltarpm ntpdate

ntpdate -s time.nist.gov

yum -y install binutils fuse-libs gcc gcc-c++ make perl yum-utils

if [ ! -f "/.dockerinit" ]; then
  yum -y install kernel-devel-`uname -r`
fi

yum -y upgrade

# Setup MOTD
cat > /etc/motd << 'EOF'
         ______           __  ____  _____    _____   ____
        / ____/__  ____  / /_/ __ \/ ___/   /__  /  / __ )____ _________
       / /   / _ \/ __ \/ __/ / / /\__ \      / /  / __  / __ `/ ___/ _ \
      / /___/  __/ / / / /_/ /_/ /___/ /     / /  / /_/ / /_/ (__  )  __/
      \____/\___/_/ /_/\__/\____//____/     /_/  /_____/\__,_/____/\___/

             __             ______                ____
            / /_  __  __   / ____/__  ____  ___  / __ )___  ____ _____
           / __ \/ / / /  / / __/ _ \/ __ \/ _ \/ __  / _ \/ __ `/ __ \
          / /_/ / /_/ /  / /_/ /  __/ / / /  __/ /_/ /  __/ /_/ / / / /
         /_.___/\__, /   \____/\___/_/ /_/\___/_____/\___/\__,_/_/ /_/
               /____/

EOF

echo 'Testing the MOTD...'
echo
cat /etc/motd

if [ ! -f "/.dockerinit" ]; then
  reboot
  sleep 60
fi
