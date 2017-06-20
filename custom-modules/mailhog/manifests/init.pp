class mailhog {

  package { 'postfix':
    ensure => 'present',
  }->

  service { 'postfix':
    ensure => 'running',
  }

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

  file { '/etc/systemd/system/multi-user.target.wants/mailhog.service':
    ensure  => 'link',
    source  => '/etc/systemd/system/mailhog.service',
    require => File['/etc/systemd/system/mailhog.service'],
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

}
