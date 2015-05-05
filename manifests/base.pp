# Puppet whines and compains if it doesn't have
# its puppet users  and apt throws a fit if it's out of date,
# so we take care of these things first.

stage { 'first': before => Stage['main'] }

class {
  'vagrant_setup': stage => first;
  'vagrantvm': stage => main;
}

class vagrantvm {
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

  class { "solr":
  }

  drush::config { 'fetcher-class':
    file  => 'fetcher_services',
    key   => "fetcher']['info_fetcher.class",
    value => 'FetcherServices\InfoFetcher\FetcherServices',
  }

  drush::config { 'fetcher-services-host':
    file  => 'fetcher_services',
    key   => "fetcher']['info_fetcher.config']['host",
    value => 'https://extranet.zivtech.com',
  }

  drush::config { 'patch-file':
    value => 'patches.make',
  }

  file { '/etc/apache2/site-available':
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['drupal_php'],
  }

  file { '/etc/apache2/site-enabled':
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['drupal_php'],
  }

  include drupal_php
  include drush
  include drush_fetcher
  include drushphpsh
  include drush-patchfile
  include mysql::server

  $mysql_root_password = hiera('mysql::server::root_password')

  file { '/home/vagrant/.my.cnf':
    content => "[client]\nuser=root\nhost=localhost\npassword='${mysql::server::root_password}'\n",
    owner   => 'vagrant',
    group   => 'vagrant',
  }

  include redis
}

include vagrant_setup
include vagrantvm
