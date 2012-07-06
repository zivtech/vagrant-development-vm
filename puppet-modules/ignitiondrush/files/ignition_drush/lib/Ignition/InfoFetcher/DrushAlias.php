<?php

namespace Ignition\InfoFetcher;

class DrushAlias  implements InfoFetcherInterface {

  /**
   * Implements Ignition\InfoFetcher\InfofetcherInterface::listSites().
   *
   * List all sites specidied in the drush aliases.
   */
  public function listSites($name = '', $page = 0) {
    // TODO: Add name searching.
    $aliases = _drush_sitealias_find_and_load_all_aliases();
    $sites = array();
    $list = array();
    // TODO: We need to handle multiple environments here.
    foreach ($aliases as $name => $alias) {
      if (!empty($alias['ignition'])) {
        $info = $alias['ignition'];
        if (!empty($list[$info['name']])) {
          $info = ((array) $list[$info['name']] + $info);
        }
        // Our code expects this to be a set of nested objects, not arrays.
        $objectify = function ($array) use (&$objectify) {
          if (is_array($array)) {
            foreach ($array as &$item) {
              if (is_array($item)) {
                $item = $objectify($item);
              }
            }
          }
          return (object) $array;
        };
        $list[$info['name']] = (object) $objectify($info);
      }
    }
    return $list;
  }

  /**
   * Implements Ignition\InfoFetcher\InfofetcherInterface::getInfo().
   */
  public function getInfo($name) {
    $sites = $this->listSites($name);
    if (isset($sites[$name])) {
      return $sites[$name];
    }
  }

}
