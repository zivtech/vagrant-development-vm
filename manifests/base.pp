# Puppet whines and compains if it doesn't have
# its puppet users  and apt throws a fit if it's out of date,
# so we take care of these things first.

stage { 'first': before => Stage['main'] }

class {
  'vagrantsetup': stage => first;
  'vagrantvm': stage => main;
}

class vagrantvm {
  $mysqlpassword = ''
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
