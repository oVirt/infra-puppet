# == Class: ovirt_jenkins_slave::ovirt_optimizer_test_runner
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that runs the ovirt optimizer checks
#
# === Parameters
#
class ovirt_jenkins_slave::ovirt_optimizer_test_runner {
  $packages = [
    'symlinks',
  ]
  package {$packages:
    ensure => latest,
  }
}
