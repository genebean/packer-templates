set -e

hostnamectl set-hostname packer-pebaseline
echo "installing via https://${PACKER_PUPPETMASTER}:8140/packages/current/install.bash"
curl -s -k "https://${PACKER_PUPPETMASTER}:8140/packages/current/install.bash" | bash
/opt/puppetlabs/puppet/bin/puppet resource service puppet ensure=stopped enable=false

figlet -f slant "Sign Me!"
echo
certname="$(/opt/puppetlabs/puppet/bin/facter fqdn)"
echo "Run 'sudo puppet cert sign ${certname}' on the master'"
echo "sleeping for 1 minute..."
sleep 60

set +e
/opt/puppetlabs/puppet/bin/puppet agent -t
/opt/puppetlabs/puppet/bin/puppet agent -t
if [ $? -eq 1 ]; then
  echo "puppet exited 1 indicating a failure"
  exit 1
fi

set -e
/opt/puppetlabs/puppet/bin/puppet resource service puppet ensure=stopped enable=false
/opt/puppetlabs/puppet/bin/puppet resource cron 'pe agent'
/opt/puppetlabs/puppet/bin/puppet resource cron 'pe agent' ensure=absent
rm -rf /etc/puppetlabs/puppet/ssl
sed -i '/^certname/d' /etc/puppetlabs/puppet/puppet.conf
sed -i '/^environment/d' /etc/puppetlabs/puppet/puppet.conf
sed -i '/packer-pebaseline/d' /etc/motd
sleep 5

figlet -f slant "Clean Up Time"
echo
echo "Run 'sudo puppet node purge ${certname}' on the master"
sleep 15

echo "Resetting up the vagrant user..."
/opt/puppetlabs/puppet/bin/puppet resource group vagrant ensure=present
/opt/puppetlabs/puppet/bin/puppet resource user vagrant ensure=present gid=vagrant groups=wheel
echo 'vagrant'|passwd --stdin vagrant
echo 'vagrant        ALL=(ALL)       NOPASSWD: ALL' >  /etc/sudoers.d/vagrant
echo 'Defaults:vagrant !requiretty'                 >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

echo 'vagrant'|passwd --stdin root
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
setenforce Permissive
