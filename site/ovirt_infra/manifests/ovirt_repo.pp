# == Class: ovirt_infra::ovirt_repo
#
# This class creates the repo file for the oVirt project
#
# === Parameters
#
# [*flavour*]
#
# Which flavour of repo to create (stable, nightly...)
#
class ovirt_infra::ovirt_repo($flavour='stable') {
  case $::operatingsystem {
    'CentOS': {
      case $flavour {
        'stable':     { $flavour_url = 'stable/rpm/EL' }
        'stable-3.3': { $flavour_url = '3.3/rpm/EL' }
        'stable-3.2': { $flavour_url = '3.2/rpm/EL' }
        'nightly':    { $flavour_url = 'nightly/rpm/EL' }
        default:      { fail("Unsupported flavour ${flavour} on ${::operatingsystem}") }
      }
    }
    'Fedora': {
      case $flavour {
        'stable':     { $flavour_url = "stable/rpm/${::operatingsystem}" }
        'stable-3.3': { $flavour_url = "3.3/rpm/${::operatingsystem}" }
        'stable-3.2': { $flavour_url = "3.2/rpm/${::operatingsystem}" }
        'nightly':    { $flavour_url = "nightly/rpm/${::operatingsystem}" }
        default:      { fail("Unsupported flavour ${flavour} on ${::operatingsystem}") }
      }
    }
    default: { fail("Unsupported operatingsystem ${::operatingsystem}") }
  }

  yumrepo { "oVirt ${flavour}":
    baseurl  => "http://resources.ovirt.org/releases/${flavour_url}/${::operatingsystemrelease}",
    descr    => "oVirt ${flavour}",
    enabled  => '1',
    gpgcheck => '0',
  }
}
