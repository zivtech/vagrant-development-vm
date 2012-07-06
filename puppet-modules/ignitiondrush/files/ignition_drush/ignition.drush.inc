<?php

/**
 * Implements hook_drush_help().
 */
function ignition_drush_help($section) {
  switch ($section) {
    case 'meta:ignition:title':
      return dt('Ignition commands');
    case 'meta:ignition:summary':
      return dt('Interact locally with sites managed by Ignition.');
  }
}

/**
 * Implements hook_drush_command().
 */
function ignition_drush_command() {

  $items = array();

  // Options necessary for interacting with sites on this server.
  $environment_options = array(
    'ignition-sql-user' => 'The database username to use for administration commands.',
    'ignition-sql-password' => 'The database password to use for administration commands.',
  );

  $items['ignition-list'] = array(
    'description' => 'List all sites available to Ignition that this user has access to.',
    'aliases' => array('il'),
    'arguments' => array(
      'search' => 'Any part of the name of a site to search for.',
      'page' => 'The page of listings starting from zero.  Necessary only if there are too many results to display on a page of 100.',
    ),
  );

  $items['ignition-info'] = array(
    'description' => 'List known information about a site managed by Ignition.',
    'aliases' => array('if'),
    'arguments' => array(
      'search' => 'The name of a site to list information for.',
    ),
  );

  // Environment items are the items that inherit the environment options.
  $environment_items['ignition-get'] = array(
    'description' => 'Setup a site on this machine managed by Ignition synchronizing the database and files if desired.',
    'aliases' => array('ig'),
    'arguments' => array(
      'site' => 'The name of a site to install on this server.',
      'environment' => 'The name of the environment to load from.  Optional but required with database or file syncing.',
    ),
    'options' => array(
      'branch' => 'The branch of the repository to checkout',
      'tag' => 'The tag of the repository to checkout',
      'hostname' => 'The hostname to use in the server config (defaults to [site_name].[hostname]).',
      'sql-sync' => 'Whether to syncronize the database with a selected remote environment.',
      // TODO: This should probably use a configurable "file-fetcher" option
      // rather than speciying local or remote.
      'file-sync' => 'Whether to syncronize the public files with the selected remote environment.',
      'local-name' => 'The local name of the site to use for this deployment. This option allows you to get more than one variation of a site on one system.',
    ),
  );

  $environment_items['ignition-create'] =  array(
    'description' => 'Setup a site on this machine similar to an Ignition site.  Note this will not add the site to the Ignition server.',
    'aliases' => array('ic'),
    'arguments' => array(
      'site_name' => 'The name of a site to create.',
      'version' => 'The version of Drupal to install (the same options that would be passed to pm-download without the `drupal-` prefix).',
    ),
    'options' => array(
      'package-handler' => 'The package handler to use for downloading drupal, defaults to drupalorg_git but any can be used that work with pm-download.',
    ),
  );

  $environment_items['ignition-release'] = array(
    'description' => 'Release an Ignition managed site to a specific tag.',
    'aliases' => array('ir'),
    'arguments' => array(
      'site name' => 'The name of the site to release.',
      'tag' => 'The tag to release. Branches are not supported.',
    ),
    'options' => array(
      'backup' => 'Flag to determine whether to create a backup.',
      'backup-dir' => 'Path to create a SQL dump.',
    ),
  );

  $environment_items['ignition-delete'] = array(
    'description' => 'Remove an Ignition managed site from this server entirely.',
    'aliases' => array('id'),
    'arguments' => array(
      'site' => 'The name of the site to delete.',
    ),
    'options' => array(
    ),
  );

  // Add environment specific options relevant to the server
  // on which ignition is being run for the appropriate commands.
  foreach ($environment_items as $name => $item) {
    $item['options'] = array_merge($environment_options, $item['options']);
    $items[$name] = $item;
  }

  // Add the base options for all Ignition commands.
  foreach ($items as &$item) {
    $item['bootstrap'] = DRUSH_BOOTSTRAP_DRUSH;
  }
  return $items;
}

/**
 * List sites available with the current configuration.
 */
function drush_ignition_list($name = '', $page = 0) {
  try {
    $result = drush_ignition_get_info_fetcher()->listSites($name, $page);
    // TODO: We should have one common error status to check.
    if (!empty($result)) {
      $rows[] = array(
        'Title',
        'Name',
      );
      foreach($result as $name => $info) {
        $rows[] = array($info->title, $name);
      }
      drush_print_table($rows, TRUE);
    }
  }
  catch (Exception $e) {
    drush_log($e->getMessage() . ' on line ' . $e->getLine() . ' of ' . $e->getFile() . '.', 'error');
  }
}

