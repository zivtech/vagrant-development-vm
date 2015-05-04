class redis {

  package { 'redis-server':
    ensure => 'installed',
  }->

  service { 'redis-server':
    enable => true,
    ensure => 'running',
  }

}
