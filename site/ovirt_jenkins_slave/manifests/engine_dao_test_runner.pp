# == Class: ovirt_jenkins_slave::engine_dao_test_runner
#
# This class makes sure the jenkins slave has all that's needed to run
# engine DAO tests
#
# === Parameters
#
class ovirt_jenkins_slave::engine_dao_test_runner {

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '127.0.0.1',
    pg_hba_conf_defaults       => false,
    ipv4acls                   => [
      'host all all 127.0.0.1/0 trust',
      'host all all ::1/128 trust',
      'local all all trust',
      'host engine engine 0.0.0.0/0 md5',
      'host engine engine ::0/0 md5',
    ],
  }
}
