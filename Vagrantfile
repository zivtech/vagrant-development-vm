#! /usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'rbconfig'
 
# Load new configuration files.
begin
  params = YAML::load_file('./config.yaml')
rescue
  params = YAML::load_file('./default.config.yaml')
end

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

# Include our deploy command.
if not is_windows
  require File.dirname(__FILE__) + '/ssh-add.rb'
end

Vagrant.configure('2') do |config|

  config.vm.hostname = params[:hostname]

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', params[:memory]]
  end

  config.vm.network :private_network, ip: params[:private_ip]

  config.vm.box = params['box']

  config.ssh.forward_agent = true

  # The puppetlabs vm comes with a puppet.conf that includes a deprecated
  # config directive, delete it to avoid confusing users.
  config.vm.provision :shell, :inline => "/bin/sed -i '/templatedir=\(.*\)/d' /etc/puppet/puppet.conf"

  #config.librarian_puppet.placeholder_filename = 'README'
  config.vm.provision :puppet do |puppet|
    puppet.module_path = [
      'modules',
      'custom-modules'
    ]
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = 'base.pp'
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.working_directory = '/vagrant'
  end


  # NFS sharing does not work on windows, so if this is windows don't try to start it.
  if not is_windows and params[:sync_folder]
    config.vm.synced_folder 'www', '/var/www', :nfs => true
  elsif params[:sync_file_enabled_on_windows]
    # This uses VirtualBox shared folders and symlinks will not work properly.
    config.vm.synced_folder 'www', '/var/www'
  end
end
