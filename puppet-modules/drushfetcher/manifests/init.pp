# Inherit from drush because we can't do anything without it
# and because we want to ensure that the shared commands folder
# exists and can't redeclare it.
class drushfetcher ($fetcher_host) inherits drush {

  vcsrepo { "/usr/share/drush/commands/drush_fetcher":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/fetcher.git",
    revision => 'b36176861e6eab94e55c1a6a484ed090bd14270a',
  }

  vcsrepo { "/usr/share/drush/commands/fetcher_services":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/fetcher_services.git",
  }

  file { "/etc/drush":
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => 755,
  }

  file { "/etc/drush/drushrc.php":
    require => File['/etc/drush'],
    mode => 755,
    content => template("drushfetcher/drushrc.php.erb"),
    owner => 'root',
    group => 'root',
  }

}
