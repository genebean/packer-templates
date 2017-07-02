#!/bin/bash

# Puppet Agent
yum install -y https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum -y install puppet-agent
source /etc/profile.d/puppet-agent.sh
puppet resource service puppet ensure=stopped enable=false || exit 1

cat > /etc/puppetlabs/puppet/puppet.conf << EOF
# This file can be used to override the default puppet settings.
# See the following links for more details on what settings are available:
# - https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html
# - https://docs.puppetlabs.com/references/latest/configuration.html
[main]
    ca_server            = localhost
    server               = localhost
    strict_variables     = true
    trusted_server_facts = true
[agent]

EOF

if [ -d '/etc/puppetlabs/puppet/ssl' ]; then
  rm -rf /etc/puppetlabs/puppet/ssl
fi

# Setup MOTD
motd='/etc/motd'
motd_first_row="Puppet 5.x"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd
