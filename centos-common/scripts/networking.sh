#!/bin/sh -eux

major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

if [ "$major_version" -ge 6 ]; then
    # Fix slow DNS:
    # Add 'single-request-reopen' so it is included when /etc/resolv.conf is
    # generated
    # https://access.redhat.com/site/solutions/58625 (subscription required)
    echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network;
    service network restart;
    echo 'Slow DNS fix applied (single-request-reopen)';
fi

# Fix for https://github.com/CentOS/sig-cloud-instance-build/issues/38
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="yes"
EOF

# SSH fixes relted to networking
echo 'Setting UseDNS to no in sshd_config'
sed -i 's/^#UseDNS yes$/UseDNS no/' /etc/ssh/sshd_config
echo 'Disabling reverse DNS lookups for ssh'
cat >>/etc/sysconfig/sshd <<EOF

# Decrease connection time by preventing reverse DNS lookups
# (see https://lists.centos.org/pipermail/centos-devel/2016-July/014981.html
#  and man sshd for more information)
OPTIONS="-u0"
EOF
