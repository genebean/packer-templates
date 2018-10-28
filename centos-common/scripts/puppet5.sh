#!/bin/bash

source /tmp/vars.sh

# Puppet Agent
yum install -y https://yum.puppetlabs.com/puppet5/puppet5-release-el-$os_version.noarch.rpm
yum -y install puppet-agent
source /etc/profile.d/puppet-agent.sh
puppet resource service puppet ensure=stopped enable=false || exit 1
puppet config set ca_server localhost.localdomain --section main
puppet config set server localhost.localdomain --section main

if [ -d '/etc/puppetlabs/puppet/ssl' ]; then
  rm -rf /etc/puppetlabs/puppet/ssl
fi

# Setup MOTD
motd='/etc/motd'
motd_first_row="Puppet `puppet --version`"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd
