#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

../centos-common/build-all.sh 6
