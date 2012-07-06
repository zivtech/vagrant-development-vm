class drush {

  package { "php5-cli":
  	ensure => installed,
  }

  vcsrepo { "/var/lib/drush":
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/drush.git",
    revision => 'f3b05d6e4f40cb1bb86e75ed57272e21c0b8aee6',
  }

  file { "/var/lib/drush/lib/Console_Table-1.1.3":
    require => Vcsrepo["/var/lib/drush"],
    recurse => true,
    source => "puppet:///modules/drush/Console_Table-1.1.3",
  }

  file { "/usr/local/bin/drush":
    require => Vcsrepo["/var/lib/drush"],
    ensure => link,
    target => "/var/lib/drush/drush",
    owner => root,
    group => root,
    mode => 755,
  }

}
