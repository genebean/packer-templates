#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"
cd $DIR

if [ "$1" = "-p" ]; then
  echo 'All builds will run in paralel starting in 5 seconds...'
  sleep 5

  for os in `ls */build-all.sh`; do
    ./${os} &
  done
else
  arg=''
  echo 'All builds will run in sequentially starting in 5 seconds...'
  sleep 5

  for os in `ls */build-all.sh`; do
    ./${os}
  done
fi
