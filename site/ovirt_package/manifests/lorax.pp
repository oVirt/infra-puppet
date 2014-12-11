# == Class: ovirt_packages::lorax
#
# This class makes sure that the lorax package is installed,
# wrap around puppet package so you can include the class multiple
# times
#
# === Parameters
#
# ensure
#   Value for the ensure parameter, if other than the default used,
#   you'll loose the ability to include multiple times the package but
#   you'll be able to specify a version, latest by default
#
class ovirt_package::lorax(
  $ensure = 'latest',
){
  package{'lorax':
    ensure => $ensure,
  }
}
