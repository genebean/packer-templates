#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "usage: $0 [username] [version]"
  exit 1
fi

username=$1
version=$2
datestring=$(date +"%Y%m%d")

for box in `ls boxes/*.box |cut -d '/' -f2 |cut -d '.' -f1`; do
  revbox=$(echo ${box} |rev)
  provider=$(echo ${revbox} |cut -d '-' -f1 |rev)
  boxname=$(echo ${revbox} |cut -d '-' -f2- |rev)

  vagrant cloud publish --release --force ${username}/${boxname} ${version}.${datestring} ${provider} boxes/${box}.box
done

