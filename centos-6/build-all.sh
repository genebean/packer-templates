#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

if [ -z "$VAGRANT_BOX_VERSION" ]; then
  echo "VAGRANT_BOX_VERSION must be set"
  exit 1
fi

../centos-common/build-all.sh 6
