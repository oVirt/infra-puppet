# Class: ovirt_backup::gerrit::client
#   Setup a backup client for Gerrit (should be included on the Gerrit server)
#
class ovirt_backup::gerrit::client(
  $gerrit_user   = 'gerrit2',
  $gerrit_group  = 'gerrit2',
  $gerrit_home   = '/home/gerrit2',
  $backup_server = 'backup-wdc.ovirt.org',
  $backup_owner  = 'gerrit-backup',
) {
  ensure_resource('file', "${gerrit_home}/bin", {
    'ensure' => directory,
    'owner'  => $gerrit_user,
    'group'  => $gerrit_group,
    'mode'   => 775,
  })
  File {
    owner => $gerrit_user,
    group => $gerrit_user,
    mode  => 0700,
  }
  file {
    "${gerrit_home}/bin/gerrit-gerrit2-home-backup.sh":
      content =>
        template("${module_name}/gerrit/gerrit-gerrit2-home-backup.sh.erb");
    "${gerrit_home}/bin/gerrit-database-backup.sh":
      content =>
        template("${module_name}/gerrit/gerrit-database-backup.sh.erb");
  }
  cron {
    'gerrit-gerrit2-home-backup':
      command => '$HOME/bin/gerrit-gerrit2-home-backup.sh',
      minute  => '20',
      hour    => '22',
      user    => $gerrit_user;
    'gerrit-database-backup':
      command => '$HOME/bin/gerrit-database-backup.sh',
      minute  => '40',
      hour    => '22',
      user    => $gerrit_user;
  }
}
