# Class:: ovirt_backup::gerrit::server
#   Backup server configuration for gerrit
#
class ovirt_backup::gerrit::server(
  $backup_home  = '/export/backup/gerrit',
  $backup_owner = 'gerrit-backup',
  $backup_group = 'backup',
  $ssh_auth_key = undef,
  $ssh_auth_key_type = 'ssh-rsa',
) {
  user { $backup_owner:
    system     => true,
    gid        => $backup_group,
    password   => 'x',
    home       => $backup_home,
    managehome => false,
  }
  file { $backup_home:
    ensure => 'directory',
    owner  => $backup_owner,
    group  => $backup_group,
    mode   => '0640',
  }
  if $ssh_auth_key {
    $real_ssh_auth_key = $ssh_auth_key
    $real_ssh_auth_key_type = $ssh_auth_key_type ? {
      undef   => 'ssh-rsa',
      default => $ssh_auth_key_type,
    }
  } else {
    $real_ssh_auth_key = strip(file("${module_name}/gerrit/ssh_auth.key"))
    $real_ssh_auth_key_type = 'ssh-rsa'
  }
  ssh_authorized_key { $backup_owner:
    user    => $backup_owner,
    type    => $real_ssh_auth_key_type,
    key     => $real_ssh_auth_key,
    require => File[$backup_home],
  }
}
