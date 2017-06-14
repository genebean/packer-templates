#!/bin/bash
#DIR="$(dirname "$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$0")")"
DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

# this is the first part of each box's name
box_prefix='centos-7'
docker_user='genebean'

# build base VM that is used for all boxes
packer build -force -except=vmware-base-${box_prefix} template-base.json
echo 'testing Docker image...'
docker run --name ${box_prefix}-base-hello-world ${docker_user}/${box_prefix}-base /bin/cat /etc/motd || exit 1
docker rm ${box_prefix}-base-hello-world

# ensure the base box was built
if [ ! -f "output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf" ]; then
  echo "Error: can't find output-virtualbox-base-${box_prefix}/packer-virtualbox-base-${box_prefix}.ovf"
  exit 1
fi

# build each box
for box in `cat ${DIR}/box-versions`; do
  packer build -force -except=vmware-vagrant-${box}-${box_prefix} template-${box}.json

  # check if the box was built
  if [ ! -f "boxes/${box_prefix}-${box}-virtualbox.box" ]; then
    # if the box wasn't built try one more time before failing
    echo "trying again to build ${box_prefix}-${box}-virtualbox.box"
    packer build -force -except=vmware-vagrant-${box}-${box_prefix} template-${box}.json
  fi

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

  echo 'testing Docker image...'
  docker run --name ${box_prefix}-${box}-hello-world ${docker_user}/${box_prefix}-${box} /bin/echo 'Hello world' || exit 1
  docker rm ${box_prefix}-${box}-hello-world
done

tree
docker images

echo 'all boxes built.'
