class mailhog {

  $php_version = $::php::globals::php_version

  package { 'postfix':
    ensure => 'absent',
  }->

  file { '/etc/network/if-up.d/postfix':
    ensure => 'present',
    mode   => '0755',
    content => "#! /bin/bash\nexit 0",
  }->

  file { '/etc/network/if-down.d/postfix':
    ensure => 'present',
    mode   => '0755',
    content => "#! /bin/bash\nexit 0",
  }->

  wget::fetch { 'download mailhog':
    source      => 'https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64',
    destination => '/usr/local/bin/mailhog',
    timeout     => 0,
    verbose     => false,
    source_hash => '3b758c81bfe2c9110911511daca1a7bc',
  }->

  file { '/usr/local/bin/mailhog':
    ensure => 'present',
    mode   => '0755',
  }->

  file { '/etc/systemd/system/mailhog.service':
    source => "puppet:///modules/${module_name}/mailhog.service",
    owner  => root,
    group  => root,
    mode   => '0755',
  }~>

  exec { 'mailhog reload systemd':
    command => '/bin/systemctl daemon-reload'
  }

  service { 'mailhog':
    provider => 'systemd',
    enable   => true,
    ensure   => 'running',
    require  => File['/etc/systemd/system/mailhog.service'],
  }

  wget::fetch { 'download mhsendmail':
    source      => 'https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64',
    destination => '/usr/local/bin/mhsendmail',
    timeout     => 0,
    verbose     => false,
    source_hash => '32e8475b0a9986c7ddefca17007dff04',
  }->

  file { '/usr/local/bin/mhsendmail':
    ensure => 'present',
    mode   => '0755',
  }->

  file { '/usr/sbin/sendmail':
    ensure => 'link',
    source => '/usr/local/bin/mhsendmail',
  }

  file_line { 'mhsendmail php.ini':
    ensure  => present,
    path    => "/etc/php/${php_version}/fpm/php.ini",
    line    => 'sendmail_path = /usr/local/bin/mhsendmail',
    match   => '^;?sendmail_path',
    require => Class['drupal_php::fpm'],
    notify  => [
      Service['httpd'],
      Service["php${php_version}-fpm"],
      Class['::php::fpm::service'],
    ],
  }

}
