<?php

namespace Ignition;

class Base {

  public function configure($config) {
    foreach ($config as $name => $value) {
      if (isset($this->{$name}) && $value != '') {
        $this->{$name} = $value;
      }
    }
  }

}
