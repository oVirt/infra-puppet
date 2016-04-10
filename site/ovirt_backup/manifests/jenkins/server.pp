# Class:: ovirt_backup::jenkins::server
#   Backup server configuration for jenkins
#
class ovirt_backup::jenkins::server(
  $backup_home  = '/export/backup/jenkins',
  $backup_owner = 'jenkins-backup',
  $backup_group = 'backup',

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

  Ssh_authorized_key <<| tag == 'jenkins_sshrsa' |>>
  {
    user    => $backup_owner,
    type    => 'ssh-rsa',
    require => File[$backup_home],
  }

}
