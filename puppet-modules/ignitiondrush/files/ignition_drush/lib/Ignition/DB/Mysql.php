<?php

namespace Ignition\DB;
use Symfony\Component\Process\Process;

class Mysql {

  private $username = FALSE;

  private $password = FALSE;

  private $database = FALSE;

  private $db_spec = array();

  private $site = FALSE;

  public function __construct(\Pimple $site) {
    $this->site = $site;
  }

  /**
   * Returns the drush driver for this database.
   */
  static public function getDriver() {
    return 'mysql';
  }

  /**
   * Check that the database exists.
   */
  public function exists() {
    return $this->executeQuery("SELECT 1;")->isSuccessful();
  }

  /**
   * Create the database.
   */
  public function createDatabase() {
    $database = $this->site['database.database'];
    $result = $this->executeQuery('create database ' . $database, FALSE)->isSuccessful();
    if (!$result) {
      throw new \Ignition\Exception\IgnitionException(sprintf('The database %s could not be created.', $database));
    }
  }

  /**
   * Check that the user exists.
   */
  public function userExists() {
    $conf = $this->site;
    $process = $this->executeQuery(sprintf("SELECT user FROM mysql.user WHERE User='%s' AND Host='%s'", $conf['database.username'], $conf['database.hostname']), FALSE);
    if (!$process->isSuccessful()) {
      throw new \Ignition\Exception\IgnitionException('MySQL command failed.');
    }
    if ($process->getOutput() == '') {
      return FALSE;
    }
    else {
      return TRUE;
    }
  }

  /**
   *
   */
  public function createUser() {
    $conf = $this->site;
    $command = sprintf('create user "%s"@"%s" identified by "%s"', $conf['database.username'], $conf['database.hostname'], $conf['database.password']);
    $this->executeQuery($command, FALSE);
  }
  
  public function grantAccessToUser() {
    $conf = $this->site;
    $command = sprintf('grant all on %s.* to "%s"@"%s"', $conf['database.database'], $conf['database.username'], $conf['database.hostname'], $conf['database.password']);
    $this->executeQuery($command, FALSE);
    $this->executeQuery('flush privileges', FALSE);
  }

  /**
   * Remove the database.
   */
  public function removeDatabase() {
    $database = $this->site['database.database'];
    $result = $this->executeQuery('drop database ' . $database, FALSE)->isSuccessful();
    if (!$result) {
      throw new \Ignition\Exception\IgnitionException(sprintf('The database %s could not be dropped.', $database));
    }
  }

  /**
   * Remove the database user.
   */
  public function removeUser() {
    $conf = $this->site;
    $command = sprintf('drop user "%s"@"%s"', $conf['database.username'], $conf['database.hostname']);
    $this->executeQuery($command, FALSE);
  }

  /**
   * Execute a MySQL query at the command line.
   */
  protected function executeQuery($command, $setDatabase = TRUE) {
    // TODO: Allow the mysql path to be specified?
    $base_command = 'mysql';

    $site = $this->site;

    if ($setDatabase) {
      $base_command .= ' --database=' . escapeshellarg($site['database.database']);
    }

    if ($site['database.admin.user']) {
      $base_command .= ' --user=' . escapeshellarg($site['database.admin.user']);
    }
    if ($site['database.admin.password']) {
      $base_command .= ' --password=' . escapeshellarg($site['database.admin.password']);
    }
    if ($site['database.admin.hostname']) {
      $base_command .= ' --host=' . escapeshellarg($site['database.admin.hostname']);
    }
    if ($site['database.admin.port']) {
      $base_command .= ' --port=' . escapeshellarg($site['database.admin.port']);
    }

    $command = $base_command . ' -e ' . escapeshellarg($command);
    drush_log(dt('Executing MySQL command `@command`', array('@command' => $command)));
    $process = new Process($command);

    if ($site['simulate']) {
      return $process;
    }

    $process->run();
    return $process;
  }
}

