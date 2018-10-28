#!/bin/bash

# Install Docker CE and set permissions for the Vagrant user
yum install -y yum-utils device-mapper-persistent-data lvm2 || exit 1
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || exit 1
yum install -y docker-ce || exit 1
usermod -a -G docker vagrant || exit 1
systemctl enable docker || exit 1
systemctl start docker || exit 1

echo 'Checking docker --version...'
docker --version || exit 1

# Setup MOTD
motd='/etc/motd'
motd_first_row="Docker CE"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd
