# == Class: ovirt_jenkins_slave::puppet_test_runner
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that runs the puppet checks
#
# === Parameters
#
class ovirt_jenkins_slave::puppet_test_runner {
  $packages = [
    'rubygem-puppet-lint',
    'rubygem-rspec-puppet',
  ]
  package {$packages:
    ensure => latest,
  }
}
