# Install version of node on an individual user.
define nvm::node_version (
  $user,
  $version,
  $alias_name,
  $nvm_dir = "/home/${user}/.nvm",
) {

  exec { "nvm install node version ${version} on ${user}":
    cwd         => $nvm_dir,
    command     => ". ${nvm_dir}/nvm.sh && nvm install ${version}",
    user        => $user,
    unless      => ". ${nvm_dir}/nvm.sh && nvm which ${version}",
    environment => [ "NVM_DIR=${nvm_dir}" ],
    provider    => shell,
    require     => Vcsrepo["${nvm_dir}"]
  }->
  exec { "nvm set node version ${version} as ${alias_name} on ${user}":
    cwd         => $nvm_dir,
    command     => ". ${nvm_dir}/nvm.sh && nvm alias ${alias_name} ${version}",
    user        => $user,
    environment => [ "NVM_DIR=${nvm_dir}" ],
    unless      => ". ${nvm_dir}/nvm.sh && nvm which ${alias_name} | grep ${version}",
    provider    => shell,
  }
}