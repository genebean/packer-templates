#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd -P)"

version=$1
user='genebean'
os='centos-6'

# test for proper version formatting

for i in `cat ${DIR}/box-versions`; do
  docker tag ${user}/${os}-$i ${user}/${os}-$i:${version}
done

docker images ${user}/*
echo
echo
echo '**********************************************************************************'
echo 'Make sure the list above is correct.'
echo "If it isn't then be sure to hit ^c quick"
echo "In 60 seconds all of the ${os} ${version}"
echo 'images will get pushed to docker.io'
echo '**********************************************************************************'
sleep 60

for i in `cat ${DIR}/box-versions`; do
  docker push ${user}/${os}-$i:${version}
  docker push ${user}/${os}-$i:latest
done
