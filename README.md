# Zivtech LAMP Development VM

This repository manages Zivtech's development virtual server. It has a number of
tools that we use to build Drupal sites. [Drush](https://github.com/drush-ops/drush)
is included as well as [Drush Fetcher](https://www.drupal.org/project/fetcher)
which is a tool used to sync copies of Drupal sites between environments.
There are also other useful features such as an Apache Solr server for easy integration with
[search api](https://drupal.org/project/search_api_solr) or
[apachesolr](https://drupal.org/project/apachesolr). By default this tool builds an
Ubuntu 16.04 server.  See [#customizing](Customizing This VM below).

## Features

- Automatically routes *.local.zivtech.com to the vm.
- [Mailhog](https://github.com/mailhog/MailHog) allows viewing of local mail at [http://mailhog.local.zivtech.com:8025](http://mailhog.local.zivtech.com:8025/)

## Installation

### Special note for macOS > 10.12 (Sierra)

Because Apple switched to the Apple Filesystem (APFS) format, NFS syncing will not correctly work. [You can follow the issue on Vagrant's Github issue tracker](https://github.com/hashicorp/vagrant/issues/8788).

Until a solution comes from vagrant, or a more workable solution is found on our end, we recommend using a separate disk image for running the VM. To set that up:

1. Open Disk Utility, and create a new image by selecting File > New Image > Blank Image.
1. Name the image as you wish, though a single string name will be less annoying for you later. Format it to Mac OS Extended (Journaled). *Not* case-sensitive and *not* APFS! The size should be at minimum 80GB, as that is the virtual size of our VM here.
1. Once the image is created, it should be automatically mounted.
1. You can now cd to your mounted image, which should be located at `/Volumes/YOUR_IMAGE_NAME`.

At this point, you can continue your install using the directions below.

### Dependencies

You must have [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org/)
installed first. 
If they are already installed, **update Vagrant and Virtualbox** before you continue.

The puppet dependencies are managed via
[librarian-puppet](https://github.com/rodjek/librarian-puppet) which can
automatically be managed for you if you install the
[vagrant-librarian-puppet](https://github.com/mhahn/vagrant-librarian-puppet) vagrant plugin.

Complete instructions below:

````bash
sudo gem install puppet facter hiera librarian-puppet --no-document
git clone https://github.com/zivtech/vagrant-development-vm.git myvm
cd myvm
librarian-puppet install
vagrant up
````
You should now have a working Virtual Server! Create a new Drupal site by running `drush fetcher-create yoursite`
(add the version of drupal as a second argument if you want Drupal 8!). Run `vagrant ssh` to get
into your VM.

**_NOTE FOR WINDOWS USERS:_** There are known issues with getting `librarian-puppet`
installed and running on windows and so for Windows users it is recommended that you
**DO NOT** follow the installation instructions below but instead download the
most recent full release via zip file from the
[releases page](https://github.com/zivtech/vagrant-development-vm/releases) instead
of installing that plugin or cloning the repository from source.  Then you can cd into
the directory and run vagrant up as normal.

## Customizing this VM <a name="customizing"></a>

Once this repository have been downloaded, running "vagrant up" from within this
directory will build the virtual server and provision it.  Two different categories
of customizations can be performed on the dev vm. First there are vagrant settings
such as Ubuntu version, local IP address, amount of RAM,
hostname, etc. The second are tunables in the virtual server configuration.

### Vagrant Settings
You can change settings
such as the IP address of the server and the server's hostname in by creating
a new file called `config.yaml` where you can define any value listed below
(see [default.config.yaml](https://github.com/zivtech/vagrant-development-vm/blob/master/default.config.yaml)
for formatting options.

- *hostname*: The hostname that gets set inside the VM. Defaults to `vm`.
- *private_ipv4*: The private IP to provision for this host. Defaults to `172.16.0.2`.
- *box*:The base box to use to build the puppet work on top of. Defaults to `zivtech/ubuntu-16.04-server-puppet-4`
- *memory*: The amount of memory (in megabytes) to provision. Defaults to `2048`.
- *sync_folder*: Set this to false in order to not mount the www folder in this
directory *inside* `/var/www` on the VM. Defaults to true.
- *sync_file_enabled_on_windows*: If we detect we are running on windows, whether
we should enable the sync folder. Note, this uses VirtualBox folder sharing which
is not compatible with symlinks and some other important features. Defaults to false.

### Server Configuration Settings

This project uses [puppet](https://puppetlabs.com/) to configure the virtual server.
Many of the common tunables for a Drupal server are set in
[hiera/common.yaml](https://github.com/zivtech/vagrant-development-vm/blob/master/hiera/hiera.yaml)
and they can be overridden by creating a new file at `hiera/custom.yaml`
and copying any line you would like to override into the second file.
Any parameter on any of the classes utilized in this setup can be overridden using
[hiera](http://docs.puppetlabs.com/hiera/1/), the settings in `hiera/custom.yaml` are
overrides needed by this project or settings listed there for your easy reference in
tuning the VM.

#### Fetcher Server Configuration
If you use a Fetcher Server, set its url as 'info_fetcher.config' 'host' in your hiera/custom.yaml file. See hiera/common.yaml.

## Common Issues

On non-windows host systems, Vagrant tries to mount a shared NFS directory to the host
machine (the physical computer). This has been known to fail in some cases. If you
receive errors about a failed mount remove the virtual machine with "vagrant destroy"
then create or edit a `config.yaml` file in the root of this project and add the
following line:

```` yaml
sync_folder: false
````
