#! /usr/bin/env bash

echo "Enter your sudo password."
echo "Installing puppet, facter, hiera, and librarian-puppet gems without documentation..."
sudo gem install puppet facter hiera librarian-puppet --no-document
echo "Installing Puppet modules with librarian-puppet..."
librarian-puppet install
echo "Running vagrant up..."
vagrant up
