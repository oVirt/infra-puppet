# Configure the backup client on a Jenkins instance
# this should be applied directly to the VM, or included in
# ovirt_jenkins/manifests/init.pp

class ovirt_backup::jenkins::client(
  $duplicity_version='0.6.24-5.el7'
) {
  package { 'duplicity':
    ensure => $duplicity_version,
  }
}
