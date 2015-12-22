#Installation of the Zivtech Vagrant Development VM

You must have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed first. The puppet dependencies are managed via [librarian-puppet]((https://github.com/rodjek/librarian-puppet)) which can automatically be managed for you if you install the [vagrant-librarian-puppet](https://github.com/mhahn/vagrant-librarian-puppet) vagrant plugin.

_*NOTE FOR WINDOWS USERS:*_ There are known issues with getting librarian-puppet installed and running on windows and so for Windows users it is recommended that you *DO NOT* follow the installation instructions below but instead download the most recent full release via zip file from the [releases page](https://github.com/zivtech/vagrant-development-vm/releases) instead of installing that plugin or cloning the repository from source. Then you can cd into the directory and run vagrant up as normal.

Complete instructions below:

    vagrant plugin install vagrant-librarian-puppet
    git clone https://github.com/zivtech/vagrant-development-vm.git myvm
    cd myvm
    vagrant up

You should now have a working Virtual Server!