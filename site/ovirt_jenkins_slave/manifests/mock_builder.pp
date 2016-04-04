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

  $packages = "${::osfamily}-${::operatingsystemrelease}" ? {
    /RedHat-6.*/ => ['yum-utils', 'mock', 'yum'],
    default      => ['yum-utils', 'mock', 'yum', 'nosync'],
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
