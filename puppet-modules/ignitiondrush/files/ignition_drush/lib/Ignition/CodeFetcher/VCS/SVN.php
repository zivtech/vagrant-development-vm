<?php

namespace Ignition\CodeFetcher\VCS;

class SVN {

  public function initialCheckout() {
    /*
    if label == 'trunk':
      remoteRepository = remoteRepository + '/trunk'
    # Otherwise, if the label has a .x in its name, it's one of our branches so check it out.
    elif (label):
      remoteRepository = remoteRepository + '/branches/' + label
    else:
      # Otherwise we're checkout out one of our tags.
      remoteRepository = remoteRepository + '/tags/' + label
    */
  }

  public function switchRefs() {
  }

  public function update($localDirectory, $label = '') {
    //update = "svn up %s" % (localDirectory)
  }
}
