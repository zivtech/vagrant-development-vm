# -*- mode: ruby -*-
# vi: set ft=ruby :

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

# Include our deploy command.
if not is_windows
  require File.dirname(__FILE__) + '/ssh-add.rb'
end

Vagrant.configure("2") do |config|

  # Things you might want to modify!
  config.vm.hostname = "local"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.network :private_network, ip: "33.33.33.40"

  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  config.ssh.forward_agent = true

  config.vm.provision :puppet do |puppet|
    config.librarian_puppet.placeholder_filename = "README"
    puppet.module_path = [
      "modules",
      "custom-modules"
    ]
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "base.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/vagrant"
  end
  # NFS sharing does not work on windows, so if this is windows don't try to start it.
  require 'rbconfig'

  if not is_windows
    config.vm.synced_folder "www", "/var/www", :nfs => true
  else
    # Uncomment this for windows file sharing. When using windows file sharing, symlinks will not work.
    # config.vm.synced_folder "www", "/var/www"
  end
end
