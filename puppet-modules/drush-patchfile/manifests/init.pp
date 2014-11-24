# Inherit from drushfetcher to ensure drushrc.php if present.
class drush-patchfile () inherits drushfetcher {

  vcsrepo { "/usr/share/drush/commands/drush-patchfile":
    require  => File["/usr/share/drush", "/usr/share/drush/commands"],
    ensure   => present,
    provider => git,
    source   => "https://bitbucket.org/davereid/drush-patchfile.git",
    revision => 'e7ffe4ccbb4c7c768788d0c24e6a18835eb35f74',
    notify   => Exec["/usr/bin/php /usr/local/bin/composer install --no-dev"],
  }

  file_line { 'Append line to drushrc.php':
    path => '/etc/drush/drushrc.php',
    line => '$options["patch-file"] = "patches.make";',
  }
}
