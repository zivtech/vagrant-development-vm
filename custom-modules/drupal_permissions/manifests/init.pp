class drupal_permissions {

  file { "/usr/local/bin/drupal-perms":
    owner => root,
    group => root,
    mode => '0774',
    ensure => file,
    source => "puppet:///modules/drupal_permissions/drupal-perms",
  }
}
