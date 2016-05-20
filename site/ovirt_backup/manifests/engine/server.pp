# Class:: ovirt_backup::engine::server
#   Backup server configuration for Engine
#
class ovirt_backup::engine::server(
  $backup_home  = '/export/backup/engine',
  $backup_owner = 'engine-backup',
  $backup_group = 'backup',
  $sshkey       = 'undef',

) {
  user { $backup_owner:
    system     => true,
    gid        => $backup_group,
    home       => $backup_home,
    managehome => false,
  }
  file { $backup_home:
    ensure => 'directory',
    owner  => $backup_owner,
    group  => $backup_group,
    mode   => '0640',
  }

  ssh_authorized_key { $backup_owner:
    user    => $backup_owner,
    type    => 'ssh-rsa',
    key     => $sshkey,
    require => File[$backup_home],
  }

}
