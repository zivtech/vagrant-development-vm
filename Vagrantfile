Vagrant::Config.run do |config|
  config.vm.box = "precise-base"
  config.vm.box_url = "http://fattony.zivtech.com/files/precise-base.box"
  config.vm.network :hostonly, "33.33.33.40"

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "puppet/modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "base.pp"
  end
  config.vm.host_name = "DevVM"

  config.vm.customize ["modifyvm", :id, "--memory", "1024"]

end
