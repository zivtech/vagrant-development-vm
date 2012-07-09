# Puppet whines and compains if it doesn't have
# its puppet users  and apt throws a fit if it's out of date,
# so we take care of these things first.

stage { 'first': before => Stage['main'] }

class {
  'vagrantsetup': stage => first;
  'vagrantvm': stage => main;
}

class vagrantvm {
  $user = 'vagrant'
  $group = 'vagrant'

  class { 'webadmin':
    webadminuser => $user,
    webadmingroup => $group,
  }

  # This lovely little hack of instantiating the class
  # we extend before the extending class allows us to get
  # our parameters into it.  Otherwise the parent class does
  # not receive them.
  class { "Php53":
    webadminuser => $user,
    webadmingroup => $group,
    require => Class['webadmin'],
  }

  class { "Php53::Dev":
    webadminuser => $user,
    webadmingroup => $group,
    require => Class['webadmin'],
  }


  # This lovely little hack of instantiating the class
  # we extend before the extending class allows us to get
  # our parameters into it.  Otherwise the parent class does
  # not receive them.
  class { 'Mysql5':
    mysqlpassword => '',
    webadminuser => $user,
    webadmingroup => $group,
  }

  class { 'Mysql5::Dev':
    mysqlpassword => '',
    webadminuser => $user,
    webadmingroup => $group,
  }

  user { "www-data":
    groups => ['dialout']
  }

  include stylomatic
  include solr
}

include vagrantsetup
include vagrantvm
