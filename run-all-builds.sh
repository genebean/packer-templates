#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $DIR

if [ "$1" = "-p" ]; then
  echo 'All builds will run in paralel starting in 5 seconds...'
  sleep 5

  for os in `ls */build-all.sh |grep -v common`; do
    ./${os} &
  done
else
  arg=''
  echo 'All builds will run in sequentially starting in 5 seconds...'
  sleep 5

  for os in `ls */build-all.sh |grep -v common`; do
    ./${os}
  done
fi

echo
ls */boxes/
echo
