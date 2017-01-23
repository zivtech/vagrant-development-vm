#!/usr/bin/env ruby
#^syntax detection

forge "https://forge.puppet.com"

mod 'puppetlabs-git'
mod 'puppetlabs-vcsrepo'
mod 'puppetlabs-mysql'
mod 'puppetlabs-gcc'
mod 'puppetlabs-apt'
mod 'puppetlabs-nodejs'

mod 'maestrodev-wget'

mod 'saz-memcached'
mod 'rodjek-logrotate'

mod 'zivtech-drush_fetcher'
#mod 'zivtech-drupal_php'
mod 'zivtech-drupal_solr'

mod 'zivtech-drush',
  :git => "git://github.com/zivtech/puppet-drush.git",
  :ref => 'php7'

mod 'zivtech-drupal_php',
  :git => "git://github.com/zivtech/puppet-drupal-php.git",
  :ref => 'php7'

mod 'zivtech-webadmin',
  :git => "git://github.com/zivtech/puppet-webadmin.git",
  :ref => 'master'
