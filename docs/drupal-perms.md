#Drupal Permissions

The drupal-perms script sets up secure Drupal core, public_files, and private_files folders for a Drupal installation.

Run the following command as the root user from your project folder root:

    drupal-perms


_*Note:*_ The drupal-perms script is looking for the following folder structure, which is provided by default if you install your site with the `drush fetcher-create sitename` command.

    sitename
    sitename/code (drupal root folder)
    sitename/public_files
    sitename/private_files
    sitename/webroot (symlink to code folder)

_*Note:*_ If you install a Drupal site manually, you have to create a symlink from the `sitename/webroot/default/files` to `sitename/public_files` in order for the public file system to work properly.