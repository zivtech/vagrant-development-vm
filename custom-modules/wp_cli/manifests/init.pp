class wp_cli {

  wget::fetch { 'download wp-cli':
    source      => 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar',
    destination => '/usr/local/bin/wp',
    timeout     => 0,
    verbose     => false,
    source_hash => '179fc8dacbfe3ebc2d00ba57a333c982',
  }->

  file { '/usr/local/bin/wp':
    ensure => 'present',
    mode   => '0755',
  }

}
