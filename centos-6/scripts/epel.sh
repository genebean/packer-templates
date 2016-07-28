yum -y install epel-release
if [ "$PACKER_BUILDER_TYPE" != "docker" ]; then
  yum -y install dkms
fi
