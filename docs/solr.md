#Solr

[Solr](http://lucene.apache.org/solr/) is highly reliable, scalable and fault tolerant, providing distributed indexing, replication and load-balanced querying, automated failover and recovery, centralized configuration and more.

##Create a Solr Instance
Solr is not installed by default in the VM, but it can be installed and configured easily by creating a Solr instance. Run the following command as root.

    create-solr-instance sitename

For those using Search API, you will want to run the following command as root instead.

    create-solr-instance sitename 7 sapi

##Accessing the Solr Instance
Once you have added the Solr instance, you will need to connect your Drupal site to the Solr Server and create an index. Generally you will want to configure the following apache solr server URL:

    http://localhost:8080/sitename

_*Note:*_ In some cases you may need to restart the tomcat6 server to get the new Solr instance to become active. Run the following command as root.

    service tomcat6 restart


##Remove a Solr Instance
Once you are done with the Solr instance you can delete it with the following command:

    remove-solr-instance sitename

For more information on managing Solr, view the [Solr Wiki](http://wiki.apache.org/solr/).