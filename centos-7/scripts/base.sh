sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# remove unneeded firmware packages
yum -y remove iwl*

# install deltarpm so to reduce the size of updates downloaded
yum -y install deltarpm ntpdate

# Ensure date is correct so that yum does not fail due to the time being off
ntpdate -s time.nist.gov

yum -y install binutils fuse-libs gcc gcc-c++ make net-tools perl vim yum-utils

if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  yum -y install kernel-devel-`uname -r`
fi

yum -y upgrade

# Setup MOTD
motd='/etc/motd'
cat > $motd << 'EOF'
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

echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd
echo >> $motd

echo 'Testing the MOTD...'
echo
cat $motd

if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  reboot
  sleep 60
fi
