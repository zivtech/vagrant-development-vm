# Ignition Drush #

Ignition Drush is a command line client to interact wiht your Ignition site and to do interesting things with the data retrieved from there.

This is the drush command to interact with sites managed by Ignition.  All `\Ignition\Site` class (the main, top level, class) methods are
intended to work in a declaritive, rather than imperitive, way.  This means that generally Ignition Drush commands are intended to be capable
of being run more than once.  Each call will verify that it is necessary before actually taking action.  If a folder needs to be created, the
existence of that folder is first tested and the path to that folder is created if necessary.

## Folder layout ##

Ignition creates a "working diredctory" with a specific layout for its uses.  That directory is laid 
out as follows:

- public_files - The drupal pubic files directory which will be symlinked to `sites/default/files` by default.  Generally group writable and group owned by the webserver.
- private_files - (Optional) A private file directory to be used by drupal.  Generally group writable and group owned by the webserver.
- logs - A folder for logs with files created for `mail.log`, `access.log` and `watchdog.log`.  Logs used in development, not recommended for production.
- code - A folder containing the actual checkout from the VCS repository.
- releases - (Optional) 
  - 1.0.1 - An example of a release folder for a tag called `1.0.1`.
- webroot - A symlink to the Drupal root (usually the root of `/code` in this directory).

It is also worth noting that while settings.php will be dynamically generated appropriately to the version of Drupal, if there is a `site-settings.php` file in the
`sites/default` folder it will dynamically be included from the settings.php file.  This is the prefered method of including PHP files.

## For Developers: ##

The ignition suite was designed to be (relatively) easy to follow and to make as few assumptions as are reasonable.  Where possible, command line options are available for
swapping out the handling classes for different functionality.  Ignition Drush uses PSR-0 compliant classes and leverages several Symfony 2 components to keey things nice
and easy for us.

## Dependency Injection ##

We use [Pimple](https://github.com/fabpot/Pimple) as a [Dependency Injection Container](http://fabien.potencier.org/article/12/do-you-need-a-dependency-injection-container).
On the face of it that might seem like overkill for a simple project like this but it serves several purposes:

- Centralizes the construction of context
- Provides a central clearinghouse for all contextual information that must be accessed and stay synchronized across several objects
- Provides a point of extension so that the desired classes or even the factory methods can be swapped out for other factory method at runtime.
- Allows utility functions to be swapped out at runtime without a sophisticated plugin system

### Site ###

This class has methods for all common top level operations though the details are delegated to
child objects.  This is the external most interface and acts as a gateway to the internal services
for performing most common operations (though the internal services are considered public APIs as
well).

### System ###

The system provides information and functionality specific to the operating system environment in use.

### Database ###

A Service class for administering a specific database.

### VCS ###

A handler class for the version control system.

### Server ###

A representation of the web server that will serve Drupal pages.  Server may be a bad idea as it is
different on different systems.  Perhaps this should be collapsed into System.
