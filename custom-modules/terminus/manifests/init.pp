class terminus {

  require php::composer

  file { '/usr/share/composer':
    mode   => '0555',
    owner  => 'root',
    group  => 'root',
    ensure => 'directory',
  }->

  exec { 'Install terminus':
    environment => [
      'COMPOSER_HOME=/usr/share/composer',
    ],
    command     => '/usr/local/bin/composer global require pantheon-systems/terminus',
    creates     => '/usr/share/composer/vendor/bin/terminus',
  }->

  file { '/usr/local/bin/terminus':
    target => '/usr/share/composer/vendor/bin/terminus',
    mode   => '0555',
    owner  => 'root',
    group  => 'root',
  }

}
