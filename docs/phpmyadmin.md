#phpMyAdmin

[phpMyAdmin](https://www.phpmyadmin.net/) is a free software tool written in PHP, intended to handle the administration of MySQL over the Web. phpMyAdmin supports a wide range of operations on MySQL and MariaDB.

phpMyAdmin is installed by default in the Zivtech Vagrant Development VM to help administer your MySQL Server databases and users.

##Accessing phpMyAdmin
phpMyAdmin has been setup to be accessed at an Apache VHost Alias /phpmyadmin. The default Vagrant settings will install phpMyAdmin so that it is accessible at the following URL:

    http://33.33.33.40/phpmyadmin/

The MySQL root user should be used to login. The default root user password is set to `root`.

_*Note:*_ Modify the IP address to whatever IP you set in your config.yaml file.