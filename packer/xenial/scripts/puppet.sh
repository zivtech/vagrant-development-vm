# Prepare puppetlabs repo
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get update

# Install puppet/facter
apt-get install -y puppet facter
