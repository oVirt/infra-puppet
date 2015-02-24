# == Class: ovirt_jenkins_slave::base
#
# This class makes sure the host has the basic stuff needed to be a
# jenkins slave
#
# === Parameters
#
class ovirt_jenkins_slave::base {
  package {['tmpwatch', 'rpm', 'git']:
    ensure => latest,
  }

  # Provide additional entropy to the VMs (provided by EPEL for EL)
  package {'haveged':
  }
  service {'haveged' :
    ensure => running,
    enable => true,
  }
  Package['haveged'] -> Service['haveged']

  case "${::osfamily}-${::operatingsystem}" {
    RedHat-Fedora: {
      case $::operatingsystemrelease {
        21: {
          package {['java-1.8.0-openjdk-devel', 'java-1.8.0-openjdk',
                    'java-1.8.0-openjdk-headless']:
            ensure => latest;
          }
        }
        20: {
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk',
                    'java-1.7.0-openjdk-headless']:
            ensure => latest;
          }
        }
        19: {
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk']:
            ensure => latest;
          }
        }
        default: {
          fail("Unsupported ${::operatingsystem}-${::operatingsystemrelease}")
        }
      }

      # Common to all fedoras
      file {'/etc/yum.repos.d/gluster.repo':
        ensure => absent,
      }
      $enable_nested = true
    }
    ## CentOS machines
    /^RedHat.*/: {
      case $::operatingsystemmajrelease {
        7: {
          ## There's a bug on latest jdk that breaks the engine build
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk',
                    'java-1.7.0-openjdk-headless']:
            ensure => latest;
          }
          $enable_nested = true
        }
        default: {
          ## There's a bug on latest jdk that breaks the engine build
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk']:
            ensure => latest;
          }
          ## On centos we need an extra selinux policy to allow slave spawned
          ## processes (ex: engine-setup) to install rpms
          file {'/usr/share/selinux/targeted/jenkins_slave.pp':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
            source => 'puppet:///modules/ovirt_jenkins_slave/jenkins_slave.selinux.el6';
          }
          selmodule {'jenkins_slave':
            ensure      => present,
            syncversion => true,
          }
          $enable_nested = false
        }
      }

      # Common to all CentOS
      include epel

      Package {
        require => Class['epel'],
      }
    }
    # No Fedora nor CentOS
    default: {
      fail("Unsupported ${::osfamily}-${::operatingsystem}")
    }
  }

  user {'jenkins':
    ensure  => present,
  }
  file {'/home/jenkins':
    ensure => directory,
    mode   => '0700',
    owner  => 'jenkins',
    group  => 'jenkins';
  }
  file {'/home/jenkins/.ssh':
    ensure => directory,
    mode   => '0700',
    owner  => 'jenkins',
    group  => 'jenkins';
  }

  cron {
    'cleanup':
      command => 'tmpwatch -a 12 /tmp',
      user    => root,
      hour    => 0,
      minute  => 0,
  }

  ssh_authorized_key {
    'jenkins@ip-10-114-123-188':
      key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAykXy+X1qUI/TyblF5J35A1bexPeFWj7SmzzcClS3GzQ8jEaV7AaOzbvyl2dQ8P4nh8tr2nSeT7LAFYWhIGscy6V7p5vMRr3mUzRA/E/g3r9wdmdDcPLOqfpJWiLTDlA3XQyFhJnwQopGRBSf5yzFGWFezH+rjzlwBDDN2mQkI/WuSEBh+UT/9+E7JvQBVhg2hapXszfSrrtrVniw/1TvNJEvR+wdwxCUkJWP+LZOtdbGIYQZMkmw8yMNy/fkEfxR3CLge65rDCbxqlDkqFff0VWcwd3SBXdIo4T1401kIjcPiPR9npib7Ra88QiWXIazHW05ejp+m2W136zmYmfxFw==',
      type    => 'ssh-rsa',
      user    => 'jenkins';
  }

  class {'limits':
    config    => {
      '*' => {
        'nofile' => {
          'soft' => '64000',
          'hard' => '96000',
        },
      },
    },
    use_hiera => false,
  }
  sysctl { 'fs.file-max':
    value => '64000',
  }

  if $enable_nested {
    file { '/etc/modprobe.d/nested.conf':
      content => "options kvm-intel nested=y
",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
    }
  }
}
