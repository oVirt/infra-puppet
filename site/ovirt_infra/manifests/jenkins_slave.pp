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
  $packages = ['autoconf', 'automake', 'make', 'puppet',
    'gettext-devel', 'python-devel', 'java-1.7.0-openjdk-devel',
    'python-pep8', 'python-pip', 'wget', 'python-nose',
    'ethtool', 'pyflakes', 'python-ethtool', 'libvirt',
    'libvirt-python', 'python-pthreading', 'm2crypto', 'psmisc',
    'python-netaddr', 'genisoimage', 'python-dmidecode',
    'gcc', 'rpm-build', 'git', 'python-ordereddict', 'libtool',
    'python-kitchen', 'python-cpopen', 'postgresql-jdbc',
    'python-lxml', 'python-inotify', 'python-ply', 'tmpwatch',
    'dosfstools', 'rpmdevtools', 'libnl', 'log4j', 'yum-utils', 'mock',
    'python-mock', 'jasperreports-server', 'pylint', 'yum',
  ]

  include ovirt_infra::ci_tools_repo

  package {$packages:
    ensure => latest,
  }

  case $::osfamily {
    RedHat: {
      case $::operatingsystem {
        Fedora: {
          package{['maven', 'maven-compiler-plugin', 'maven-enforcer-plugin',
            'maven-install-plugin', 'maven-jar-plugin', 'maven-javadoc-plugin',
            'maven-source-plugin', 'maven-surefire-provider-junit',
            'maven-local', 'maven-dependency-plugin', 'maven-antrun-plugin',
            'apache-commons-collections', 'apr-util']:
            ensure => latest,
          }
        }
        ## CentOS machines
        default: {
          include epel

          Package {
            require => Class['epel'],
          }

          package {['apache-commons-logging', 'junit4', 'dom4j', 'ant',
            'apache-commons-collections', 'maven3']:
            ensure => latest,
          }

          file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage':
            owner  => root,
            group  => root,
            mode   => '0444',
            source => 'puppet:///modules/ovirt_infra/jpackage.repo.gpg.key',
          }
          yumrepo{'jpackage':
            descr      => 'JPackage 6.0, for Red Hat Enterprise Linux 5',
            mirrorlist => 'http://www.jpackage.org/mirrorlist.php?dist=redhat-el-5.0&type=free&release=6.0',
            gpgcheck   => 1,
            enabled    => 1,
            gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage',
            require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage'],
          }
          yumrepo{'jpackage-generic':
            descr      => 'JPackage 6.0, for Red Hat Enterprise Linux 5',
            mirrorlist => 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=6.0',
            gpgcheck   => 1,
            enabled    => 1,
            gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage',
            require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage'],
          }
        }
      }
    }
    default: {
      fail("Unsupport osfamily ${::osfamily}")
    }
  }

  user {'jenkins':
    ensure  => present,
    groups  => ['mock'],
    require => Package['mock'],
  }

  file {
    '/home/jenkins':
      ensure => directory,
      mode   => '0700',
      owner  => 'jenkins',
      group  => 'jenkins';
    '/home/jenkins/.ssh':
      ensure => directory,
      mode   => '0700',
      owner  => 'jenkins',
      group  => 'jenkins';
    ## as a file so we can use skip_if_unavailable options
    '/etc/yum.repos.d/gluster.repo':
      ensure => present,
      mode   => '0664',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/ovirt_infra/gluster.repo';
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
