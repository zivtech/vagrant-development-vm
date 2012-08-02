class ignitiondrush {

  file { "/usr/share/drush":
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }

  file {  "/usr/share/drush/commands":
    require => File['/usr/share/drush'],
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }

  vcsrepo { "/var/lib/drush":
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/drush.git",
    revision => 'f3b05d6e4f40cb1bb86e75ed57272e21c0b8aee6',
  }

  vcsrepo { "/usr/share/drush/commands/drush_fetcher":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/sandbox/tizzo/1703334.git",
    revision => '94d635c',
  }

}
