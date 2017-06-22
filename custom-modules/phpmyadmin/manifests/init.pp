class phpmyadmin {

  package { 'phpmyadmin':
    ensure => 'installed',
  }->

  file { '/etc/apache2/mods-enabled/mpm_prefork.conf':
    ensure  => 'absent',
    require => Package['httpd'],
    notify => Class['Apache::Service'],
  }->

  file { '/etc/apache2/mods-enabled/mpm_prefork.load':
    ensure  => 'absent',
    require => Package['httpd'],
    notify => Class['Apache::Service'],
  }->

  file { '/etc/apache2/mods-enabled/php7.0.load':
    ensure  => 'absent',
    require => Package['httpd'],
    notify => Class['Apache::Service'],
  }->

  file { '/etc/apache2/mods-enabled/php7.0.conf':
    ensure  => 'absent',
    require => Package['httpd'],
    notify => Class['Apache::Service'],
  }->

  file { '/etc/apache2/sites-available/phpmyadmin.conf':
    owner => root,
    group => root,
    mode => '0644',
    ensure => file,
    source => "puppet:///modules/${module_name}/phpmyadmin.conf",
  }
}
