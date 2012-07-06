<?php

namespace Ignition\InfoFetcher;

interface InfoFetcherInterface {
  public function getInfo($name);

  public function listSites($name = '', $page = 0);
}
