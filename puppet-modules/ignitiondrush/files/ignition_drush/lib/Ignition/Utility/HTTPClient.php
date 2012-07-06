<?php

/**
 * @file
 *   Provide a convenient and fully featured HTTP client without any
 *   reliance on bootstrapping Drupal (drupal_http_request) curl, or
 *   enabling `allow_url_fopen` by using PHP streams.
 */

namespace Ignition\Utility;


class HTTPClient {

  /**
   * The URL that will be used for the request.
   */
  public $url = '';

  /**
   * The path of within the URL without a leading `/` (which is added
   * automatically).
   */
  public $path = '';

  /**
   * An internal list of parameters to be used in the request.
   */
  public $params = array();

  /**
   * An array of headers to be used inthe request.
   */
  public $headers = array();

  /**
   * The HTTP request method, acceptable values are GET, SET, PUT,
   * POST and DELETE.
   */
  public $method = 'GET';

  /**
   * An array of supported encodings and their decode functions.
   */
  protected $encodings = array();

  /**
   * The encoding to be requested, acceptable values are json and xml.
   */
  public $encoding = FALSE;

  /**
   * The timeout for this request.
   */
  public $timeout = FALSE;

  /**
   * A container for the raw response of the request.
   */
  public $response = FALSE;

  /**
   * A container for the metadata returned from the stream wrapper,
   * useful for tracking down redirects and the like.
   */
  public $meta = FALSE;

  /**
   * A constructor function to register our default encodings and set a default encoding.
   */
  public function __construct() {

    // Register plaintext decoding (the default).
    $plainTextDecode = function($textString) {
      return (string) $textString;
    };
    $plainTextEncode = function(Array $textString) {
      return $params = http_build_query($params);
    };
    $this->registerEncoding('plain', 'text/plain', $plainTextDecode, $plainTextEncode);

    // Default our decoding to plain
    $this->setEncoding('plain');

    // Register our json decoding.
    $jsonDecode = function($jsonString) {
      $response = json_decode($jsonString);
      if ($response === null) {
        $response = FALSE;
      }
      return $response;
    };
    $jsonEncode = function(Array $params) {
      return json_encode($params);
    };
    $this->registerEncoding('json', 'application/json', $jsonDecode, $jsonEncode);

    // Register xml decoding.
    $xmlDecode = function($xmlString) {
      $response = simplexml_load_string($xmlString);
      if ($response === null) {
        $response = FALSE;
      }
      return $response;
    };
    $this->registerEncoding('xml', 'application/xml', $xmlDecode, $plainTextEncode);

    // Register serialized PHP decoding.
    $phpDecode = function($serializedPhpString) {
      return unserialize($serializedPhpString);
    };
    $phpEncode = function(Array $params) {
      return serialize($params);
    };
    $this->registerEncoding('php', 'application/vnd.php.serialized', $phpDecode, $phpEncode);

  }

  /**
   * Set the URL for this request.
   *
   * @param $url
   *   The URL against which to make the request.
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function setURL($url, $port = FALSE) {
    $this->url = $url;
    if ($port) {
      $this->url = $url . ':' . $port;
    }
    return $this;
  }

  /**
   * Set the path to go after the URL.
   *
   * @param $path
   *   The path to be added to the $url without a leading `/` (which is added automatically).
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function setPath($path) {
    $this->path = $path;
    return $this;
  }

  /**
   * Set the HTTP method to be used.
   *
   * @param $method
   *   The method to use for the request. Acceptable values are `GET`, `PUT`, `POST`, and `DELETE`.
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function setMethod($method) {
    $this->method = $method;
    return $this;
  }

  /**
   * Set the encoding to be used.
   *
   * @param $encoding
   *   The encoding with which to send and receive data.  Acceptable values
   *   by default are `plain`, `xml` and `json` defaulting to `plain`.  New
   *   encodings may be added via the HTTPClient::registerEncoding() method.
   * @return
   *   This request object, allowing this method to be chainable on success,
   *   FALSE on failure.
   */
  public function setEncoding($encoding) {
    if (isset($this->encodings[$encoding])) {
      $this->encoding = $encoding;
      return $this;
    }
    else {
      return FALSE;
    }
  }

  /**
   * Set a header string.
   *
   * @param $name
   *   The name of the header to set (the string before the colon).
   * @param $value
   *   The value of the header to set (the string after the colon and space).
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function setHeader($name, $value) {
    $this->headers[$name] = $value;
    return $this;
  }

  /**
   * Set username and password to use basic HTTP authentication.
   *
   * This is a convenience method to set the appropriate header
   * for basic HTTP authentication.
   *
   * @param $username
   *   A string containing the plaintext username.
   * @param $password
   *   A string containing the plaintext password.
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function setBasicAuth($username, $password) {
    $this->setHeader('Authorization', 'Basic ' .  base64_encode($username.':'.$password));
    return $this;
  }

  /**
   * Reset the response data so that a similar request
   * can be made with the same object.
   *
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function reset() {
    $this->response = FALSE;
    $this->meta = FALSE;
    return $this;
  }

  /**
   * Add a parameter for this request.
   *
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function addParam($name, $value) {
    $this->params[$name] = $value;
    return $this;
  }

  /**
   * Remove a parameter from this request.
   *
   * @return
   *   This request object, allowing this method to be chainable.
   */
  public function removeParam($name, $value) {
    unset($this->params[$name]);
    return $this;
  }

