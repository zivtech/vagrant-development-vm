class solr {

  package { 
    [
      'tomcat6',
      'tomcat6-admin',
    ]: 
      ensure => installed 
  }

  service { 
    [
      'tomcat6',
    ]:
    require => Package['tomcat6'],
    ensure => running,
  }
  
  file { "/opt/solr":
    require => Package['tomcat6'],
    ensure => directory,
    owner => 'tomcat6',
    group => 'webadmin',
    recurse => true,
    mode => 775,
  }

  file { "/opt/solr/solr-base-6":
    ensure => "present",
    recurse => "remote",
    require => [File['/opt/solr'], Package['tomcat6']],
    source => "puppet:///modules/solr/solr-base-6",
    owner => 'tomcat6',
    group => 'webadmin',
  }

  file { "/opt/solr/solr-base-7":
    ensure => "present",
    recurse => "remote",
    require => [File['/opt/solr'], Package['tomcat6']],
    source => "puppet:///modules/solr/solr-base-7",
    owner => 'tomcat6',
    group => 'webadmin',
  }
}



