#!/bin/bash
rvm_version='1.9.3'
# Setup RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 || exit 1
su - vagrant -c '\curl -L https://get.rvm.io | sudo bash -s stable' || exit 1
usermod -a -G rvm vagrant || exit 1
su - vagrant -c 'rvm autolibs enable' || exit 1

# Setup Ruby
su - vagrant -c "rvm install ${rvm_version}" || exit 1

# Verify install
echo
echo 'Checking RMV and Ruby'
su - vagrant -c 'rvm -v' || exit 1
su - vagrant -c 'ruby -v' || exit 1
echo

# Setup MOTD
motd='/etc/motd'
motd_first_row="RVM + v${rvm_version}"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd || exit 1
