class nvm (
  $nvm_version = 'v0.33.11',
  $nvm_repo = 'https://github.com/creationix/nvm.git',
  $users = [],
  $node_versions = [],
) {

  # Build the hashes to install nvm on an
  # individual user.
  $installs = $users.reduce({}) |$cumulate, $user| {
    $tmp = merge($cumulate, {
      $user['name'] => {
        home          => $user['home'],
        nvm_repo      => $nvm_repo,
        nvm_version   => $nvm_version,
        node_versions => $node_versions,
    }})
  }
  create_resources(::nvm::install, $installs)
}