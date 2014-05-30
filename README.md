# Zivtech

## About

This repository manages Zivtech's development virtual server. It has a number of
tools that Zivtech uses to help build Drupal sites. Drush is included as well as
Drush Fetcher which is a tool used to sync copies of Drupal sites between
environments. There are also other useful features such as a solr server for
Drupal search integration.

## Installation

You must have [Vagrant](http://vagrantup.com) and [VirtualBox](https://www.virtualbox.org/) installed first.

````bash
git clone --recrusive https://github.com/zivtech/vagrant-development-vm.git
git submodule update --init # Note this part isn't necessary if you included the `--recursive` option above.
vagrant up
````

*NOTE:* This repository has several git submodules that you will need before the
installation will complete. Run "git submodule update --init" from within this
directory to get the required sub-projects.


Once the repositories have been downloaded, running "vagrant up" from within this
directory will build the virtual server and provision it. You can change settings
such as the IP address of the server and the server's name in the VagrantFile.

After the server has been built it is a good idea to update the packages. Log in
to the server over SSH. The username and password are both "vagrant". Run
"sudo apt-get update && sudo apt-get upgrade" to update the server's packages.
When this is completed back on the command line in this directory run
"vagrant provision" to finish the build.

You should now have a working Virtual Server.

The default server hostname is `local` and the default IP is `33.33.33.40`.

## Issues

Vagrant tries to mount a shared NFS directory to the host machine (the physical
computer). This has been known to fail in some cases. If you receive errors
about a failed mount remove the virtual machine with "vagrant destroy" then
comment out the line that sets this up in the VagrantFile by placing a # at the
beginning of the line:

    #config.vm.share_folder("web", "/var/www", "www", :nfs => true)
