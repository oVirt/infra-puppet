class ovirt_infra::jenkins_slave {
  $packages = ['autoconf', 'automake', 'make', 'puppet',
    'gettext-devel', 'python-devel', 'java-1.7.0-openjdk-devel',
    'python-pep8', 'python-pip', 'wget', 'python-nose',
    'ethtool', 'pyflakes', 'python-ethtool', 'libvirt',
    'libvirt-python', 'python-pthreading', 'm2crypto', 'psmisc',
    'python-netaddr', 'genisoimage', 'python-dmidecode',
    'gcc', 'rpm-build', 'git', 'python-ordereddict', 'libtool',
    'python-kitchen', 'python-cpopen', 'postgresql-jdbc',
    'python-lxml', 'python-inotify', 'python-ply']


  package {$packages:
    ensure => latest,
  }

  case $::osfamily {
    RedHat: {
      case $::operatingsystem {
        Fedora: {
          package{['maven', 'maven-compiler-plugin', 'maven-enforcer-plugin',
            'maven-install-plugin', 'maven-jar-plugin', 'maven-javadoc-plugin',
            'maven-source-plugin', 'maven-surefire-provider-junit', 'maven-local',
            'maven-dependency-plugin', 'maven-antrun-plugin',
            'apache-commons-collections']:
            ensure => latest,
          }
        }
        default: {
          include epel

          Package {
            require => Class['epel'],
          }

          package {['jakarta-commons-logging', 'junit4']:
            ensure => latest,
          }
        }
      }
    }
    default: {
      fail("Unsupport osfamily ${::osfamily}")
    }
  }

  user {'jenkins':
    ensure => present,
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
  }

  ssh_authorized_key {
    'jenkins@ip-10-114-123-188':
      key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAykXy+X1qUI/TyblF5J35A1bexPeFWj7SmzzcClS3GzQ8jEaV7AaOzbvyl2dQ8P4nh8tr2nSeT7LAFYWhIGscy6V7p5vMRr3mUzRA/E/g3r9wdmdDcPLOqfpJWiLTDlA3XQyFhJnwQopGRBSf5yzFGWFezH+rjzlwBDDN2mQkI/WuSEBh+UT/9+E7JvQBVhg2hapXszfSrrtrVniw/1TvNJEvR+wdwxCUkJWP+LZOtdbGIYQZMkmw8yMNy/fkEfxR3CLge65rDCbxqlDkqFff0VWcwd3SBXdIo4T1401kIjcPiPR9npib7Ra88QiWXIazHW05ejp+m2W136zmYmfxFw==',
      type    => 'ssh-rsa',
      user    => 'jenkins';
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

  augeas { 'root !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      'set Defaults[type=":root"]/type :root',
      'clear Defaults[type=":root"]/requiretty/negate',
    ],
  }
}
