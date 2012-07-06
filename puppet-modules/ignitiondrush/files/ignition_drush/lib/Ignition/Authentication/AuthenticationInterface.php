<?php
namespace Ignition\Authentication;

  /**
   *
   */
interface AuthenticationInterface {

  /**
   * Recieve a client object similar to \Ignition\Utility\HTTPClient() and add authentication parameters.
   *
   * @param $client
   *   An HTTPClient descended object.
   * @return Void
   */
  public function addAuthenticationToHTTPClientFromDrushContext(\Ignition\Utility\HTTPClient $client);

}
