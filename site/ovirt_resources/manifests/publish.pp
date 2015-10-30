# Handles new artifacts publishing and purge of the old ones
class ovirt_resources::publish(
  $resources_dir = '/srv/resources',
  $incoming_dir  = '/home/jenkins/artifacts',
) {
  $releng_git  = 'git://gerrit.ovirt.org/releng-tools'
  $releng_path = '/usr/local/libexec/releng-tools'

  include ovirt_infra::user::system::jenkins

  file { $incoming_dir:
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  package { 'git':
    ensure => present,
  }

  vcsrepo { $releng_path:
    ensure   => latest,
    provider => git,
    source   => $releng_git,
    revision => 'master'
  }

  file { '/etc/cron.d/clean_jenkins_nightly':
    content => template('ovirt_resources/clean_jenkins_nightly.erb'),
  }

  file { '/etc/cron.d/move_jenkins_nightly':
    content => template('ovirt_resources/move_jenkins_nightly.erb'),
  }

}
