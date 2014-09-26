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

  # Mainly for the CVE-2014-6271 secutiry bug
  package{'bash':
    ensure => 'latest',
  }
}
