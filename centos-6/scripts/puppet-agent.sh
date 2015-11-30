#!/bin/bash

# Puppet Agent
yum install -y http://reflector.westga.edu/repos/PuppetLabs/yum/puppetlabs-release-pc1-el-6.noarch.rpm
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
cat > /etc/motd << 'EOF'
                 ____                         __     __ __
                / __ \__  ______  ____  ___  / /_   / // /   _  __
               / /_/ / / / / __ \/ __ \/ _ \/ __/  / // /_  | |/_/
              / ____/ /_/ / /_/ / /_/ /  __/ /_   /__  __/ _>  <
             /_/    \__,_/ .___/ .___/\___/\__/     /_/ (_)_/|_|
                        /_/   /_/
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
