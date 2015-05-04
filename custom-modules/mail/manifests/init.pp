class mail($dev_mail = '') {

  package { 'postfix':
    ensure => 'present',
  }->

  service { "postfix":
    ensure => 'running',
  }
}
