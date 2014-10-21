# == Class: ovirt_infra::jenkins_slave
#
# This class makes sure the host has all that's needed to be a jenkins slave
#
# === Parameters
#
# [*packages*]
#
# List of packages to be installed
#
class ovirt_infra::jenkins_slave {
  $packages = ['autoconf', 'automake', 'make',
    'gettext-devel', 'python-devel', 'python-pip', 'wget', 'python-nose',
    'ethtool', 'pyflakes', 'python-ethtool', 'libvirt',
    'libvirt-python', 'python-pthreading', 'm2crypto', 'psmisc',
    'python-netaddr', 'genisoimage', 'python-dmidecode',
    'gcc', 'rpm-build', 'git', 'libtool', 'libselinux-python',
    'python-kitchen', 'python-cpopen', 'postgresql-jdbc',
    'python-lxml', 'python-inotify', 'python-ply', 'tmpwatch',
    'dosfstools', 'rpmdevtools', 'libnl', 'log4j', 'yum-utils', 'mock',
    'python-mock', 'jasperreports-server', 'pylint', 'yum', 'python-six',
    'chrpath', 'sos', 'python-tox', 'mailcap',
  ]

  include ovirt_infra::ci_tools_repo

  package {$packages:
    ensure => latest,
  }

  if "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" != 'RedHat-Fedora-21' {
    package{'python-ordereddict':
      ensure => latest,
    }
  }

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
            ensure => '1.7.0.60-2.4.3.0.fc20';
          }
        }
        19: {
          package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk']:
            ensure => '1.7.0.25-2.3.10.3.fc19';
          }
        }
        default: {
          fail("Unsupported ${::operatingsystem}-${::operatingsystemrelease}")
        }
      }
      package {['maven', 'maven-compiler-plugin', 'maven-enforcer-plugin',
                'maven-install-plugin', 'maven-jar-plugin',
                'maven-javadoc-plugin', 'maven-source-plugin',
                'maven-surefire-provider-junit', 'maven-local',
                'maven-dependency-plugin', 'maven-antrun-plugin',
                'apache-commons-collections', 'apr-util', 'lorax',
                'pykickstart', 'virt-install', 'libguestfs-tools']:
                  ensure => latest,
      }
      package {'python-pep8':
        ensure => installed,
      }

      file {'/etc/yum.repos.d/gluster.repo':
        ensure => absent,
      }

      yumrepo{'patternfly':
        descr      => 'Copr repo for patternfly1 owned by patternfly',
        baseurl    => 'http://copr-be.cloud.fedoraproject.org/results/patternfly/patternfly1/fedora-$releasever-$basearch/',
        gpgcheck   => 0,
        enabled    => 1,
      }

    }
    ## CentOS machines
    /^RedHat.*/: {
      include epel

      Package {
        require => Class['epel'],
      }

      package {['apache-commons-logging', 'junit4', 'dom4j', 'ant',
                'apache-commons-collections', 'python-argparse', 'python-pep8']:
                  ensure => latest,
      }
      ## Special maven3 specifying version as jpackage repos introduce a
      ## new one that we don't want yet (and requires enabling devel
      ## jpackage repos right now for deps
      package {'maven3':
        ensure => '3.0.3-4.jdk7'
      }
      ## There's a bug on latest jdk that breaks the engine build
      package {['java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk']:
        ensure => '1.7.0.55-2.4.7.1.el6_5';
      }

      file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage':
        owner  => root,
        group  => root,
        mode   => '0444',
        source => 'puppet:///modules/ovirt_infra/jpackage.repo.gpg.key';
      }
      ## Use a file resource instead of yumrepo because skip_if_unavailable is not supported yet
      file {'/etc/yum.repos.d/gluster.repo':
        ensure => present,
        mode   => '0664',
        owner  => 'root',
        group  => 'root',
        source => 'puppet:///modules/ovirt_infra/gluster.epel.repo';
      }

      yumrepo{'jpackage':
        descr      => 'JPackage 6.0, for Red Hat Enterprise Linux 5',
        mirrorlist => 'http://resources.ovirt.org/repos/jpackage/generate_mirrors.cgi?dist=redhat-el-5.0&type=free&release=6.0',
        gpgcheck   => 1,
        enabled    => 1,
        gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage',
        require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage'],
      }
      yumrepo{'jpackage-generic':
        descr      => 'JPackage 6.0, for Red Hat Enterprise Linux 5',
        mirrorlist => 'http://resources.ovirt.org/repos/jpackage/generate_mirrors.cgi?dist=generic&type=free&release=6.0',
        gpgcheck   => 0,
        enabled    => 1,
        gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage',
        require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage'],
      }
      yumrepo{'patternfly':
        descr      => 'Copr repo for patternfly1 owned by patternfly',
        baseurl    => 'http://copr-be.cloud.fedoraproject.org/results/patternfly/patternfly1/epel-$releasever-$basearch/',
        gpgcheck   => 0,
        enabled    => 1,
      }

      ## On centos we need an extra selinux policy to allow slave spawned
      ## processes (ex: engine-setup) to install rpms
      file {'/usr/share/selinux/targeted/jenkins_slave.pp':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/ovirt_infra/jenkins_slave.selinux.el6';
      }
      selmodule {'jenkins_slave':
        ensure      => present,
        syncversion => true,
      }
    }
    default: {
      fail("Unsupported ${::osfamily}-${::operatingsystem}")
    }
  }

  user {'jenkins':
    ensure  => present,
    groups  => ['mock'],
    require => Package['mock'],
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

  augeas { 'jenkins full sudo':
    context => '/files/etc/sudoers',
    changes => [
      # cleanup before creating the entry
      'rm spec[user = "jenkins"]',
      'set spec[user = "jenkins"]/user jenkins',
      'set spec[user = "jenkins"]/host_group/host ALL',
      'set spec[user = "jenkins"]/host_group/command ALL',
      'set spec[user = "jenkins"]/host_group/command/runas_user ALL',
      'set spec[user = "jenkins"]/host_group/command/tag NOPASSWD',
    ],
  }

  augeas { 'remove vdsm unit test leftovers':
    context => '/files/etc/sudoers',
    changes => [
      'rm Cmnd_Alias[alias/name = "VDSMUT"]',
    ],
  }

  augeas { 'jenkins !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      'set Defaults[type=":jenkins"]/type :jenkins',
      'clear Defaults[type=":jenkins"]/requiretty/negate',
    ],
  }

  augeas { 'allow passing HOME through':
    context => '/files/etc/sudoers',
    changes => [
      'rm Defaults[always_set_home]',
    ],
  }

  augeas { 'root !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      'set Defaults[type=":root"]/type :root',
      'clear Defaults[type=":root"]/requiretty/negate',
    ],
  }
}
