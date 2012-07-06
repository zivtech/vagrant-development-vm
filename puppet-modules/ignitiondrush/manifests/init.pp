class ignitiondrush {

  file { "/usr/share/drush":
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }

  file {  "/usr/share/drush/commands":
    require => File['/usr/share/drush'],
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }

  file { "/usr/share/drush/commands/ignition_drush":
    require => File["/usr/share/drush", "/usr/share/drush/commands"],
    recurse => true,
    source => "puppet:///modules/ignitiondrush/ignition_drush",
  }

}
