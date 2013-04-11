class vagrantsetup {

  # TODO: Try deleting the webadmin user here.
  group { ['puppet']:
    ensure => present,
  }

  # Prevent errors by running apt-get update when anything beneath /etc/apt/ changes
  # exec { "apt-get-update":
  #   command => "/usr/bin/apt-get update",
  # }

  # We don't actually create the user it already exists,
  # but we do need to ensure it's in the dialout group.
  user { "vagrant":
    # groups => ['dialout']
  }
  include epel
  # yumrepo { "IUS":
  #   baseurl => "http://dl.iuscommunity.org/pub/ius/stable/$operatingsystem/$operatingsystemrelease/$architecture",
  #   descr => "IUS Community repository",
  #   enabled => 1,
  #   gpgcheck => 0,
  #   # notify => Exec['yum-update'],
  # }
  # yumrepo { "webtatic":
  #   baseurl => "http://repo.webtatic.com/yum/centos/5/latest.rpm",
  #   descr => "Webtatic Repository",
  #   enabled => 1,
  #   gpgcheck => 0,
  #   # notify => Exec['yum-update'],
  # }
  /*
  exec { 'yum-update':
    command => '/usr/bin/yum update',
  }
  */
}
