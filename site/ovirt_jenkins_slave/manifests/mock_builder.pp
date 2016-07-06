# == Class: ovirt_jenkins_slave::mock_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that builds rpms using mock
#
# === Parameters
#
class ovirt_jenkins_slave::mock_builder (
  $mock_user='jenkins',
) {

  $packages = "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" ? {
    /^RedHat-CentOS-6.*$/  => ['yum-utils', 'mock', 'yum'],
    /^RedHat-Fedora-24$/   => ['yum-utils', 'mock', 'yum', 'nosync', 'python2-requests'],
    default                => ['yum-utils', 'mock', 'yum', 'nosync'],
  }


  package {$packages:
    ensure => latest,
  }

  #TODO: This will override the groups if defined before
  User <| title == $mock_user |> {
    groups  => ['mock'],
    require => Package['mock'],
  }

}
