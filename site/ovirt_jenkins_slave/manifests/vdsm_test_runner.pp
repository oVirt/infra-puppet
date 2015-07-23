# == Class: ovirt_jenkins_slave::vdsm_test_runner
#
# This class makes sure the host has all that's needed to be a jenkins slave
#
# === Parameters
#
class ovirt_jenkins_slave::vdsm_test_runner {
  $packages = [
    'python-pip', 'wget', 'python-nose', 'ethtool', 'pyflakes',
    'python-ethtool', 'libvirt', 'libvirt-python', 'python-pthreading',
    'm2crypto', 'psmisc', 'python-netaddr', 'python-dmidecode',
    'libtool', 'libselinux-python', 'python-kitchen', 'python-cpopen',
    'python-lxml', 'python-inotify', 'python-ply', 'dosfstools',
    'pylint', 'python-six', 'libnl3', 'python-ioprocess', 'python-pep8',
  ]

  include ovirt_jenkins_slave::make_builder
  include ovirt_package::genisoimage
  include ovirt_package::python_devel

  package {$packages:
    ensure => latest,
  }

  if "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" != 'RedHat-Fedora-21' {
    package{'python-ordereddict':
      ensure => latest,
    }
  }

  case "${::osfamily}-${::operatingsystem}" {
    RedHat-Fedora: {

      include ovirt_package::pykickstart

      # Common to all fedoras
      package {['virt-install', 'libguestfs-tools']:
                  ensure => latest,
      }
    }
    ## CentOS machines
    /^RedHat.*/: {
      if $::operatingsystemmajrelease == 6 {
        package {['python-argparse']:
          ensure => latest,
        }
      }

      # Common to all CentOS
      include epel

    }
    default: {
      fail("Unsupported ${::osfamily}-${::operatingsystem}")
    }
  }

  augeas { 'remove vdsm unit test leftovers':
    context => '/files/etc/sudoers',
    changes => [
      'rm Cmnd_Alias[alias/name = "VDSMUT"]',
    ],
  }

}
