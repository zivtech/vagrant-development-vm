<?php

namespace Ignition\System;
use Symfony\Component\Process\Process;

class Posix {

  private $site;

  public function __construct(\Pimple $site) {
    $this->site = $site;
  }

  /**
   * Ensures a path exists creating each folder necessary.
   *
   * @param $path
   *   The path of the folder.
   * @param $owning_user
   *   A string representing the existing owner to set for the elements created in the path.
   * @param $owning_group
   *   A string representing the existing owning group to set for the elements created in the path.
   * @param $permissions
   *   The permission to set for the file, specified as a file mode creation mask (umask, e.g. 777).
   */
  public function ensureFolderExists($path, $owning_user = NULL, $owning_group = NULL, $permission = 0755) {
    $old_mask = umask(0);
    $path_parts = explode('/', $path);
    $success = TRUE;
    $path = '';
    foreach ($path_parts as $part) {
      $path .= $part . '/';
      if ($success && !is_dir($path)) {
        drush_log("Creating folder $path");
        if (!$this->site['simulate']) {
          $success = mkdir($path, $permission);
        }
      }
    }
    umask($old_mask);
    if (!$success) {
      throw new \Exception(sprintf('Folder creation failed on path "%s".', $path));
    }
    return $success;
  }

  /**
   * Ensure that a file exists and is owned by the appropriate user.
   *
   * @param $path
   *   The path of the file.
   * @param $owning_user
   *   A string representing the existing owner to set for the elements created in the path.
   * @param $owning_group
   *   A string representing the existing owning group to set for the elements created in the path.
   * @param $permissions
   *   The permission to set for the file, specified as a file mode creation mask (umask, e.g. 777).
   */
  public function ensureFileExists($path, $owning_user = NULL, $owning_group = NULL, $permission = 0755) {
    $old_mask = umask(0);
    $path_parts = explode('/', $path);
    $filename = array_pop($path_parts);
    $directory = implode('/', $path_parts);
    $this->ensureFolderExists($directory, $owning_user, $owning_group);
    if (!file_exists($path)) {
      $vars = array('@path' => $path, '@permissions' => (string) $permission);
      drush_log(dt('Creating file @path', $vars));
      drush_log(dt('Setting permissions of @path to @permissions', $vars));
      if (!$this->site['simulate']) {
        if (!touch($path)) {
          throw new \Ignition\Exception\IgnitionException(dt('File creation failed for @path.', $vars));
        }
        if (!chmod($path, $permission)) {
          throw new \Ignition\Exception\IgnitionException(dt('File permission setting failed while setting @path to @permissions.', $path));
        }
      }
    }
  }

  /**
   * Ensure that a symlink exists and points to the location we want.
   *
   * @param $realPath
   *   The path to the real thing we are linking to.
   * @param $link
   *   The path of the desired link.
   */
  public function ensureSymLink($realPath, $link) {
    $pathParts = explode('/', $link);
    array_pop($pathParts);
    $destinationDirectory = implode('/', $pathParts);
    if (is_dir($destinationDirectory) && !is_link($link)) {
      drush_log("Creating a symlink to point from $link to $realPath");
      if (!$this->site['simulate']) {
        if (!symlink($realPath, $link)) {
          // Throw an exception
          throw new \Exception('Link creation failed.');
        }
      }
    }
    else if (!$this->site['simulate']) {
      if (!is_dir($destinationDirectory)) {
        throw new \Exception(sprintf('The directory where the symlink is desired (%s) does not exist.', $destinationDirectory));
      }
      else if (readlink($link) != $realPath) {
        throw new \Exception(sprintf('A symlink already exists at %s but it points to %s rather than %s.', $link, readlink($link), $realPath));
      }
    }
  }

 /**
  * Ensure that a path has been deleted.
  *
  * @param $path
  *   The path to delete.
  */
  public function ensureDeleted($path) {
    // Note: PHP doesn't have a recursive deletion function, so we just shell out here.
    // Also git sets file permissions that require the -f.
    if (!$this->site['simulate']) {
      $process = new Process(sprintf('rm -rf %s', $path));
      $process->run();
      if ($process->isSuccessful()) {
        return $process->getOutput();
      }
      else {
        throw new \Exception(sprintf('The path "%s" could not be deleted.', $path));
      }
    }
    else {
      drush_log(sprintf('rm -rf %s', $path));
    }
  }

  /**
   * Write a file to disk.
   *
   * @param $path
   *   A string representing the absolute path on disk.
   * @param $content
   *   The content to write into the file.
   */
  public function writeFile($path, $content) {
    $path_parts = explode('/', $path);
    array_pop($path_parts);
    $containing_path = implode('/', $path_parts);
    if (is_dir($containing_path)) {
      drush_log("Writing file to $path");
      if (!$this->site['simulate']) {
        if (file_put_contents($path, $content) === FALSE) {
          throw new \Ignition\Exception\IgnitionException(sprintf('Writing file %s failed.', $path));
        }
      }
    }
    else if (!$this->site['simulate']) {
      drush_print((string) gettype($this->site['simulate']));
      throw new \Ignition\Exception\IgnitionException(sprintf('Writing file %s failed because containing folder %s does not exist.', $path, $containing_path));
    }
  }

  /**
   * Return the user's home folder.
   */
  public function getUserHomeFolder() {
    $user = posix_getpwuid(posix_geteuid());
    return $user['dir'];
  }

  /**
   * Get this machine's configured hostname.
   */
  public function getHostname() {
    $process = new Process('hostname');
    $process->run();
    if (!$process->isSuccessful()) {
      throw new \Ignition\Exception\IgnitionException('The hostname could not be found.');
    }
    return trim($process->getOutput());
  }

}
