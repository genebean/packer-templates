yum -y install passwd sudo which tar

/usr/sbin/groupadd vagrant
/usr/sbin/useradd vagrant -g vagrant -G wheel
echo 'vagrant'|passwd --stdin vagrant
echo 'vagrant        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers.d/vagrant
echo 'Defaults:vagrant !requiretty'                 >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
