# Inherit from drush because we can't do anything without it
# and because we want to ensure that the shared commands folder
# exists and can't redeclare it.
class drush_phpsh inherits drush {

  file { "/usr/src/phpsh_1.3_i386.deb":
    owner => root,
    group => root,
    mode => '0644',
    ensure => file,
    source => "puppet:///modules/drush_phpsh/phpsh_1.3_i386.deb",
  }

  file { "/etc/phpsh":
    owner => root,
    group => root,
    mode => '0755',
    ensure => directory,
  }

  file { "/etc/phpsh/rc.php":
    owner => root,
    group => root,
    mode => '0755',
    ensure => file,
    source => "puppet:///modules/drush_phpsh/rc.php",
  }

  package { "phpsh":
    ensure => installed,
    provider => 'dpkg',
    source => "/usr/src/phpsh_1.3_i386.deb",
    require => File["/usr/src/phpsh_1.3_i386.deb"],
  }

  vcsrepo { "/usr/share/drush/commands/phpsh":
    require => [
      File["/usr/share/drush", "/usr/share/drush/commands"],
      Package["phpsh"],
    ],
    ensure => present,
    provider => git,
    source => "http://git.drupal.org/project/phpsh.git",
    revision => '287e7329efcdd0c13334446fc95418b7cf110cda',
  }

}
