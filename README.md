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
	
# Windows Installation

1. Create a vangrant folder on your C drive.
a. C:\vagrant-projects\

2. Go to https://www.virtualbox.org/ to download and install the latest version of VirtualBox.

3. Go to http://downloads.vagrantup.com/ to download and install the latest version of Vagrant.

4. Uninstall your old version of vagrant and install the new version (if needed).

5. Reclone the repository.
a. Copy the url from the right-hand column on GitHub by clicking the clipboard icon.
b. In the cmd window, navigate to the vagrant folder you created in step 1.
c. Run "git clone (paste url of repository)".

6. Copy the contents of your old www file into the www directory of this freshly cloned version (if 

needed).
a. C:\vagrant-projects\vagrant-development-vm\www\

7. The file at www/apache2.conf/my.conf.default has default settings to get a web server up and 

running. If you want to restore the changes you made to the 000-default file that you saved in step 6, 

 move them to www/apache.conf/my.conf and delete www/apache2.conf/my.conf.default. (If needed).

8. Navigate to the cloned vagrant development folder, C:\vagrant-projects\vagrant-development-vm

9. Run "git submodule update --init" to clone Zivtech's Puppet scripts for provisioning the server.

10. Type "vagrant up" and let Vagrant download the server image and launch and provision the server.

11. Log into your virtual server by typing 'vagrant ssh'.
a. You'll get a message saying Windows does not support ssh and that you have to use PuTTY.
b. You will also be given the connection info you need to use PuTTY, something like:
Host: 127.0.0.1
Port: 2222
Username: vagrant
Private key: I:/vagrant.d/insecure_private_key (your path may be different)
c. The private key does not work with PuTTY as is, you need to convert it first.

12. Download PuTTYgen from http://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe

13. Open the PuTTYgen program
a. In the 'Conversions' menu, choose 'Import key'.
b. Import the key that vagrant installed, use the path found in step 11.
c. Once the key is imported, click 'Save private key' in the lower right corner.
d. Make sure to give it an extension of .ppk
e. Exit PuTTYgen.

14. Download PuTTY from http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe

15. Open the PuTTY program.
a. In the left-hand pane, expand the 'SSH' item and click on 'Auth'.
b. Click 'Browse' and locate the ppk key file you created in step 13.
c. In the left-hand pane, click the 'Session' item.
d. Add the 'Host Name' and 'Port' from step 11.
e. Save these settings as Vagrant.
f. Click 'Open'.
g. The PuTTY window should now be open.
h. When prompted for a login name, type "vagrant".

16. Once logged into the server, run "sudo apt-get update && sudo apt-get upgrade" in the PuTTY window 

to update the server's packages.
a. At some point in the process an ugly GUI will pop up and tell you that the GRUB loader was 

previously installed to a disk that no loner exists. It will give you the option to select one of the 

three known disk devices.
b. Hit the space bar to select the currently highlighted choice (/dev/sda (10632 MB; VBOX_HARDDISK).
c. Press 'Enter' to complete the selection.

17. When the update is complete, return to the cmd window.
a. Navigate to the vagrant development folder, C:\vagrant-projects\vagrant-devlopment-vm
b. Run "vagrant provision", to finish the build.

18. Create a database named 'drupal' owned by a user named 'drupal' with password 'drupal'.
a. In the PuTTY window, run "mysql -u root -p".
b. Press 'Enter' to pass a blank password. 
c. 'Welcome to the MySql monitor, etc, etc.'
d. Run the following commands in this order:
create database drupal;
create user drupal;
grant all on drupal.* to 'drupal'@'localhost' identified by 'drupal';
exit;

19. Install latest Drupal 7.
a. In the PuTTY window, run the following commands in this order:
cd /var/www
drush dl drupal-7.x
mv drupal-7.22 drupal
cd drupal
drush site-install standard --account-name=admin --account-pass=admin --

dburl=mysql://drupal:drupal@localhost/drupal

20. Open the apache config file
a. C:\vagrant-projects\vagrant-development-vm\puppet-modules\customsettings\files\apache2.conf
b. Comment out the third to last line, "Include sites-enabled/phpmyadmin" with #

21. Open a browser with the following url: http://33.33.33.40/drupal
a. You should see the default Drupal screen.
b. If you recevie a 404 error, you will need to deactivate myPHPadmin.

