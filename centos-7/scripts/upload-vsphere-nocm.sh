set -e

if [ -z "${PACKER_ROOT_PW}" ]; then
  echo "You must set the environment variable PACKER_ROOT_PW to the password for root."
  exit 1
fi

set -ex
if [ $(ls /tmp/root_keys/*.pub |wc -l) -eq 0 ]; then
  echo "No .pub files were found in /tmp/root_keys. At least 1 is required."
  exit 1
fi

userdel -f -r vagrant
rm -f /etc/sudoers.d/vagrant

rm -f /root/.ssh/*
mkdir /root/.ssh
chmod 700 /root/.ssh
cat /tmp/root_keys/*.pub > /root/.ssh/authorized_keys
rm -rf /tmp/root_keys
chmod 644 /root/.ssh/authorized_keys
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "${PACKER_ROOT_PW}" | passwd --stdin root
