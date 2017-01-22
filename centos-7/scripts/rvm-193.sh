#!/bin/bash

# Setup RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
su - vagrant -c '\curl -L https://get.rvm.io | sudo bash -s stable'
usermod -a -G rvm vagrant
su - vagrant -c 'rvm autolibs enable'

# Setup Ruby 1.9.3
su - vagrant -c 'rvm install 1.9.3' || exit 1 

# Verify install
echo
echo 'Checking RMV and Ruby'
su - vagrant -c 'rvm -v' || exit 1
su - vagrant -c 'ruby -v' || exit 1
echo

# Setup MOTD
motd='/etc/motd'
cat > $motd << 'EOF'
               ____ _    ____  ___                 ___  ____   _____
              / __ \ |  / /  |/  /    __     _   _<  / / __ \ |__  /
             / /_/ / | / / /|_/ /  __/ /_   | | / / / / /_/ /  /_ <
            / _, _/| |/ / /  / /  /_  __/   | |/ / /_ \__, / ___/ /
           /_/ |_| |___/_/  /_/    /_/      |___/_/(_)____(_)____/

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
