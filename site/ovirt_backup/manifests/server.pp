# Class: ovirt_backup::server
#   Configuration for an oVirt infra backup server
#
class ovirt_backup::server(
  $home_base      = '/export',
  $backup_home    = '/export/backup',
  $backup_group   = 'backup',
  $backup_pv      = '/dev/vdb',
  $mk_backup_pv   = true,
  $backup_vg      = 'backupvg',
  $mk_backup_vg   = true,
  $backup_lv      = 'backuplv',
  $mk_backup_lv   = true,
  $mnt_backup_lv  = true,
  $backup_lv_size = '60G'
) {
  include ovirt_base

  ensure_packages(['lvm2', 'rsync'])

  if $mk_backup_pv {
    physical_volume { $backup_pv:
      ensure => 'present',
    }
  }
  if $mk_backup_vg {
    volume_group { $backup_vg:
      ensure           => 'present',
      physical_volumes => $backup_pv,
    }
    if $mk_backup_pv {
      Physical_volume[$backup_pv] -> Volume_group[$backup_vg]
    }
  }
  $backup_fs_dev = "/dev/${backup_vg}/${backup_lv}"
  if $mk_backup_lv {
    logical_volume { $backup_lv:
      ensure          => 'present',
      volume_group    => $backup_vg,
      size            => $backup_lv_size,
      size_is_minsize => true,
    }
    filesystem { $backup_fs_dev:
      ensure  => 'present',
      fs_type => 'xfs',
    }
    if $mk_backup_vg {
      Volume_group[$backup_vg] -> Logical_volume[$backup_lv]
    }
    Logical_volume[$backup_lv] -> Filesystem[$backup_fs_dev]
  }
  if $mnt_backup_lv {
    mount { $backup_home:
      ensure  => 'mounted',
      atboot  => true,
      device  => $backup_fs_dev,
      fstype  => 'xfs',
      options => 'noatime',
    }
    if $mk_backup_lv {
      Filesystem[$backup_fs_dev] -> Mount[$backup_home]
    }
    Mount[$backup_home] ->
    Class['ovirt_backup::gerrit::server']
  }
  if $home_base {
    ensure_resource('file', $home_base, { 'ensure' => 'directory' })
  }
  file { $backup_home:
    ensure => 'directory',
  }
  group { $backup_group:
    ensure => 'present',
    system => true,
  }

  class { 'ovirt_backup::gerrit::server':
    backup_home  => "${backup_home}/gerrit",
    backup_group => $backup_group,
  }
  class { 'ovirt_backup::jenkins::server':
    backup_home  => "${backup_home}/jenkins",
    backup_group => $backup_group,
  }
  class { 'ovirt_backup::engine::server':
    backup_home  => "${backup_home}/engine",
    backup_group => $backup_group,
  }
  class { 'ovirt_backup::rsync::server':
    backup_home  => "${backup_home}/rsync",
    backup_group => $backup_group,
  }
}
