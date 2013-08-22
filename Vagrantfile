# -*- mode: ruby -*-
# vi: set ft=ruby :

# Include our deploy command.
# require File.dirname(__FILE__) + '/ssh-add.rb'

Vagrant.configure('2') do |config|

  config.vm.define "local" do |config|
    # Things you might want to modify!
    config.vm.hostname = "local"

    config.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ['modifyvm', :id, '--memory', '2048']
    end

    #config.vm.provider.customize ['modifyvm', :id, '--memory', '2048']
    config.vm.network :private_network, ip: "33.33.33.40"

    config.vm.box = "precise-vbox-4.2.4"
    config.vm.box_url = "http://fattony.zivtech.com/files/precise-vbox-4.2.4.box"

    # config.ssh.forward_agent = true

    config.vm.provision :puppet do |puppet|
      puppet.module_path = "puppet-modules"
      puppet.manifests_path = "puppet-manifests"
      puppet.manifest_file = "base.pp"
    end

    # NFS sharing does not work on windows, so if this is windows don't try to start it.
    require 'rbconfig'
    is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
    if not is_windows
      config.vm.synced_folder "www", "/var/www",  :nfs => true
    else
      config.vm.synced_folder "www", "/var/www"
    end
  end
end
