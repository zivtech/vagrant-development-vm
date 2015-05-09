# Puppet whines and compains if it doesn't have
# its puppet users  and apt throws a fit if it's out of date,
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
    webadminuser => $user,
    webadmingroup => $group,
  }

  class { 'mail::dev':
    dev_mail => "${user}@${hostname}",
    require => Class['webadmin'],
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

  include drupal_php
  include drupal_solr

  include mysql::server

  include drush
  include drush_fetcher
  include drushphpsh
  include drush_patchfile

  include redis

  file { '/home/vagrant/.my.cnf':
    content => "[client]\nuser=root\nhost=localhost\npassword='${mysql::server::root_password}'\n",
    owner   => 'vagrant',
    group   => 'vagrant',
  }

}

include vagrant_setup
include vagrant_vm
