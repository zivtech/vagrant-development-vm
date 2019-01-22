# Install nvm for a single user.
define nvm::install (
  $user = $name,
  $home = "/home/${user}",
  $node_versions,
  $nvm_repo,
  $nvm_version,
) {

  $profile_path = "${home}/.bashrc"
  $nvm_dir = "${home}/.nvm"

  vcsrepo { "${nvm_dir}":
    ensure   => 'present',
    provider => 'git',
    source   => $nvm_repo,
    revision => $nvm_version,
    owner    => $user,
    group    => $user,
  }

  file { "ensure ${profile_path}":
    ensure  => 'present',
    path    => $profile_path,
    owner   => $user,
    require => User[$user],
  }->

  file_line { "add NVM_DIR to profile file for ${user}":
    path => $profile_path,
    line => "export NVM_DIR=\"\$HOME/.nvm\"",
  }->

  file_line { "add . ~/.nvm/nvm.sh to profile file for ${user}":
    path => $profile_path,
    line => "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm",
  }

  # This builds the version hashes so we can install the
  # same versions for each user.
  $versions = $node_versions.reduce({}) |$cumulate, $node_version| {
    $tmp = merge($cumulate, {
      "${user}-${node_version['alias']}" => {
        version    => $node_version['version'],
        alias_name => $node_version['alias'],
        user       => $user,
        nvm_dir    => $nvm_dir,
    }})
  }

  create_resources(::nvm::node_version, $versions)
}