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

  case $::operatingsystem {
    'CentOS': {
      include ovirt_package::lorax
      package {['python-imgcreate',
                'squashfs-tools',
                'syslinux',
                'pyparted',
                'mkisofs',
                'isomd5sum',
                'hfsplus-tool',
                'syslinux-extlinux',
                'dumpet',
                ]:
        ensure => latest,
      }
    }
    default: {
      #TBD
    }
  }

  package {$packages:
    ensure => latest,
  }
}
