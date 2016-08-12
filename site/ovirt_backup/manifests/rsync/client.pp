# Class: ovirt_backup::rsync::client
#   rsync backups off-site
#
class ovirt_backup::rsync::client(
  $rsync_user   = 'root',
  $rsync_group  = 'root',
  $remote_directory = '/export/backup',
  $local_directory = '/var/backup_mirror',
  $backup_server = 'backup.phx.ovirt.org',
  $backup_owner  = 'rsync-backup',
) {
  ensure_resource('file', "${local_directory}/", {
    'ensure' => directory,
    'owner'  => $rsync_user,
    'group'  => $rsync_group,
    'mode'   => 700,
  })
  ensure_packages([ 'rsync'])
  cron { 'rsync-backup':
    command => "flock -w 30 /var/run/ovirt_backup_rsync.lock \
      rsync -az -e \"ssh -o PasswordAuthentication=false\" \
      --bwlimit=2048  --exclude=\".*\" --exclude \".*/\" \
      ${backup_owner}@${backup_server}:${remote_directory} ${local_directory}",
    minute  => '20',
    hour    => '02',
    user    => $rsync_user
  }
}
