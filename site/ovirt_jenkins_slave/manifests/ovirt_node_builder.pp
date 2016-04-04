# == Class: ovirt_jenkins_slave::ovirt_node_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that builds ovirt-node images
#
# === Parameters
#
class ovirt_jenkins_slave::ovirt_node_builder () {
  include ovirt_package::automake
  include ovirt_package::autoconf
  include ovirt_package::createrepo
  include ovirt_package::pykickstart
  include ovirt_package::python_devel

  $common_packages = [
    'checkpolicy',
    'fedora-packager',
    'hardlink',
    'livecd-tools',
    'ltrace',
    'python-lockfile',
    'rpm-build',
    'selinux-policy-doc',
  ]

  $f20_packages = [
    'appliance-tools-minimizer',
    'appliance-tools',
    'selinux-policy-devel',
  ]

  $el7_packages = [
    'dumpet',
    'isomd5sum',
    'lorax',
    'hfsplus-tools',
    'pyparted',
    'python-imgcreate',
    'squashfs-tools',
    'syslinux',
    'syslinux-extlinux',
    'system-config-keyboard',
    'selinux-policy-devel',
  ]

  case "${::operatingsystem}-${::operatingsystemrelease}" {
    'Fedora-20': {
      package {$common_packages:
        ensure => latest,
      }
      package {$f20_packages:
        ensure => latest,
      }
    }
    /^CentOS-7.*/: {
      include ovirt_package::genisoimage
      package {$common_packages:
        ensure => latest,
      }
      package {$el7_packages:
        ensure => latest,
      }
    }
    /^CentOS-6.*/: {
      include ovirt_package::genisoimage
      package {$common_packages:
        ensure => latest,
      }
    }
    default: {
      package {$common_packages:
        ensure => latest,
      }
    }
  }
}
