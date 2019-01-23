#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

if [ -z "$VAGRANT_BOX_VERSION" ]; then
  echo "VAGRANT_BOX_VERSION must be set"
  exit 1
fi

if [ "$#" -ne 1 ]; then
  echo "usage: $0 [virtualbox|vmware|docker]"
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

../centos-common/build.sh $builder 7
