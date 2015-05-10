# Zivtech LAMP Development VM

This repository manages Zivtech's development virtual server. It has a number of
tools that we use to build Drupal sites. [Drush](https://drupal.org/project/drush)
is included as well as [Drush Fetcher](https://drupal.org/project/drush_fetcher)
which is a tool used to sync copies of Drupal sites between environments.
There are also other useful features such as a solr server for easy integration with
[search api](https://drupal.org/project/search_api_solr) or
[apachesolr](https://drupal.org/project/apachesolr). By default this tool builds an
Ubuntu 14.04 server but 12.04 is also supported.  See [#customizing](Customizing This VM below).

## Installation

You must have [Vagrant](http://vagrantup.com) and [VirtualBox](https://www.virtualbox.org/)
installed first. The puppet dependencies are managed via
[librarian-puppet](https://github.com/rodjek/librarian-puppet) which can
automaticaally be managed for you if you install the
[vagrant-librarian-puppet](https://github.com/mhahn/vagrant-librarian-puppet) vagrant plugin.

**_NOTE FOR WINDOWS USERS:_** There are known issues with getting `librarian-puppet`
installed and running on windows and so for Windows users it is recommended that you
**DO NOT** follow the installation instructions below but instead download the
most recent full release via zip file from the
[releases page](https://github.com/zivtech/vagrant-development-vm/releases) instead
of installing that plugin or cloning the repository from source.  Then you can cd into
the directory and run vagrant up as normal.


Complete instructions below:

````bash
vagrant plugin install vagrant-librarian-puppet
git clone https://github.com/zivtech/vagrant-development-vm.git myvm
cd myvm
vagrant up
````
You should now have a working Virtual Server! Create a new Drupal site by running `drush fetcher-create yoursite`
(add the version of drupal as a second argument if you want Drupal 8!). Run `vagrant ssh` to get
into your VM.

<a name="customizing" />
## Customzing this VM

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

- *hostname*: The hostname that gets set inside the VM. Defaults to `local`.
- *private_ip*: The private IP to provision for this host. Defaults to `33.33.33.40`.
- *box*:The base box to use to build the puppet work on top of. Commetning out the
line below (or overriding in config,yaml) to switch to 12.04 should also work.
Defaults to `puppetlabs/ubuntu-14.04-64-puppet` though
`puppetlabs/ubuntu-12.04-64-puppet` is also supported.
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

## Common Issues

On non-windows host systems, Vagrant tries to mount a shared NFS directory to the host
machine (the physical computer). This has been known to fail in some cases. If you
receive errors about a failed mount remove the virtual machine with "vagrant destroy"
then create or edit a `config.yaml` file in the root of this project and add the
following line:

```` yaml
sync_folder: false
````
