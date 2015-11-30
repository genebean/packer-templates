date > /etc/vagrant_box_build_time

if [ ! -f "/.dockerinit" ]; then
  mkdir -pm 700 /home/vagrant/.ssh
  curl -L https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
  chmod 0600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh

  echo 'UseDNS no' >> /etc/sshd_config
fi
