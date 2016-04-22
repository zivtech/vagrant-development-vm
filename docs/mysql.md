#MySQL

The MySQL version is installed by default for the Ubuntu distribution you choose to install.

##Versions

14.04 installs the mysql-server-5.6 package.

12.04 installs the mysql-server-5.5 package.

##Root Password
The root user is used to login to the MySQL server. 

The root password is:

    root

##MySQL Settings

The following settings are set with Puppet through Hiera in the [hiera/common.yaml](https://github.com/zivtech/vagrant-development-vm/blob/master/hiera/common.yaml) file. They can be overridden by adding a new hiera/custom.yaml file and customizing the settings as needed. You can also set any other MySQL settings variables as needed for your custom setup.

mysql::server::root_password: 'root'