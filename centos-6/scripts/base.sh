sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum -y install yum-presto ntpdate

# Ensure date is correct so that yum does not fail due to the time being off
ntpdate -s time.nist.gov

yum -y install binutils fuse-libs gcc gcc-c++ make perl yum-utils

if [ ! -f "/.dockerinit" ]; then
  yum -y install kernel-devel-`uname -r`
fi

yum -y upgrade

# Setup MOTD
motd='/etc/motd'
cat > $motd << 'EOF'
         ______           __  ____  _____    _____    ____
        / ____/__  ____  / /_/ __ \/ ___/   / ___/   / __ )____ _________
       / /   / _ \/ __ \/ __/ / / /\__ \   / __ \   / __  / __ `/ ___/ _ \
      / /___/  __/ / / / /_/ /_/ /___/ /  / /_/ /  / /_/ / /_/ (__  )  __/
      \____/\___/_/ /_/\__/\____//____/   \____/  /_____/\__,_/____/\___/

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

if [ ! -f "/.dockerinit" ]; then
  reboot
  sleep 60
fi
