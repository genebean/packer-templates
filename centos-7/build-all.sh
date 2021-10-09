#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

rm -f boxes/*
rm -rf output-*

../el-common/build-all.sh centos 7
