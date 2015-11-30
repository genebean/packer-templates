#!/bin/bash

# Puppet Agent
yum install -y http://reflector.westga.edu/repos/PuppetLabs/yum/puppetlabs-release-el-6.noarch.rpm
yum -y install puppet
puppet resource service puppet ensure=stopped enable=false || exit 1

cat > /etc/puppet/puppet.conf << EOF
[main]
    logdir            = /var/log/puppet
    rundir            = /var/run/puppet
    ssldir            = \$vardir/ssl
    privatekeydir     = \$ssldir/private_keys { group = service }
    hostprivkey       = \$privatekeydir/\$certname.pem { mode = 640 }
    autosign          = \$confdir/autosign.conf { mode = 664 }
    show_diff         = false
    ca_server         = localhost
    hiera_config      = \$confdir/hiera.yaml
[agent]
    classfile         = \$vardir/classes.txt
    localconfig       = \$vardir/localconfig
    default_schedules = false
    report            = true
    pluginsync        = true
    masterport        = 8140
    environment       = production
    server            = localhost
    listen            = false
    splay             = false
    splaylimit        = 1800
    runinterval       = 1800
    noop              = false
    configtimeout     = 120
    usecacheonfailure = true

EOF

if [ -d '/var/lib/puppet/ssl' ]; then
  rm -rf /var/lib/puppet
fi

# Setup MOTD
cat > /etc/motd << 'EOF'
                  ____                         __     _____
                 / __ \__  ______  ____  ___  / /_   |__  /  _  __
                / /_/ / / / / __ \/ __ \/ _ \/ __/    /_ <  | |/_/
               / ____/ /_/ / /_/ / /_/ /  __/ /_    ___/ / _>  <
              /_/    \__,_/ .___/ .___/\___/\__/   /____(_)_/|_|
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
