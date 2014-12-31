#!/bin/bash

# Setup RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
su - vagrant -c '\curl -L https://get.rvm.io | sudo bash -s stable'
usermod -a -G rvm vagrant
su - vagrant -c 'rvm autolibs enable'

# Setup Ruby 1.9.3
su - vagrant -c 'rvm install 1.9.3'
