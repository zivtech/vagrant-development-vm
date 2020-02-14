class wp_cli {

  wget::fetch { 'download wp-cli':
    source      => 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar',
    destination => '/usr/local/bin/wp',
    timeout     => 0,
    verbose     => false,
  }->

  file { '/usr/local/bin/wp':
    ensure => 'present',
    mode   => '0755',
  }

}
