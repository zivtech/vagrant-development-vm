#Drush Patch File

[Drush Patch File](https://bitbucket.org/davereid/drush-patchfile) is a [Drush](https://github.com/drush-ops/drush) plugin that adds a set of Drush commands to help you manage patches on your local Drupal installation. Patches can be added to Drush make files that will get applied on installation, but typically it has been difficult to manage those patches after installation has been completed and security updates or version updates are made to Drupal core, Drupal modules, or Drupal themes. Enter Drush Patch File, which allows for patches to be managed easily after initial installation is complete.

##Patching with Drush Patch File
Patching Drupal core, modules, and themes is much easier with Drush Patch File. The Zivtech Vagrant Development VM is pre-configured to use Drush Patch File by adding the following file to your Drupal installations root folder. For those who used Drush Fetcher Create to create a site, you would add the patches.make file in the following location:

    /var/www/somesite/webroot/patches.make

##Drush Commands
###Patch Add
Once the patches.make file has been created you can start adding the patches you need to apply in your project.

    drush patch-add noderefcreate https://drupal.org/files/763454-9.patch

    or

    drush pa noderefcreate https://drupal.org/files/763454-9.patch

###Patch-Status
Check the status of patches included in your patches.make file to see if they have been applied.

    drush patch-status

    or

    drush ps


###Patch-Project
Use this command to apply patches against a given project. If for example you've updated a module and need to re-apply patches, you would use this command with that module name to do that.

    drush patch-project views

    or

    drush pp views

###Patch-Apply-All
Use this command to apply all the patches listed in the patch file.

    drush patch-apply-all

    or

    drush paa

###PM-Download
If you are running a drush dl on a module or theme that has a related patch, after the download has been completed, the patch utility will attempt to apply the patches again to the project. Use the patch application messages to see if you will need to reroll the patch, or if it has been fixed.

    drush dl views

Learn more about [Drush Patch File](https://bitbucket.org/davereid/drush-patchfile).