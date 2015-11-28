#!/bin/bash

# Puppet Agent
yum install -y http://reflector.westga.edu/repos/PuppetLabs/yum/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppet-agent
source /etc/profile.d/puppet-agent.sh
puppet resource service puppet ensure=stopped enable=false

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