/**
 * Print out information about a single site.
 */
function drush_ignition_info($site_name = NULL) {
  if (is_null($site_name) && !$site_name != drush_ignition_prompt_for_site_name()) {
    return;
  }
  $site_info = drush_ignition_get_site_info($site_name);
  if ($site_info) {
    drush_print_r($site_info);
  }
}

/**
 * Create and install a new site.
 */
function drush_ignition_create($site_name = FALSE, $version = '7') {

  if (!$site_name && !$site_name = drush_ignition_prompt_for_site_name()) {
    return;
  }

  // TODO: Most of this should probably be moved into the site class iteslf.

  // Build a new site object.
  $site_info = new stdClass;
  $site_info->name = $site_name;
  $site_info->version = $version;
  $site = drush_ignition_get_site($site_info);

  try {
    // Make sure that the project direcotry is properly configured on the server.
    $success = $site->ensureWorkingDirectory();

    $commandline_args = array(
      'drupal-' . $version,
    );
    $commandline_options = array(
      // Default our package hander to git_drupalorg.
      '--package-handler=' . drush_get_option('package-handler', 'git_drupalorg'),
      '--drupal-project-rename=code',
      '--destination=' . $site->getWorkingDirectory(),
    );
    foreach ($commandline_options as $name => $value) {
      drush_set_option($name, $value);
    }
    // Note we don't use drush_invoke_process() because it requires an existing
    // site.
    drush_invoke_process('@none', 'pm-download', $commandline_args);
    return;

    // Create necessary symlinks.
    $success = $site->ensureSymLinks();

    // Install the site
    $commandline_args = array();
    $commandline_options = array(
      'root' => $site->getCodePath(),
      'db-url' => '',
      'account-name' => 'admin',
      'account-pass' => 'pass',
      'site-name' => $ite_name,
    );
    drush_invoke_process('@self', 'site-install', $commandline_args, $commandline_options, TRUE);
  }
  catch (Exception $e) {
    drush_log($e->getMessage(), 'error');
    drush_log(dt('Something failed in site creation, consider running `drush ignition-delete @site_name.', array('@site_name', $site_name)), 'error');
  }
}

/**
 * Setup a local copy of an Ignition site.
 *
 * Do all of the work to setup a local copy of a site tracked
 * by Ignition, optionally syncronizing database and file with
 * an environment tracked by Ignition.
 *
 * TODO: Document installation instructions.
 */
function drush_ignition_get($site_name = FALSE) {

  if (!$site_info = drush_ignition_load_site_info_from_name_alias_or_context($site_name)) {
    drush_log(dt('The site @site could not be found.', array('@site' => $site_name)), 'error');
    return FALSE;
  }
  // Instantiate the site object.
  $site = drush_ignition_get_site($site_info);
  if ($local_name = drush_get_option('local-name', FALSE)) {
    $site['site.name'] = $local_name;
  }
  drush_ignition_ensure_site($site);
}

/**
 *
 */
function drush_ignition_ensure_site(Ignition\SiteInterface $site) {
  // Note that the Ignition library generally throws exceptions with helpful
  // error messages if anything goes wrong anywhere, so we wrap all our work
  // in one big try/catch.
  try {

    // Make sure that the project direcotry is properly configured.
    drush_log(dt('Ensuring the working directory for this repository is properly setup...'), 'ok');
    $site->ensureWorkingDirectory();
    drush_log(dt('The working directory is properly setup.'), 'success');

    // Checkout the site in the appropriate location.
    drush_log(dt('Checking out code from the repository...'), 'ok');
    $site->ensureCode();
    drush_log(dt('The code is in place and up to date.'), 'success');

    // Create the settings.php file.
    $site->ensureSettingsFileExists();
    drush_log(dt('The settings.php file is in place.'), 'success');

    // Create necessary symlinks.
    $site->ensureSymLinks();
    drush_log(dt('All symlinks have exist and point to the correct path.'), 'success');

    // Ensure we have a database and user.
    $site->ensureDatabase();
    drush_log(dt('Your database exists and the site user has successfully conntected to it.'), 'success');

    // Create a drush alias for this site.
    $site->ensureDrushAlias();
    drush_log(dt('The alias @!alias exists and resides in the file @path', array('!alias' => $site_name, '@path' => $site->getDrushAliasPath())), 'success');

    // Write a file with the site information so that we can track down
    // which site this is even if it has been placed in an unexpected location
    // came from later.
    $site->ensureSiteInfoFileExists();
    drush_log(dt('The site info file for this site exists.'), 'success');

    // Add the site to the server.
    $site->ensureSiteEnabled();
    // TODO: Fill in hosntame.
    drush_log(dt('The site is enabled and is running at @hostname', array('@hostname' => 'hostname')), 'success');

    if (drush_get_option('sql-sync')) {
      drush_log(dt('Attempting to sync database from remote...', 'ok'));
      $site->syncDatabase();
      drush_log(dt('The database was properly synchronized.', 'success'));
    }

    /*
    if (drush_get_option('sync-public-files')) {
      $commandline_args = array(
        // TODO: Build these dynamically!
        'webadmin@bart.zivtech.com/var/www/roadside/webroot:%files',
        '/var/www/roadside/webroot:%files',
      );
      // TODO: The sorts of logging above!
      drush_invoke_process('@self', 'sql-sync', $commandline_args, $commandline_options) ? drush_print('true') : drush_print('false');
    }
    */
    drush_log('Your site has been setup!', 'success');
  }
  catch (Exception $e) {
    drush_log($e->getMessage(), 'error');
    drush_log('Something went wrong along the way, try running with `--verbose` to find the problem.', 'error');
  }
}

