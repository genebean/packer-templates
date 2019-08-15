#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"

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

# the list of builders that are enabled.
builders=(virtualbox vmware)

# ensure the base boxes were built
test_base_boxes_built() {
  box_prefix=$1

  for builder in "${builders[@]}"; do
    case ${builder} in
      "virtualbox")
        base_extension='ova'
        ;;
      "vmware")
        base_extension='vmx'
        ;;
      *)
        echo "Not sure what extension the ${builder} builder creates... update the case statement in build-all.sh"
        return 1
        ;;
    esac

    output_dir="output-${builder}-base-${box_prefix}"
    box_file="packer-${builder}-base-${box_prefix}.${base_extension}"
    box_path="${output_dir}/${box_file}"

    if [ ! -f "${box_path}" ]; then
      echo "Error: can't find ${box_path}"
      return 1
    fi

    # generate the checksum used by remaining builders
    shasum -a 256 "${box_path}" |cut -d ' ' -f1 > "${output_dir}/sha256-checksum.txt" 
  done
}

test_with_vagrant() {
  box_prefix=$1
  box=$2

  for builder in "${builders[@]}"; do
    case ${builder} in
      "virtualbox")
        vagrant_provider='virtualbox'
        vagrant_up_provider='virtualbox'
        ;;
      "vmware")
        vagrant_provider='vmware_desktop'
        vagrant_up_provider='vmware_fusion'
        ;;
      *)
        echo "Not sure what extension the ${builder} builder creates... update the case statement in build.sh"
        exit 1
        ;;
    esac

    echo "testing ${box_prefix}-${box}-${builder}.box with Vagrant"
    sleep 2

    vagrant box add boxes/${box_prefix}-${box}-${builder}.box --name ${box_prefix}-${box} -f --provider ${vagrant_provider}  || return 1
    vagrant init -m ${box_prefix}-${box}  || return 1
    vagrant up --provider ${vagrant_up_provider} || return 1
    vagrant ssh -c 'cat /etc/motd' || return 1
    sleep 2
    vagrant destroy -f || return 1
    vagrant box remove ${box_prefix}-${box} -f --provider ${vagrant_provider} || return 1

    echo 'removing files made by Vagrant...'
    rm -rf .vagrant Vagrantfile
  done
}

# build base VM that is used for all boxes
packer build -force -var-file=template-base-vars.json $DIR/template-base.json || exit 1
test_base_boxes_built $box_prefix || exit 1

# build each box
for box in `cat ${DIR}/../${box_prefix}/box-versions`; do
  packer build -force -var-file=template-std-vars.json $DIR/template-${box}.json || exit 1
  test_with_vagrant $box_prefix $box || exit 1
done

tree -L 2 

echo 'all boxes built.'
