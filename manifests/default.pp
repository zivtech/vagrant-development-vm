# Puppet whines and complains if it doesn't have
# its puppet users and apt throws a fit if it's out of date,
# so we take care of these things first.

/*
stage { 'first': before => Stage['main'] }
class {
  'vagrant_setup': stage => first;
  'vagrant_vm': stage => main;
}

*/


class vagrant_vm {
  $user = 'vagrant'
  $group = 'vagrant'

  class { 'webadmin':
    webadminuser  => $user,
    webadmingroup => $group,
  }

  /*
  class { 'mail::dev':
    dev_mail => "${user}@${hostname}",
    require => Class['webadmin'],
  }
  */

  # If the folder is mounted via NFS we can't change the perms anyway,
  # but if it is not we want to make it owned by the `vagrant`.
  if ($vagrant_share_www == 'false') {
    file { '/var/www':
      owner   => $user,
      group   => $group,
      require => Class['drupal_php'],
    }
  }
/*

  file { '/etc/apache2/sites-available':
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['drupal_php'],
  }

  file { '/etc/apache2/sites-enabled':
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['drupal_php'],
  }

*/
include drupal_php

/*
  class { '::php':
    fpm      => false,
    settings => {
      'PHP/max_execution_time'  => '90',
      'PHP/max_input_time'      => '300',
      'PHP/memory_limit'        => '64M',
      'PHP/post_max_size'       => '32M',
      'PHP/upload_max_filesize' => '32M',
      'Date/date.timezone'      => 'Europe/Berlin',
    },
    extensions => {
      #'curl' => {},
      imagick   => {
        provider => pecl,
      },
      xmlrpc    => {},
    }
  }
  */
/*
  include drupal_solr
  */
  include mysql::server
  /*

  include drush
  include drush_fetcher
  include drush_phpsh
  include drush_patchfile
  include drupal_permissions
  include terminus
  include redis

  file { '/home/vagrant/.my.cnf':
    content => "[client]\nuser=root\nhost=localhost\npassword='${mysql::server::root_password}'\n",
    owner   => 'vagrant',
    group   => 'vagrant',
  }

*/
  include phpmyadmin

  package { 'git-sh':
    ensure => 'installed',
  }

  class { 'nodejs': }->
  file { '/usr/bin/node':
    ensure => 'link',
    target => '/usr/bin/nodejs'
  } 
}

#include vagrant_setup
include vagrant_vm

