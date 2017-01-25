#! /usr/bin/env bash

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update
apt-get install puppet-agent
ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
rm puppetlabs-release-pc1-xenial.deb
