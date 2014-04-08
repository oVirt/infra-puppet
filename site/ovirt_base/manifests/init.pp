# == Class: ovirt_base
#
# Ovirt base contains all the manifests that will be applied to all the machines
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'ovirt_base':
#  }
#

class ovirt_base {
  class { 'puppet': }
}
