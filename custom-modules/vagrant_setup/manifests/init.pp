class vagrant_setup {

  # We don't actually create the user it already exists,
  # but we do need to ensure it's in the dialout group.
  user { 'vagrant':
    groups => ['dialout']
  }

  package { 'software-properties-common':
    ensure => 'installed',
  }
}
