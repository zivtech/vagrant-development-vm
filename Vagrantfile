Vagrant::Config.run do |config|

  # Things you might want to modify!
  config.vm.host_name = "local"
  config.vm.customize ["modifyvm", :id, "--memory", "2048"]
  config.vm.network :hostonly, "33.33.33.40"

  config.vm.box = "precise-base-4.1.20"
  config.vm.box_url = "http://fattony.zivtech.com/files/precise-base-vbox-4.1.20.box"

  config.ssh.forward_agent = true

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "puppet-modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "base.pp"
  end
  # NFS sharing does not work on windows, so if this is windows don't try to start it.
  if not RUBY_PLATFORM.downcase.include?("mswin")
    config.vm.share_folder("web", "/var/www", "www", :nfs => true)
  end
end
