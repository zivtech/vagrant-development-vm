#Solr

[Apache Solr](http://lucene.apache.org/solr/) is highly reliable, scalable and fault tolerant, providing distributed indexing, replication and load-balanced querying, automated failover and recovery, centralized configuration and more.

Drupal integrates with Solr, as Solr is a more efficient and more powerful search tool compared to Drupal core's search functionality. Solr integration is easy to configure on the Zivtech Vagrant Development VM, as we have included some helpful scripts to get your Solr server instance setup.

##Create a Solr Instance
Solr is not installed by default in the VM, but it can be installed and configured easily by issuing a single command that creates the Solr instance. 

For those using [Apache Solr Search](https://www.drupal.org/project/apachesolr) integration, you will want to run the following command as root, where `sitename` is the name of the site you want to configure Solr search on. The will generate your Solr instance for use with [Apache Solr Search](https://www.drupal.org/project/apachesolr) Drupal module.

    create-solr-instance sitename

For those using [Search API Solr Search](https://www.drupal.org/project/search_api_solr) integration, you will want to run the following command as root instead, where `sitename` is the name of the site you want to configure Solr search on. This will generate your Solr instance for use with the [Search API Solr Search](https://www.drupal.org/project/search_api_solr) and [Search API](https://www.drupal.org/project/search_api) Drupal modules.

    create-solr-instance sitename 7 sapi

##Accessing the Solr Instance
Once you have added the Solr instance, you will need to connect your Drupal site to the Solr Server and create a Solr index. Generally you will want to configure the following Solr server URL:

    http://localhost:8080/sitename

_*Note:*_ In some cases you may need to restart the tomcat6 server to get the new Solr instance to become active. Run the following command as root.

    service tomcat6 restart


##Remove a Solr Instance
Once you are done with the Solr instance you can delete it with the following command:

    remove-solr-instance sitename

##More Information
For more information on managing Solr, view the [Solr Wiki](http://wiki.apache.org/solr/).