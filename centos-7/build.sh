#!/bin/bash

#DIR="$(dirname "$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$0")")"
DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

if [ "$#" -ne 1 ]; then
  echo "$0 requires a builder to be passed in."
  exit 1
fi

case "$1" in
  virtualbox|vmware|docker )
    builder=$1
    ;;
  * )
    echo "The only builders that are currently supported are virtualbox, vmware, and docker."
    exit 1
esac

# this is the first part of each box's name
box_prefix='centos-7'
docker_user='genebean'

# build base VM that is used for all boxes
packer build -force -only=${builder}-base-${box_prefix} template-base.json

if [ "${builder}" == "docker" ]; then
  echo 'testing Docker image...'
  docker run --name ${box_prefix}-base-hello-world ${docker_user}/${box_prefix}-base /bin/cat /etc/motd || exit 1
  docker rm ${box_prefix}-base-hello-world
  sleep 2
else
  # ensure the base box was built
  case ${builder} in
          "virtualbox")
                  base_extension='ovf'
                  ;;
          "vmware")
                  base_extension='vmx'
                  ;;
          *)
                  echo "Not sure what extension the ${builder} builder creates... update the case statement in build.sh"
                  exit 1
                  ;;
  esac
  if [ ! -f "output-${builder}-base-${box_prefix}/packer-${builder}-base-${box_prefix}.${base_extension}" ]; then
    echo "Error: can't find output-${builder}-base-${box_prefix}/packer-${builder}-base-${box_prefix}.${base_extension}"
    exit 1
  fi
fi


# build each box
for box in `cat ${DIR}/box-versions`; do
  if [ "${builder}" == "docker" ]; then
    packer build -force -only=${builder}-${box}-${box_prefix} template-${box}.json

    echo 'testing Docker image...'
    docker run --name ${box_prefix}-${box}-hello-world ${docker_user}/${box_prefix}-${box} /bin/echo 'Hello world' || exit 1
    docker rm ${box_prefix}-${box}-hello-world
    sleep 2
  else
    packer build -force -only=${builder}-vagrant-${box}-${box_prefix} template-${box}.json

    # check if the box was built
    if [ ! -f "boxes/${box_prefix}-${box}-${builder}.box" ]; then
      # if the box wasn't built try one more time before failing
      echo "trying again to build ${box_prefix}-${box}-${builder}.box"
      packer build -force -only=${builder}-vagrant-${box}-${box_prefix} template-${box}.json
    fi

    # if the box still does not exist then fail.
    if [ ! -f "boxes/${box_prefix}-${box}-${builder}.box" ]; then
      echo "building ${box_prefix}-${box}-${builder}.box failed."
      exit 1
    fi

    echo "testing ${box_prefix}-${box}-${builder}.box with Vagrant"
    sleep 2

    vagrant box add boxes/${box_prefix}-${box}-${builder}.box --name ${box_prefix}-${box} -f  || exit 1
    vagrant init -m ${box_prefix}-${box}  || exit 1
    vagrant up || exit 1
    vagrant ssh -c 'cat /etc/motd' || exit 1
    sleep 2
    vagrant destroy -f || exit 1
    vagrant box remove ${box_prefix}-${box} -f || exit 1

    echo 'removing files made by Vagrant...'
    rm -rf .vagrant
    rm -f Vagrantfile
  fi

done

if [ "${builder}" == "docker" ]; then
  docker images
else
  tree
fi

echo 'all boxes built.'
