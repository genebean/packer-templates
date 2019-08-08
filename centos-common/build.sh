#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"

if [ "$#" -ne 2 ]; then
  echo "usage: $0 [virtualbox|vmware] [6|7]"
  exit 1
fi

case "$1" in
  virtualbox|vmware )
    builder=$1
    ;;
  * )
    echo "The only builders that are currently supported are virtualbox, and vmware."
    exit 1
esac

case "$2" in
  6|7 )
    # this is the first part of each box's name
    box_prefix="centos-${2}"
    ;;
  * )
    echo "The only os versions that are currently supported are 6 and 7."
    exit 1
esac

# build base VM that is used for all boxes
packer build -force -only=${builder}-base-${box_prefix} -var-file=template-base-vars.json $DIR/template-base.json || exit 1

# ensure the base box was built
case ${builder} in
        "virtualbox")
                base_extension='ova'
                vagrant_provider='virtualbox'
                vagrant_up_provider='virtualbox'
                ;;
        "vmware")
                base_extension='vmx'
                vagrant_provider='vmware_desktop'
                vagrant_up_provider='vmware_fusion'
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

# generate the checksum used by remaining builders
shasum -a 256 "output-${builder}-base-${box_prefix}/packer-${builder}-base-${box_prefix}.${base_extension}" |cut -d ' ' -f1 > "output-${builder}-base-${box_prefix}/sha256-checksum.txt" 


# build each box
for box in `cat ${DIR}/../${box_prefix}/box-versions`; do
  packer build -force -only=${builder}-vagrant-${box}-${box_prefix} -var-file=template-std-vars.json $DIR/template-${box}.json || exit 1

  # if the box still does not exist then fail.
  if [ ! -f "boxes/${box_prefix}-${box}-${builder}.box" ]; then
    echo "building ${box_prefix}-${box}-${builder}.box failed."
    exit 1
  fi

  echo "testing ${box_prefix}-${box}-${builder}.box with Vagrant"
  sleep 2

  vagrant box add boxes/${box_prefix}-${box}-${builder}.box --name ${box_prefix}-${box} -f --provider ${vagrant_provider}  || exit 1
  vagrant init -m ${box_prefix}-${box}  || exit 1
  vagrant up --provider ${vagrant_up_provider} || exit 1
  vagrant ssh -c 'cat /etc/motd' || exit 1
  sleep 2
  vagrant destroy -f || exit 1
  vagrant box remove ${box_prefix}-${box} -f --provider ${vagrant_provider} || exit 1

  echo 'removing files made by Vagrant...'
  rm -rf .vagrant Vagrantfile
done

tree -L 2 

echo 'all boxes built.'