  /**
   * Execute the request and return the response object.
   *
   * This method returns this request object rather than the response
   * under the assumption that HTTPRequest::decode() will likely be called immediately after.
   *
   * @return
   *   The body of the request or FALSE of failure.
   */
  public function execute() {

    $request_url = $this->url;

    if ($this->path != '') {
      $request_url = $request_url . '/' . $this->path;
    }
    $context_parameters = array(
      'http' => array(
        'method' => $this->method,
        'ignore_errors' => true,
        'user_agent' => 'drush',
      )
    );

    if ($this->timeout) {
      $context_parameters['http']['timeout'] = ($this->timeout['seconds'] * 60) + $this->timeout['microseconds'];
    }

    // Use the configured mime type, this shuold always be set because we default
    // to plain.
    $mimeType = $this->encodings[$this->encoding]['mime type'];
    if (!isset($this->headers['Content Type'])) {
      $this->setHeader('Content-Type', $mimeType);
    }
    if (!isset($this->headers['Accept'])) {
      $this->setHeader('Accept', $mimeType);
    }
    if (count($this->headers)) {
      $headers = array();
      foreach ($this->headers as $name => $value) {
        $headers[] = $name . ': ' . $value;
      }
      $context_parameters['http']['header'] = $headers;
    }
    if (!empty($this->params) && count($this->params) > 0) {
      if (in_array($this->method, array('POST', 'PUT'))) {
        $params = $this->encode();
        $context_parameters['http']['content'] = $params;
      }
      else {
        $params = http_build_query($this->params);
        $request_url .= '?' . $params;
      }
    }
    $context = stream_context_create($context_parameters);
    $file_resource = @fopen($request_url, 'rb', false, $context);
    if (!$file_resource) {
      $response = false;
    }
    else {
      // Track redirects and other metadata in a member variable.
      $this->meta = stream_get_meta_data($file_resource);
      $response = stream_get_contents($file_resource);
    }
    return $this->response = $response;
  }

  public function setTimeout($seconds, $microseconds = 0) {
    $this->timeout = array('seconds' => $seconds, 'microseconds' => $microseconds);
    return $this;
  }

  /**
   * Decode the response.
   *
   * If encoding is set to something we understand, decode the response.
   *
   * See HTTPClient::registerEncoding() to add encodings.
   *
   * @return
   *  The decoded PHP representation of the data.
   */
  public function decode() {
    if ($this->encoding && isset($this->encodings[$this->encoding]) && $this->response) {
      return $this->encodings[$this->encoding]['decode']($this->response);
    }
  }

  /**
   * Decode the response.
   *
   * If encoding is set to something we understand, decode the response.
   *
   * See HTTPClient::registerEncoding() to add encodings.
   *
   * @return
   *  The decoded PHP representation of the data.
   */
  public function encode() {
    if ($this->encoding && isset($this->encodings[$this->encoding])) {
      return $this->encodings[$this->encoding]['encode']($this->params);
    }
  }

  /**
   * Make the request and decode the response.
   *
   * This is a convenience wrapper around execute() and decode().
   */
  public function fetch() {
    $this->execute();
    if (!$this->getTimeoutStatus() && $this->getResponseCode() == 200) {
      return $this->decode();
    }
    return FALSE;
  }

  /**
   * Retrieve the response response code for the previously executed request.
   *
   * @return
   *   Numeric HTTP Response code, NULL if this request has not been executed.
   */
  public function getResponseCode() {
    if ($this->meta) {
      $responseCode = $this->meta['wrapper_data'][0];
      $parts = explode(' ', $responseCode);
      return $parts[1];
    }
  }

  /**
   * Check whether the previous execution of this request timed out.
   *
   * @return
   *   Boolean value, NULL if this request has not been executed.
   */
  public function getTimeoutStatus() {
    if ($this->meta) {
      return $this->meta['timed_out'];
    }
  }

  /**
   * Get the result.
   *
   * Returns the raw result string.
   *
   * @return
   *   The string returned from the request.
   */
  public function getResult() {
    return $this->response;
  }

  /**
   * Get the metadata from this request.
   */
  public function getMetadata() {
    return $this->meta;
  }

  /**
   * Register a encoding and provide a function to deal with it.
   */
  public function registerEncoding($name, $mimeType, \Closure $decode, \Closure $encode) {
    // It would be cool to allow decode callbacks to be injected to allow
    // support for arbitrary encodings.
    // TODO: The body of this function :D.
    $this->encodings[$name] = array(
      'encode' => $encode,
      'decode' => $decode,
      'mime type' => $mimeType,
    );
  }
}
