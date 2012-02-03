Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
  config.vm.network :hostonly, "33.33.33.33"
  # This is the old syntax, use if you are on older version.
  #config.vm.provision :puppet, :module_path => "puppet/modules", :module_path => "puppet/modules", :manifest_path => "puppet/manifests", :manfiest_file => "base.pp"
  config.vm.provision :puppet do |puppet|
    puppet.module_path = "puppet/modules"
    # I get an error if I don't use the 'manifests' folder that contains base.pp. 
    # Upon testing this was still able to load the manifests listed in base.pp included in puppet/manifests 
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "base.pp"
  end
  config.vm.host_name = "DevVM"

  config.vm.customize ["modifyvm", :id, "--memory", "1024"]

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"
  #config.vm.share_folder "web-data", "/var/www", "./www"

end
