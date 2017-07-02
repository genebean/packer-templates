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
motd='/etc/motd'
motd_first_row="Puppet 3.x"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd
