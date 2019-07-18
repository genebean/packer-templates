#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "usage: $0 [6|7]"
  exit 1
fi

case "$1" in
  6|7 )
    # this is the first part of each box's name
    box_prefix="centos-${1}"
    ;;
  * )
    echo "The only os versions that are currently supported are 6 and 7."
    exit 1
esac


DIR="$(cd "$(dirname "$0")" && pwd -P)"

# build base VM that is used for all boxes
packer build -force -except=vmware-base-${box_prefix} -var-file=template-base-vars.json $DIR/template-base.json || exit 1

# ensure the base box was built
if [ ! -f "output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf" ]; then
  echo "Error: can't find output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf"
  exit 1
fi

# build each box
for box in `cat ${DIR}/box-versions`; do
  packer build -force -except=vmware-vagrant-${box}-${box_prefix} -var-file=template-std-vars.json $DIR/template-${box}.json || exit 1

  # if the box still does not exist then fail.
  if [ ! -f "boxes/${box_prefix}-${box}-virtualbox.box" ]; then
    echo "building ${box_prefix}-${box}-virtualbox.box failed."
    exit 1
  fi

  echo "testing ${box_prefix}-${box}-virtualbox.box with Vagrant"
  sleep 2

  vagrant box add boxes/${box_prefix}-${box}-virtualbox.box --name ${box_prefix}-${box} -f  || exit 1
  vagrant init -m ${box_prefix}-${box}  || exit 1
  vagrant up || exit 1
  vagrant ssh -c 'cat /etc/motd' || exit 1
  sleep 2
  vagrant destroy -f || exit 1
  vagrant box remove ${box_prefix}-${box} -f || exit 1

  echo 'removing files made by Vagrant...'
  rm -rf .vagrant
  rm -f Vagrantfile
done

tree

echo 'all boxes built.'
