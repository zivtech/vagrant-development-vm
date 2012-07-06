<?php

namespace Ignition\DBSynchronizer;

interface DBSynchronizerInterface {
  public function syncDB(array $conf);
}
