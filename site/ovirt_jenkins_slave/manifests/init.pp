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
  include ovirt_jenkins_slave::base
  class{'ovirt_jenkins_slave::sudo':
    user => $jenkins_user,
  }
  # Requirements for non packaging jobs
  include ovirt_jenkins_slave::vdsm_test_runner
  include ovirt_jenkins_slave::engine_test_runner
  include ovirt_jenkins_slave::engine_dao_test_runner
  include ovirt_jenkins_slave::puppet_test_runner
  include ovirt_jenkins_slave::ovirt_optimizer_test_runner
  # packaging jobs requirements
  include ovirt_jenkins_slave::ovirt_node_builder
  include ovirt_jenkins_slave::mock_builder
}
