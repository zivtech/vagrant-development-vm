class server-autobackup() {
$backup_dir = '/home/webadmin/backup/mysql'

# Setup backups.
  file {$backup_dir:
    ensure => directory,
    path => $backup_dir,
    owner => 'webadmin',
    group => 'webadmin',
    mode => 754,
    require => File["/home/webadmin/backups"],
  }
  file {"/home/webadmin/backups":
    ensure => directory,
    path => "/home/webadmin/backups",
    owner => webadmin,
    group => webadmin,
    mode => 744,
  }
  file {"/etc/automysqlbackup":
    ensure => directory,
    path => "/etc/automysqlbackup",
    owner => webadmin,
    group => webadmin,
    mode => 744,
    recurse => true,
    source => "puppet:///modules/${module_name}/automysqlbackup",
    require => File["/etc"],
  }
  file {"/etc/automysqlbackup/automysqlbackup.conf":
    path => "/etc/automysqlbackup/automysqlbackup.conf",
    ensure => file,
    owner => webadmin,
    group => webadmin,
    mode => 744,
    content => template("${module_name}/automysqlbackup.conf.erb")
  }

  user { "zivtech_backup":
    ensure => present
  }
}