/**
 * Issue a request against Ignition to retrieve a site's information by name.
 */
function drush_ignition_get_site_info($site_name) {
  try {
    $result = drush_ignition_get_info_fetcher()->getInfo($site_name);
    return $result;
  }
  catch (Exception $e) {
    drush_log(dt('Site info loading failed - @message', array('@message' => $e->getMessage())), 'error');
  }
}

/**
 * Get the conifugred siteInfoFetcher().
 *
 */
function drush_ignition_get_info_fetcher() {
  $class = ignition_drush_get_option('info-fetcher.class', 'Ignition\InfoFetcher\DrushAlias');
  return new $class();
}


/**
 * Delete an ignition site.
 */
function drush_ignition_delete($site_name) {
  // TODO: Validate $site_name.
  // TODO: Allow deletion of other webroots (check site info?).
  if (!drush_confirm("Are you sure you want to delete $site_name?")) {
    return;
  }
  try {
    $site_info = new stdClass;
    $site_info->name = $site_name;
    $site = drush_ignition_get_site($site_info);
    $site->remove();
    drush_log(dt('The site @site has been successfully removed.', array('@site' => $site_name)), 'success');
  }
  catch (Exception $e) {
    drush_log($e->getMessage(), 'error');
  }
}

/**
 * Factory function for instatiating a site object.
 */
function drush_ignition_get_site($site_info = NULL) {
  $class = drush_get_option('ignition-site-class', '\Ignition\Site');
  $site = new $class();
  $site->configureWithSiteInfo($site_info);
  $ignition_config = drush_get_option('ignition', array());
  // Merge in global configuration.
  foreach ($ignition_config as $name => $value) {
    if (!empty($site[$name]) && is_array($site[$name]) && is_array($value)) {
      $site[$name] = array_merge($site[$name], $value);
    }
    else {
      $site[$name] = $value;
    }
  }
  return $site;
}

function drush_ignition_release() {
  // Optionally create a MySQL backup.
  // Checkout a new tag.
  // Create settings.php and files symlinks.
  // Put the site in offline mode.
  // Update the webroot symlink.
  // Run update.php
  // Take the site out of offline mode.
}

/**
 *
 */
function drush_ignition_prompt_for_site_name() {
  $site_name = drush_prompt(dt('Please enter the site name you would like to create or n to cancel'));
  if ($site_name = 'n') {
    return FALSE;
  }
  else {
    return $site_name;
  }
}

// TODO: Add this to the hook_command implementation above.
function drush_ignition_subcommand() {
  // Just planning the available subcommands.
  $subcommands = array(
    'setup-working-directory' => '',
    'get-code' => '',
    'create-database' => '',
    'sync-database' => '',
    'sync-files' => '',
  );
}

/**
 * Implements hook_drush_init().
 *
 * Register our autoloader.
 */
function ignition_drush_init() {
  $command = drush_get_command();
  // Check to see if we're running a Ignition command.
  if (strpos($command['command-hook'], 'ignition-') === 0) {
    spl_autoload_register('ignition_autoload');
  }
}

/**
 * Autoloader for Ignition.
 *
 * @param $class
 *   The name of the class to load.
 * @return
 *   True if the class was successfully loaded.
 */
function ignition_autoload($class) {

  static $search_paths;

  // Only take action if searching for an Ignition class.
  if ($search_paths === NULL) {
    // TODO: use a proper method for discovering the base path to the cmd file
    $command = drush_get_command();
    $search_paths = array(
      // Classes in base Ignition install.
      $command['path'] . '/lib/',
    );
  }

  // Try the search paths in order.
  foreach ($search_paths as $base_path) {
    $file = $base_path . strtr($class, '\\', '/') . '.php';
    if (is_file($file)) {
      require $file;
      return TRUE;
    }
  }
}

