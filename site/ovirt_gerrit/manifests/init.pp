# This manifests manages gerrit.ovirt.org
class ovirt_gerrit() {
  # restart gerrit weekly
  cron { 'gerrit-restart':
    command => '/sbin/service gerrit restart',
    hour    => '0',
    minute  => '0',
    weekday => '6',
  }
}

