# == Class: ovirt_jenkins_slave::make_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that can run make and autotools
#
# === Parameters
#
class ovirt_jenkins_slave::make_builder {
  $packages = ['make', 'gettext-devel',]

  include ovirt_package::autoconf
  include ovirt_package::automake

  package {$packages:
    ensure => latest,
  }

}
