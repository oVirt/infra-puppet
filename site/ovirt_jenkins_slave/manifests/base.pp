# == Class: ovirt_jenkins_slave::base
#
# This class makes sure the host has the basic stuff needed to be a
# jenkins slave
#
# === Parameters
#
class ovirt_jenkins_slave::base {
  package {['tmpwatch', 'rpm', 'git', 'libvirt']:
    ensure => latest,
  }

  class { 'ovirt_selinux':
    mode => 'permissive'
  }

  # Make sure libvirt is started
  service {'libvirtd' :
    ensure => running,
    enable => true,
  }
  Package['libvirt'] -> Service['libvirtd']
  # Provide additional entropy to the VMs (provided by EPEL for EL)
  package {'haveged':
  }
  service {'haveged' :
    ensure => running,
    enable => true,
  }
  Package['haveged'] -> Service['haveged']

  # we don't need lago installed, but we need somewhere to put the cached store
  # and repos
  file {'/var/lib/lago':
    ensure => directory,
    owner  => 'root',
    mode   => '0644',
  }
  # gluster is taken from SIG from 'centos-release-gluster'
  # repository and is needed on EL7> only.
  file {'/etc/yum.repos.d/gluster.repo':
    ensure => absent,
  }

  case "${::osfamily}-${::operatingsystem}" {
    RedHat-Fedora: {
      case $::operatingsystemrelease {
        /^(23|24|25)$/: {
          package {['java-1.8.0-openjdk-devel', 'java-1.8.0-openjdk',
                    'java-1.8.0-openjdk-headless']:
            ensure => installed;
          }

          firewalld_rich_rule { 'Accept http to lago internal repo from vms':
            ensure => present,
            zone   => 'public',
            source => '192.168.0.0/16',
            dest   => '192.168.0.0/16',
            port   => {
              'port'     => '8585',
              'protocol' => 'tcp',
            },
            action => 'accept',
          }
        }
        default: {
          fail("Unsupported ${::operatingsystem}-${::operatingsystemrelease}")
        }
      }

      # Common to all fedoras
      package {'qemu-kvm':
        ensure => latest,
      }
      if $::virtual != 'physical' {
        # Provide Guest Agent for oVirt
        package {'ovirt-guest-agent-common':
        }
        service {'ovirt-guest-agent' :
          ensure => running,
          enable => true,
        }
        Package['ovirt-guest-agent-common'] -> Service['ovirt-guest-agent']
      }

      $enable_nested = true
    }
    ## CentOS machines
    /^RedHat.*/: {
      case $::os_maj_version {
        7: {
          ## There's a bug on latest jdk that breaks the engine build
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk',
                    'java-1.7.0-openjdk-headless', 'java-1.8.0-openjdk-devel',
                    'java-1.8.0-openjdk', 'java-1.8.0-openjdk-headless']:
            ensure => installed;
          }
          ## workaround for OVIRT-616
          package {['hystrix-core', 'hystrix-metrics-event-stream']:
            ensure => latest;
          }
          package { 'centos-release-qemu-ev':
            ensure => latest,
          } ->
          package { 'qemu-kvm-ev':
            ensure => latest,
          }
          $enable_nested = true
          if $::virtual != 'physical' {
            # Provide Guest Agent for oVirt
            package {'ovirt-guest-agent-common':
            }
            service {'ovirt-guest-agent' :
              ensure => running,
              enable => true,
            }
            Package['ovirt-guest-agent-common'] -> Service['ovirt-guest-agent']
          }
        }
        6: {
          if $::virtual != 'physical' {
            # Provide Guest Agent for oVirt
            package {'ovirt-guest-agent':
            }
            service {'ovirt-guest-agent' :
              ensure => running,
              enable => true,
            }
            Package['ovirt-guest-agent'] -> Service['ovirt-guest-agent']
          }

          ## There's a bug on latest jdk that breaks the engine build
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk']:
            ensure => installed;
          }
          ## On centos we need an extra selinux policy to allow slave spawned
          ## processes (ex: engine-setup) to install rpms
          file {'/usr/share/selinux/targeted/slave.pp':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
            source => 'puppet:///modules/ovirt_jenkins_slave/jenkins_slave.selinux.el6';
          }
          selmodule {'slave':
            ensure      => present,
            syncversion => true,
          }
          $enable_nested = false
        }
        default: {
          fail("Unsupported ${::operatingsystem}-${::operatingsystemrelease}")
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
    mode   => '0750',
    owner  => 'jenkins',
    group  => 'jenkins';
  }
  file {'/home/jenkins/.ssh':
    ensure => directory,
    mode   => '0700',
    owner  => 'jenkins',
    group  => 'jenkins';
  }
  User['jenkins']->
  File['/home/jenkins']->
  File['/home/jenkins/.ssh']->
  Ssh_authorized_key <<| tag == 'jenkins_sshrsa' |>>
  {
    user    => 'jenkins',
    type    => 'ssh-rsa',
  }

  user {'qemu':
    ensure  => present,
    groups  => ['jenkins'],
    require => User['jenkins'],
  }

  cron {
    'cleanup':
      command => 'tmpwatch -a 12 /tmp',
      user    => root,
      hour    => 0,
      minute  => 0,
  }

  class {'limits':
  # TO-DO: this doesn't take any affect on the current connected
  # users(i.e. jenkins agent), so jenkins agent has to reconnet.
  # once we start using the swarm-plugin, we need to schedule here a refresh
  # of jenkins-slave service after applying the limit.
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

  if $enable_nested and $::architecture =~ /^(x86_64|amd64)$/ {
    kmod::option {'enable nested':
      module => 'kvm_intel',
      option => 'nested',
      value  => 'y',
      file   => '/etc/modprobe.d/nested.conf',
    }
    kmod::load { 'kvm_intel': }
    Kmod::Option['enable nested']~>
    Kmod::Load['kvm_intel']
  }
}
