stage { 'first': before => Stage['main'] }

class {
  'setup': stage => first;
  'vagrantvm': stage => main;
}

class setup {
  group { 'puppet':
    ensure => present,
  }
  # Prevent errors by running apt-get update when anything beneath /etc/apt/ changes
  exec { "apt-get-update":
   command => "/usr/bin/apt-get update",
  }
}

class vagrantvm {
  $mysqlpassword = ''
  # passwords must always be actual hashes as used on disk in /etc/shadow
  $webadminpassword = '$6$bCysFszn$Ycq5zFTrRm8QOWKWJk9qAr94okYBVLiQm/tcWe9dT6ohuFl46i8DoWP.LMdYJG7dQyFJh0XgDGeiWhnHUHLKF.'
  $rootpassword = $webadminpassword
  $backuppassword = $webadminpassword
  include zivtechbase
  include stylomatic
  include solr
  include php53-dev
  class { 'mysql5':
    mysqlpassword => $mysqlpassword
  }
}

include setup
include vagrantvm
