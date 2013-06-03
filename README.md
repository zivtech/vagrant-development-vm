# ILR

If you installed this repo rpeviously and used a version of Vagrant before 1.1, then don't pull down any changes unless you are prepared to update your version of Vagrant.

Here is what you should do when you're ready to update:

There is no way to gracefully save the changes you may have made to your current virtual machine, so you need to start over. The easiest course is to just start over from scratch (in whihc case you can just skip dow to the standard Zivtech instructions from here), but if you have a lot of work on your current machine that you really want to save, here are the steps.

1. Start your current vagrant virtual machine by typing 'vagrant up'
2. Say you're machine's ip is 33.33.33.40. Go to http://33/33/33/40/phpmyadmin.
3. Export all of your databases to a file in your local file system. You will need these to restore after the upgrade.
4. Type 'vagrant ssh' to log into you virtual server and then type 'cat /etc/apache2/sites-enabled/000-default', which will output the contents of that file.
5. Log out of your virtual server and type 'vagrant halt' to stop it.
6. Rename the directory of your old vagrant site (which contains your Vagrant file and your www forlder)

You're now ready to upgrade vagrant and start over.

1. Go to http://downloads.vagrantup.com/ and downlaod and install the latest version of Vagrant
2. Uninstall your old version of vagrant and install the new version
3. Reclone this repositpory.
4. Copy the contents of your old www file into the www directory of this freshly cloned version
5. The file at www/apache2.conf/my.conf.default has default settings to get a web server up and running. If you want to restore the changes you made to the 000-default file that you saved in step 4 above, then move them to www/apache.conf/my.conf and delete www/apache2.conf/my.conf.default.
6. Run "git submodule update --init" to clone Zivtech's Puppet scripts for provisioning the server
7. Type 'vagrant up' and let Vagrant download the server image and launch and provision the server
8. Log into your virtual server by typing 'vagrant ssh' and once logged in, run "sudo apt-get update && sudo apt-get upgrade" to update the server's packages.
9. When this is completed back on the command line in this directory run "vagrant provision" to finish the build.
10. Once this is done, got to http://33/33/33/40/phpmyadmin and import the databases that you exported in step 3 above.
11. Create the users that your Drupal config files use to connect to their database and grant them rights to the appropriate databses.
12. Test to make sure that you can see your old Drupal installs.


# Zivtech

## About

This repository manages Zivtech's development virtual server. It has a number of
tools that Zivtech uses to help build Drupal sites. Drush is included as well as
Drush Fetcher which is a tool used to sync copies of Drupal sites between
environments. There are also other useful features such as a solr server for
Drupal search integration.

## Installation

You must have [Vagrant](http://vagrantup.com) and [VirtualBox](https://www.virtualbox.org/) installed first.

This repository has several git submodules that you will need before the
installation will complete. Run "git submodule update --init" from within this
directory to get the required sub-projects.

Once the repositories have been downloaded run "vagrant up" from within this
directory. This will build the virtual server and provision it. You can change
some settings such as the IP address of the server and the server's name in the
VagrantFile.

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
