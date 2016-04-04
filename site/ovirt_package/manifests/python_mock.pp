# == Class: ovirt_packages::python-mock
#
# This class makes sure that the python-mock package is installed,
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
class ovirt_package::python_mock(
  $ensure = 'latest',
){
  case "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" {
    /^(RedHat-RedHat-7.*|RedHat-CentOS-7.*)$/: {
    $package_name = 'python2-mock'
  }

  default: {
    $package_name = 'python-mock'
    }
  }

  package{'python-mock':
      ensure => $ensure,
      name   => $package_name,
  }

}
