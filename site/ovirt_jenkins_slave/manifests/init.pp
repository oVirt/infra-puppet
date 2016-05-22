# == Class: ovirt_jenkins_slave
#
# This class makes sure the host has all that's needed to be a jenkins slave
#
# === Parameters
#
# jenkins_user
#   User that jenkins will run with
#
#
class ovirt_jenkins_slave (
  $jenkins_user='jenkins',
) {

  class{'ovirt_jenkins_slave::sudo':
    user => $jenkins_user,
  }
  include ovirt_jenkins_slave::base
  # Requirements for non packaging jobs
  include ovirt_jenkins_slave::engine_test_runner
  include ovirt_jenkins_slave::engine_dao_test_runner
  # node builder jobs only run on el7
  if "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" =~ /^(RedHat-RedHat-7.*|RedHat-CentOS-7.*)$/ {
      include ovirt_jenkins_slave::ovirt_node_builder
  }
  # packaging jobs requirements
  include ovirt_jenkins_slave::mock_builder
}
