#Drush - The Drupal Shell

Drush is a command-line shell and scripting interface for Drupal, a veritable Swiss Army knife designed to make life easier for those who spend their working hours hacking away at the command prompt.

Drush is included in the Zivtech Vagrant Development VM as it helps Drupal developers and Drupal themers execute functions on a Drupal website without having to enter the Drupal UI. This saves time and ultimately leads to more productivity and faster site builds. See the video, [Drush: More Beer, Less Effort](https://vimeo.com/5207683), for a direct comparison between using Drush and not using Drush for some standard Drupal developer tasks. You will quickly see why it is widely used throughout the Drupal community.

##Drush Commands
Drush adds many commands to control your Drupal website. It is easiest to see the what commands are available to your Drush installation by simply typing drush at the command prompt. Depending on what Drush Plugins you have installed, you will have more or less commands on your VM.

    drush

You should see a list of commands available and a short description of their functionality. 

_*Note:*_ You may not see a command listed if you just installed it. Fix that by clearing Drush's cache.

    drush cc drush


##Drush Plugins
Drush Plugins add additional functionality to Drush core. We include some of these plugins in the Zivtech Vagrant Devleopment VM as they are very helpful in our development workflow.

###Drush Patch File
[Drush Patch File](https://bitbucket.org/davereid/drush-patchfile) is a [Drush](https://github.com/drush-ops/drush) plugin that adds a set of Drush commands to help you manage patches on your local Drupal installation.

###Drupal Permissions
While this isn't a true Drush plugin yet, it will be someday. This script will setup the proper secure permission for a Drupal installation and it's files directories.

Read more about Drush in the [Drush docs](http://www.drush.org/en/master/).