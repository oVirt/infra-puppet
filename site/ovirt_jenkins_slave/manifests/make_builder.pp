# == Class: ovirt_jenkins_slave::make_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that can run make and autotools
#
# === Parameters
#
class ovirt_jenkins_slave::make_builder {
  $packages = ['autoconf', 'automake', 'make', 'gettext-devel',]

  package {$packages:
    ensure => latest,
  }

}
