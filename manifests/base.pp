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

  notify { "PRINTING!!! ${my_message}": }

  class { "solr":
    webadmingroup => $webadmingroup,
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

  include drupal_php
  include drush
  include drush_fetcher
  include drushphpsh
  include drush-patchfile
  include mysql::server

  include redis
}

include vagrant_setup
include vagrantvm
