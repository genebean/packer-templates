#!/bin/bash
rvm_versions=(jruby-9.2 jruby-9.1 2.6.0 2.5.1 2.4.1 2.2.1 1.9.3)
rvm_default_version='2.5.1'
# Make sure gpg folder is created before actually doing stuff with gpg
gpg2 --list-keys
# Setup RVM
curl -#OL https://rvm.io/mpapis.asc || exit 1
curl -#OL https://rvm.io/pkuczynski.asc || exit 1
gpg2 --import mpapis.asc || exit 1
gpg2 --import pkuczynski.asc || exit 1

su - vagrant -c '\curl -L https://get.rvm.io | sudo bash -s stable' || exit 1

# Verify RVM install
su - vagrant -c 'rvm -v' || exit 1

usermod -a -G rvm vagrant || exit 1
su - vagrant -c 'rvm autolibs enable' || exit 1

# Setup MOTD
motd='/etc/motd'
motd_first_row="Multi-RVM"

figlet -w 80 -c -f slant "${motd_first_row}" > $motd || exit 1
figlet -w 80 -c -f slant "by GeneBean" >> $motd || exit 1
echo $(printf 'RVM versions:') |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1

# Install Java for JRuby
yum -y install java-1.8.0-openjdk

# Setup Ruby
for rvm_version in ${rvm_versions[@]}; do
  echo
  su - vagrant -c "rvm install ${rvm_version}" || exit 1
  echo
  echo
  su - vagrant -c "rvm --default use ${rvm_version}" || exit 1
  case $rvm_version in
    jruby-* )
      echo 'Checking JRuby install'
      su - vagrant -c 'jruby -v' || exit 1
      v=`su - vagrant -c 'jruby -v' |cut -d ' ' -f2,3`
      if [ ${rvm_version} == ${rvm_default_version} ]; then
        echo "JRuby ${v} -- default" |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> ${motd} || exit 1
      else
        echo "JRuby ${v}" |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> ${motd} || exit 1
      fi
      ;;
    *)
      echo 'Checking Ruby install'
      su - vagrant -c 'ruby -v' || exit 1
      v=`su - vagrant -c 'ruby -v' |cut -d ' ' -f2`
      if [ ${rvm_version} == ${rvm_default_version} ]; then
        echo "Ruby ${v} -- default" |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> ${motd} || exit 1
      else
        echo "Ruby ${v}" |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> ${motd} || exit 1
      fi
      ;;
  esac
  echo
done

# Set default version of Ruby to be used
echo "Setting RVM ${rvm_default_version} as the default"
su - vagrant -c "rvm --default use ${rvm_default_version}" || exit 1

echo $(printf 'Created on '; date +"%a %B %d, %Y") |perl -pe '$sp = " " x ((80 - length) / 2); s/^/$sp/' >> $motd || exit 1
echo >> $motd || exit 1

echo 'Testing the MOTD...'
echo
cat $motd || exit 1
