#! /usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'rbconfig'

params = YAML::load_file(File.join(__dir__, 'default.config.yaml'))

# Load new configuration files.
begin
  params = params.merge YAML::load_file(File.join(__dir__, 'config.yaml'))
rescue
  # The customization file didn't exist - no worries.
end

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

# Include our deploy command.
require File.join(__dir__, '/ssh-add.rb') unless is_windows

Vagrant.configure('2') do |config|

  config.vm.hostname = params['hostname']

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', params['memory']]
  end

  #config.vm.network :private_network, ip: params[:private_ip]
  config.vm.network :private_network, ip: params['private_ip']

  config.vm.box = params['box']
  config.vm.box_url = params['box_url']

  config.ssh.forward_agent = true

  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision :shell, inline: "/bin/sed -i '/templatedir/d' /etc/puppet/puppet.conf"

  # The puppetlabs vm comes with a puppet.conf that includes a deprecated
  # config directive, delete it to avoid confusing users.
  config.vm.provision :shell, :inline => "/bin/sed -i '/templatedir=\(.*\)/d' /etc/puppet/puppet.conf"

  if Vagrant.has_plugin?("vagrant-librarian-puppet")
    config.librarian_puppet.placeholder_filename = 'README.md'
  elsif not File.exist?(File.join(__dir__, 'modules', 'drupal_php', 'manifests', 'init.pp'))
    raise Vagrant::Errors::VagrantError.new, "You are not using vagrant-librarian-puppet and have not installed the dependencies."
  end

  # If vagrant-cachier is installed, use it!
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    if not is_windows
      # See https://github.com/fgrehm/vagrant-cachier for details.
      config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end
  end

  # NFS sharing does not work on windows, so if this is windows don't try to start it.
  vagrant_share_www = "false"
  if not is_windows and params['sync_folder']
    config.vm.synced_folder 'www', '/var/www', :nfs => true
    vagrant_share_www = "true"
  elsif params['sync_file_enabled_on_windows']
    # This uses VirtualBox shared folders and symlinks will not work properly.
    config.vm.synced_folder 'www', '/var/www'
    vagrant_share_www = "true"
  end


  config.vm.provision :puppet do |puppet|
    puppet.module_path = [
      'modules',
      'custom-modules'
    ]
    puppet.facter = {
      "vagrant" => "1",
      "vagrant_share_www" => vagrant_share_www
    }
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = 'base.pp'
    puppet.hiera_config_path = 'hiera/hiera.yaml'
    puppet.working_directory = '/vagrant'
  end


end
