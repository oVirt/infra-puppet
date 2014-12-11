# == Class: ovirt_jenkins_slave::ovirt_node_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that builds ovirt-node images
#
# === Parameters
#
class ovirt_jenkins_slave::ovirt_node_builder () {
  $packages = [
    'livecd-tools',
    'appliance-tools',
    'appliance-tools-minimizer',
    'fedora-packager',
    'rpm-build',
    'selinux-policy-doc',
    'checkpolicy',
    'selinux-policy-devel',
    'hardlink',
    'ltrace',
    'python-lockfile',
  ]

  include ovirt_package::python_devel
  include ovirt_package::createrepo
  include ovirt_package::python_mock
  include ovirt_package::automake
  include ovirt_package::autoconf
  include ovirt_package::pykickstart

  case "${::operatingsystem}-${::operatingsystemrelease}" {
    'Fedora-20': {
      package {$packages:
        ensure => latest,
      }
    }
    default: {
      #TBD only fedora 20 for now
    }
  }
}
