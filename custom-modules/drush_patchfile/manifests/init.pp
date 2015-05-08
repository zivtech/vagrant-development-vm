class drush_patchfile ($git_ref = 'master') {

  vcsrepo { "/usr/share/drush/commands/drush-patchfile":
    require  => Class['drush'],
    ensure   => present,
    provider => git,
    source   => "https://bitbucket.org/davereid/drush-patchfile.git",
    revision => $git_ref,
  }

}
