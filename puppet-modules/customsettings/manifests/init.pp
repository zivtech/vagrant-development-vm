class customsettings {

  file { "/etc/apache2":
    ensure => directory,
    owner => root,
    group => root,
    mode => 644,
  }

  file {  "/etc/apache2/apache2.conf":
    require => File['/etc/apache2'],
    ensure => file,
    source => "puppet:///modules/customsettings/apache2.conf",
    owner => vagrant,
    group => root,
    mode => 644,
  }

  #file { "/etc/php5/apache2":
  #  ensure => directory,
  #  owner => root,
  #  group => root,
  #  mode => 755,
  #}

  #file {  "/etc/php5/apache2/php.ini":
  #  require => File['/etc/php5/apache2'],
  #  ensure => file,
  #  source => "puppet:///modules/customsettings/php.ini",
  #  owner => vagrant,
  #  group => root,
  #  mode => 644,
  #}


}
