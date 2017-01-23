class phpmyadmin {

  package { 'phpmyadmin':
    ensure => 'installed',
  }

  file { "/etc/apache2/sites-available/phpmyadmin.conf":
    owner => root,
    group => root,
    mode => '0644',
    ensure => file,
    source => "puppet:///modules/phpmyadmin/phpmyadmin.conf",
  }
}
