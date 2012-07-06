<?php

namespace Ignition\InfoFetcher;

class IgnitionServices implements InfoFetcherInterface {

  public function __construct(Pimple $site) {
    $this->site = $site;
  }

  public function listSites($name = '', $page = 0) {
    $container = \Ignition\Site::getServiceContainerFromDrushContext();
    $client = $container['ignition client'];
    $client->setPath('ignition/api/site.json');

    // If we have a name to search for add it to the query.
    if ($name != '') {
      $client->addParam('name', $name);
    }
    // If we are paging past the first 100 results, add the page.
    if ($page) {
      $client->addParam('page', $page);
    }

    // Execute the request and decode the response.
    $result = $client->fetch();
    if (!empty($result) && $result) {
      return $result;
    }
    else {
      drush_log(dt('The data could not be retrieved from the server. Error code @code received rom server.', array('@code' => $client->getResponseCode())), 'error');
    }
  }

  public function getInfo($site_name) {
    $container = \Ignition\Site::getServiceContainerFromDrushContext();
    $client = $container['ignition client'];
    $result = $client
      ->setPath("ignition/api/site/$site_name.json")
      ->fetch();
    if ($result === FALSE) {
      $code = $client->getResponseCode();
      if ($code == 401) {
        // If access was denied, lets provide the server message for a hint as to why.
        $meta = $client->getMetadata();
        // The response code should be the first line in the response.
        if (isset($meta['wrapper_data'][0])) {
          $code = $meta['wrapper_data'][0];
          $parts = explode(' ', $code);
          // Remove the protocol and code leaving the message.
          array_shift($parts);
          array_shift($parts);
          $message = implode(' ', $parts);
          drush_log(dt('Server message: @message', array('@message' => $message)), 'error');
        }
        drush_log(dt('Access was denied, please check your authentication credentials.'), 'error');
      }
      else if ($code == 404) {
        drush_log(dt('The requested site could not be found on the server.'), 'error');
      }
      else {
        drush_log(dt('The data could not be retrieved from the server. Error code @code received rom server.', array('@code' => $code)), 'error');
      }
      return FALSE;
    }
    return $result;
  }

}
