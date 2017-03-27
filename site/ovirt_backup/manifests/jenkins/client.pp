# Configure the backup client on a Jenkins instance
# this should be applied directly to the VM, or included in
# ovirt_jenkins/manifests/init.pp

class ovirt_backup::jenkins::client(
) {
  package { 'duplicity':
    ensure => installed,
  }
}
