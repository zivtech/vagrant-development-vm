class automysqlbackup($webadminuser, $mysqluser, $mysqlpassword, $backupdir = "/home/$webadminuser/backups") {

  # todo: Add ssh key for mcbain to zivtech backup user
  # Setup backups.
  $mysqlbackupdir = "${backupdir}/mysql"
  $backupuser = 'zivtech-backup'
  file { $backupdir:
    ensure  => directory,
    owner   => $webadminuser,
    group   => $webadminuser,
    mode    => 754,
    require => User[$webadminuser],
  }->
  file { $mysqlbackupdir:
    ensure => directory,
    owner  => $webadminuser,
    group  => $webadminuser,
    mode   => 754,
  }

  file { "/etc/automysqlbackup":
    ensure  => directory,
    owner   => $webadminuser,
    group   => $webadminuser,
    mode    => 744,
    recurse => true,
    source  => "puppet:///modules/${module_name}/automysqlbackup",
  }->
  file { "/etc/automysqlbackup/automysqlbackup.conf":
    path    => "/etc/automysqlbackup/automysqlbackup.conf",
    ensure  => file,
    owner   => $webadminuser,
    group   => $webadminuser,
    mode    => 744,
    content => template("${module_name}/automysqlbackup.conf.erb")
  }

  user { $backupuser:
    ensure     => present,
    managehome => true,
  }->
  file { "/home/${backupuser}/backup":
    ensure  => directory,
    owner   => $backupuser,
    group   => $backupuser,
    mode    => 755,
  }->
  file { "/home/${backupuser}/backup/backups":
    ensure  => 'link',
    target  => $backupdir,
    require => User[$webadminuser],
  }->
  ssh_authorized_key { 'zivtech-backup@mcbain.zivtech.com':
    ensure => present,
    key    => 'AAAAB3NzaC1kc3MAAACBAIfiGd6lxKFSGhbahzeXnQu0lb0JX9XAvzv1Vml088NNuLJRzGofIftL+Q1nrL7Sx2UAehIGKa7jkXORGyYbgEPHZZ5PqM61Y1uF7QaRxmIjgMsEHDRwNElW6aCLT3MxNNR+FjpV+YbEiorfvpqWsO9UfGNp9EDD57qR/hpzaxcLAAAAFQCwqAEWMMYktS5xUYo36vVy1NlpTQAAAIAfydudd0/AGGGM4XwGpoo8Nc1ILc0fe6q1u/0IESATPjP6ZoOJDNOYdq42r9Fxmm60j1EDiTtpkghURz5AebdhjYF6Kn862wZWI2CuOHmW0rLIBFGw0uC+MtYmP+2TWQhabQpuJ+lpxw40hnsShT0kd8QizIfJqjqJGRG0i/hOKQAAAIBSLRyMZfBufH2jBgCc4j1lf0zPkLbAWG4nU8Fml1aGdZl4LwbEiZLNGtbfUNf64CYKRmC9bj1o5YXYhkuh9DAd3DHolusGENS8H6w55Lyn6388t5MMkFu2/PGXwLwOlwFxtKCqio6C9aGgL3U3BXRu3ZbCnll1/stSx87yOU5G4g==',
    user   => $backupuser,
    type   => 'ssh-dss',
  }
}