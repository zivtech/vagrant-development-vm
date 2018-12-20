# Puppet whines and complains if it doesn't have
# its puppet users and apt throws a fit if it's out of date,
# so we take care of these things first.

stage { 'first': before => Stage['main'] }
class {
  'vagrant_setup': stage => first;
  'vagrant_vm': stage => main;
}


class vagrant_vm {
  $user = 'vagrant'
  $group = 'vagrant'

  class { 'webadmin':
    webadminuser  => $user,
    webadmingroup => $group,
  }

  # If the folder is mounted via NFS we can't change the perms anyway,
  # but if it is not we want to make it owned by the `vagrant`.
  if ($vagrant_share_www == 'false') {
    file { '/var/www':
      owner   => $user,
      group   => $group,
      require => Class['drupal_php'],
    }
  }

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

  include mysql::server

  include drupal_php
  # todo: update drupal_solr
  #include drupal_solr

  include drush
  include drush_fetcher
  include drush_phpsh
  include drush_patchfile

  drush::config { 'fetcher_server_sapi':
    file  => 'fetcher',
    key   => "fetcher']['server.sapi",
    value => 'fpm',
  }

  drush::config { 'fetcher_server_fpm_url':
    file  => 'fetcher',
    key   => "fetcher']['server.fpm_url",
    value => '127.0.0.1:9001',
  }

  include drupal_permissions
  include terminus
  include redis
  include mailhog
  include wp_cli
  include nvm

  file { '/home/vagrant/.my.cnf':
    content => "[client]\nuser=root\nhost=localhost\npassword='${mysql::server::root_password}'\n",
    owner   => 'vagrant',
    group   => 'vagrant',
  }

  include phpmyadmin

  package { 'git-sh':
    ensure => 'installed',
  }
}

include vagrant_setup
include vagrant_vm
