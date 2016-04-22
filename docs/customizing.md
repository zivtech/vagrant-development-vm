#Customizing this VM

Once this repository have been downloaded, running "vagrant up" from within this
directory will build the virtual server and provision it.  Two different categories
of customizations can be performed on the dev vm. First there are vagrant settings
such as Ubuntu version, local IP address, amount of RAM,
hostname, etc. The second are tunables in the virtual server configuration.

##Vagrant Settings
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

##Server Configuration Settings

This project uses [Puppet](https://puppetlabs.com/) to configure the virtual server.
Many of the common tunables for a Drupal server are set in
[hiera/common.yaml](https://github.com/zivtech/vagrant-development-vm/blob/master/hiera/hiera.yaml)
and they can be overridden by creating a new file at `hiera/custom.yaml`
and copying any line you would like to override into the second file.
Any parameter on any of the classes utilized in this setup can be overridden using
[hiera](http://docs.puppetlabs.com/hiera/1/), the settings in `hiera/custom.yaml` are
overrides needed by this project or settings listed there for your easy reference in
tuning the VM.