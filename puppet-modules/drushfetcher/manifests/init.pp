# Inherit from drush because we can't do anything without it
# and because we want to ensure that the shared commands folder
# exists and can't redeclare it.
class drushfetcher ($fetcher_host) inherits drush {

  include wget
  wget::fetch { "Composer":
    source      => 'http://getcomposer.org/composer.phar',
    destination => '/usr/local/bin/composer',
    timeout     => 0,
    verbose     => false,
  }->
  file { '/usr/local/bin/composer':
    mode => 755,
  }

  vcsrepo { "/usr/share/drush/commands/drush_fetcher":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/fetcher.git",
    revision => '2d85462bdb443bf676882b28439a74b4e7f6eb88',
    notify   => Exec["/usr/bin/php /usr/local/bin/composer install"],
  }

  exec { "/usr/bin/php /usr/local/bin/composer install":
    cwd         => "/usr/share/drush/commands/drush_fetcher",
    creates     => "/usr/share/drush/commands/drush_fetcher/vendor",
    environment => "HOME=/root/",
    require     => [
      Package['php5-cli'],
      Wget::Fetch["Composer"],
      Vcsrepo["/usr/share/drush/commands/drush_fetcher"],
    ],
  }

  vcsrepo { "/usr/share/drush/commands/fetcher_services":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/fetcher_services.git",
    revision => "b1d56371b266c43cd76407df3765d0650140fdd6",
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
