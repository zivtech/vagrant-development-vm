#Drush Fetcher

[Fetcher](https://www.drupal.org/project/fetcher) is a Drush extension that automates provisioning Drupal sites. It can build new Drupal installations locally or on servers through the command line interface. It can also connect to a Fetcher Services server to manage provisioning sites across multiple servers and environments during Drupal website development.

##Basic Usage
The following command will build a Drupal site with the current stable version of Drupal, currently Drupal 7.

    drush fec somesite

The following command will build a Drupal 8 Standard installation. _*(Must be running the 14.04 VM)*_

    drush fec somesite 8

##Advanced Usage
The following command will build a Drupal 7 installation using the [Bear Installation Profile](https://www.drupal.org/project/bear).

    drush fec somesite --profile="bear"

Learn more advanced usage techniques by reading the [Drush Fetcher Documentation](http://fetcher.readthedocs.org/en/7.x-1.x/).