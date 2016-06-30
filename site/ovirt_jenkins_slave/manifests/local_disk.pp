# == Class: ovirt_jenkins_slave::local_disk
#
# This class mounts jenkins and mock directories to local disk
#
# === Parameters
#
# jenkins_user
#   User that jenkins will run with
# device
#   Disk device to use as local
# jenkins_lib
#   Path to jenkins files to mount on local disk
# mock_lib
#   Path to mock files to mount on local disk
# mock_cache
#   Path to mock cache files to mount on local disk
#
class ovirt_jenkins_slave::local_disk (
  $jenkins_user='jenkins',
  $device='/dev/vdb',
  $jenkins_lib='/home/jenkins',
  $mock_lib='/var/lib/mock',
  $mock_cache='/var/cache/mock'
) {
  $systemd_etc='/etc/systemd/system'
  # Systemd mount file for /foo/bar is foo-bar.mount
  $jenkins_lib_subst=regsubst(regsubst($jenkins_lib, '^/', ''), '/', '-', 'G')
  $mock_lib_subst=regsubst(regsubst($mock_lib, '^/', ''), '/', '-', 'G')
  $mock_cache_subst=regsubst(regsubst($mock_cache, '^/', ''), '/', '-', 'G')
  $jenkins_lib_mount_file="${jenkins_lib_subst}.mount"
  $mock_lib_mount_file="${mock_lib_subst}.mount"
  $mock_cache_mount_file="${mock_cache_subst}.mount"

  exec {'systemctl daemon-reload':
    refreshonly => true,
  }

  file { "${systemd_etc}/format-local-disk.service":
    content => template('ovirt_jenkins_slave/format-local-disk.service.erb'),
    notify  => Exec['systemctl daemon-reload'],
  }

  file { "${systemd_etc}/srv-local.mount":
    content => template('ovirt_jenkins_slave/srv-local.mount.erb'),
    require => File["${systemd_etc}/format-local-disk.service"],
    notify  => Exec['systemctl daemon-reload'],
  }

  file { "${systemd_etc}/prepare-srv-local.service":
    content => template('ovirt_jenkins_slave/prepare-srv-local.service.erb'),
    require => File["${systemd_etc}/srv-local.mount"],
    notify  => Exec['systemctl daemon-reload'],
  }

  file { "${systemd_etc}/${jenkins_lib_mount_file}":
    content => template('ovirt_jenkins_slave/jenkins-lib.mount.erb'),
    require => File["${systemd_etc}/prepare-srv-local.service"],
    notify  => Exec['systemctl daemon-reload'],
  }

  file { "${systemd_etc}/${mock_lib_mount_file}":
    content => template('ovirt_jenkins_slave/mock-lib.mount.erb'),
    require => File["${systemd_etc}/prepare-srv-local.service"],
    notify  => Exec['systemctl daemon-reload'],
  }

  file { "${systemd_etc}/${mock_cache_mount_file}":
    content => template('ovirt_jenkins_slave/mock-cache.mount.erb'),
    require => File["${systemd_etc}/prepare-srv-local.service"],
    notify  => Exec['systemctl daemon-reload'],
  }

  service { $jenkins_lib_mount_file:
    ensure   => running,
    enable   => true,
    provider => systemd,
    require  => File["${systemd_etc}/${jenkins_lib_mount_file}"],
    notify   => [
      File[$jenkins_lib],
      User[$jenkins_user]
    ],
  }

  service { $mock_lib_mount_file:
    ensure   => running,
    enable   => true,
    provider => systemd,
    require  => File["${systemd_etc}/${mock_lib_mount_file}"],
  }

  service { $mock_cache_mount_file:
    ensure   => running,
    enable   => true,
    provider => systemd,
    require  => File["${systemd_etc}/${mock_cache_mount_file}"],
  }
}
