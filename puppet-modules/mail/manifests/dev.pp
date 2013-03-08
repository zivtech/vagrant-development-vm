class mail::dev($dev_mail = '') inherits mail {

  # @todo: This needs to restart postfix if changed, but
  # we would have to setup postfix as its own package.
  file { '/etc/postfix/main.cf':
    require => File['/etc/postfix/virtual-regexp'],
    ensure => present,
    content => template("${module_name}/main.cf.erb"),
    owner => root,
    group => root,
    mode => 644,
    # How do we notify puppet to restart postfix?
    #notify => Package['postfix'],
  }

  # This is a required file.  It is empty for us because it
  # allows specific emails to be mapped and we don't have nay.
  file { '/etc/postfix/virtual':
    require => Package['base-package'],
    source => "puppet:///modules/${module_name}/virtual",
    owner => root,
    group => root,
    mode => 644,
  }

  # This file maps all email addresses to user@hostname
  # @todo: It would be nice to have a way to modify this so
  # we can send stuff to our own email address.
  file { '/etc/postfix/virtual-regexp':
    require => Exec['postmap_virtual'],
    content => template("${module_name}/virtual-regexp.erb"),
    owner => root,
    group => root,
    mode => 644,
  }

  # Postfix requires this virtual.db file to modify the email addresses.
  exec { 'postmap_virtual':
    require => File['/etc/postfix/virtual'],
    unless => "/bin/ls -l /etc/postfix/virtual.db",
    command => "/usr/sbin/postmap /etc/postfix/virtual",
  }
}