# PHP

PHP is installed by default for the Ubuntu distribution you choose to install.

## Versions

14.04 installs the php5 (5.6.x) package.

12.04 installs the php5 (5.3.x) package.

## PHP Settings

The following settings are set with Puppet through Hiera in the [hiera/common.yaml](https://github.com/zivtech/vagrant-development-vm/blob/master/hiera/common.yaml) file. They can be overridden by adding a new hiera/custom.yaml file and customizing the settings as needed. You can also set any other PHP settings variables as needed for your custom setup.

drupal_php::log_errors: true

drupal_php::memory_limit: 128M

drupal_php::max_execution_time: 30

drupal_php::post_max_size: '8M'

drupal_php::upload_max_filesize: 200M

drupal_php::display_errors : 'On'

drupal_php::log_errors: 'On'

drupal_php::timezone: 'America/New_York'
