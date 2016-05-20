# Class: ovirt_backup::engine::client
#   Setup a backup client for Engine
#
class ovirt_backup::engine::client(
  $engine_user   = 'root',
  $engine_group  = 'root',
  $engine_backups = '/var/backups',
  $backup_server = 'backup.phx.ovirt.org',
  $backup_owner  = 'engine-backup',
) {
  ensure_resource('file', "${engine_backups}/", {
    'ensure' => directory,
    'owner'  => $engine_user,
    'group'  => $engine_group,
    'mode'   => 700,
  })
  File {
    owner => $engine_user,
    group => $engine_user,
    mode  => 0700,
  }
  file {
    '/usr/local/sbin/engine-backup.sh':
      content =>
        template("${module_name}/engine/engine-backup.sh.erb");
  }
  cron {
    'engine-backup':
      command => '/usr/local/sbin/engine-backup.sh',
      minute  => '20',
      hour    => '23',
      user    => $engine_user;
  }
}