/**
 * Retrieve a specific handler object.
 *
 * @param $type
 *   The type of handler we are loading (e.g. System, DB, etc.).
 * @param
 *   The specific handler to load, this should map directly to a class.
 * @return
 *   A loaded handler object.
 */
function drush_ignition_get_handler($type, $handler) {
  // TODO: Determine whether we could have a much better plugin system (hint:
  // we can).
  $handler = strtolower($handler);
  $handler[0] = strtoupper($handler[0]);
  $class = 'Ignition\\' . $type . '\\' . $handler;
  return new $class;
}

/**
 * Load an Ignition asset and populate it with variables.
 *
 * We do not have Drupal's templating system available to us at the bootstrap
 * level where we start needing file assets so we implement our own dead
 * simple php template engine here.
 *
 * @param $asset_name
 *   The name of the file as it appears in the `/assets` directory or a fully .
 * @param $vars
 *   An array of variables for the asset, each will be available in the scope
 *   of the asset template with a variable name of the key and a value of the value.
 */
function drush_ignition_get_asset($asset_name, array $vars = array()) {
  if (!is_file($asset)) {
    $path = __DIR__ . '/assets/' . $asset_name . '.tpl.php';
  }
  if (is_file($path)) {
    foreach ($vars as $name => $value) {
      $$name = $value;
    }
    ob_start();
    include($path);
    $contents = ob_get_contents();
    ob_end_clean();
    return $contents;
  }
  else {
    throw new \Ignition\Exception\IgnitionException(dt('The requested resource !path could not be found.', array('!path' => $path)));
  }
}

/**
 * Attempt to identify the site we are working with from the specified path.
 *
 * @return
 *   A stdClass object containing site information or FALSE on failure.
 */
function drush_ignition_find_site_by_directory($directory) {
  $parts = explode(DIRECTORY_SEPARATOR, $directory);
  $site_info = FALSE;
  while (count($parts)) {
    $path = implode(DIRECTORY_SEPARATOR, $parts) . DIRECTORY_SEPARATOR . 'site_info.yaml';
    if (file_exists($path)) {
      $site_info = drush_ignition_load_site_info_from_file($path);
      break;
    }
    array_pop($parts);
  }
  return $site_info;
}

/**
 *
 * @param $site_name
 *   An optional param representing a site name or drush alias to the site.
 * @return
 *   A stdClass object containing site information.
 */
function drush_ignition_load_site_info_from_name_alias_or_context($site_name = FALSE) {

  $site_info = FALSE;

  try {
    // If we have a drush alias starting with `@` then we look up the local alias
    // and try to get the site info from the parent folder of the webroot
    // indicated by the alias root.
    if (strpos($site_name, '@') === 0 && $specs = drush_sitealias_resolve_sitespecs($site_name)) {
      // We may have multiple environments but if we wrote the aliases then the
      // first one is the local one.
      $spec = array_shift($specs);
      $site_info = drush_ignition_find_site_by_directory($spec['root']);
    }

    // If a site was not selected, we may be loading the site information from
    // the site info file in the current working directory, have a look.
    $path = getcwd();
    if (!$site_name && !($site_info = drush_ignition_find_site_by_directory($path))) {
      $site_name = drush_ignition_prompt_for_site_name();
    }

    // Otherwise load the site from the Ignition web service based on the site
    // name.
    if ($site_name && !$site_info) {
      $site_info = drush_ignition_get_site_info($site_name);
    }

    if ($site_info === FALSE) {
      drush_log(dt('This site information could not be loaded.'), 'error');
      return;
    }

    return $site_info;
  }
  catch (Exception $e) {
    drush_log(dt('Fetching site information failed: @message', array('@message' => $e->getMessage())), 'error');
  }
}

/**
 * Load site info from a specific file.
 *
 * @param $path
 *   The path of the yaml file where site info is stored.
 * @return
 *   A stdClass object with data about the site.
 */
function drush_ignition_load_site_info_from_file($path) {
  $return = FALSE;
  if (is_file($path) && $site_info = file_get_contents($path)) {
    $class = drush_get_option('ignition_site_class', '\Ignition\Site');
    $return = $class::parseSiteInfo($site_info);
  }
  return $return;
}

/**
 * Get an option from the configured Ignition array.
 *
 * @param $option
 *   The name of the option.
 * @param $default
 *  The default to use if no value is specified.
 */
function ignition_drush_get_option($option, $default = NULL) {
  $options = drush_get_option('ignition');
  if (isset($options[$option])) {
    $return = $options[$option];
  }
  else {
    $return = $default;
  }
  return $return;
}
