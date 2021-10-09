source /tmp/vars.sh

major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

if [ "$major_version" -ge 8 ]; then
  echo 'removing unneeded files and cache...'
  dnf clean all
  dnf makecache
else
  echo 'removing unneeded files and cache...'
  yum clean all
  yum makecache fast
fi
