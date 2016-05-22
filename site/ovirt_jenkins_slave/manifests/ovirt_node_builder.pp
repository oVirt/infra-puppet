# == Class: ovirt_jenkins_slave::ovirt_node_builder
#
# This class makes sure the host has all that's needed to be a jenkins
# slave that builds ovirt-node images
#
# === Parameters
#
class ovirt_jenkins_slave::ovirt_node_builder () {
  include ovirt_package::automake
  include ovirt_package::autoconf
  include ovirt_package::createrepo
  include ovirt_package::pykickstart
  include ovirt_package::python_devel
  include ovirt_package::genisoimage
  $node_packages = [
    'checkpolicy',
    'fedora-packager',
    'hardlink',
    'livecd-tools',
    'ltrace',
    'python-lockfile',
    'rpm-build',
    'selinux-policy-doc',
    'dumpet',
    'isomd5sum',
    'lorax',
    'hfsplus-tools',
    'pyparted',
    'python-imgcreate',
    'squashfs-tools',
    'syslinux',
    'syslinux-extlinux',
    'system-config-keyboard',
    'selinux-policy-devel',
  ]
  package {$node_packages:
    ensure => latest,
  }
}
