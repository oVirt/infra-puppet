# == Class: ovirt_selinux
#
# Small wrapper around community selinux module to allow CentOS 6 machines
#
# === Parameters
#
class ovirt_selinux ($mode) {

  case "${::osfamily}-${::operatingsystem}-${::os_maj_version}" {

    /^RedHat-.*-6/: {
      $mode_int = $mode ? {
        'enforcing'  => 1,
        'permissive' => 0,
        'disabled'   => 0,
        default      => fail("Unsupported selinux mode passed ${mode}"),
      }
      if $::selinux_current_mode != $mode {
        exec {"setenforce ${mode_int}":
          command => "/usr/sbin/setenforce ${mode_int}"
        }
      }

      if ! $::selinux or $::selinux_config_mode != $mode {
        file {'/etc/selinux/config':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('ovirt_selinux/selinux_config.erb')
        }
      }
    }

    default: {
      class { 'selinux':
        mode => $mode
      }
    }
  }
}
