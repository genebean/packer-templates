#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"
cd $DIR

rm -f boxes/*
rm -rf output-*

# this is the first part of each box's name
box_prefix='centos-6'

# build base VM that is used for all boxes
packer build -except=vmware-base-${box_prefix} template-base.json

# ensure the base box was built
if [ ! -f "output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf" ]; then
  echo "Error: can't find output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf"
  exit 1
fi

# build each box
for box in 'nocm' 'puppet' 'puppet-agent' 'rvm-193' 'rvm-221'; do
  packer build -except=vmware-vagrant-${box}-${box_prefix} template-${box}.json

  # check if the box was built
  if [ ! -f "boxes/${box_prefix}-${box}-virtualbox.box" ]; then
    # if the box wasn't built try one more time before failing
    echo "trying again to build ${box_prefix}-${box}-virtualbox.box"
    packer build -except=vmware-vagrant-${box}-${box_prefix} template-${box}.json
  fi

  # if the box still does not exist then fail.
  if [ ! -f "boxes/${box_prefix}-${box}-virtualbox.box" ]; then
    echo "building ${box_prefix}-${box}-virtualbox.box failed."
    exit 1
  fi

  echo "testing ${box_prefix}-${box}-virtualbox.box with Vagrant"
  sleep 2

  vagrant box add boxes/${box_prefix}-${box}-virtualbox.box --name ${box_prefix}-${box} -f
  vagrant init -m ${box_prefix}-${box}
  vagrant up
  sleep 2
  vagrant destroy -f
  vagrant box remove ${box_prefix}-${box} -f

  echo 'removing files made by Vagrant...'
  rm -rf .vagrant
  rm -f Vagrantfile
done

tree

echo 'all boxes built.'
