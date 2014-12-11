# == Class: ovirt_jenkins_slave::engine_test_runner
#
# This class makes sure the jenkins slave has all that's needed to run
# engine tests
#
# === Parameters
#
class ovirt_jenkins_slave::engine_test_runner {
  $packages = [
    'postgresql-jdbc', 'libnl', 'log4j', 'jasperreports-server',
    'chrpath', 'sos', 'mailcap',
  ]

  include ovirt_package::createrepo

  package {$packages:
    ensure => latest,
  }

  case "${::osfamily}-${::operatingsystem}" {
    RedHat-Fedora: {

      # Common to all fedoras
      package {[
        'maven', 'maven-compiler-plugin', 'maven-enforcer-plugin',
        'maven-install-plugin', 'maven-jar-plugin',
        'maven-javadoc-plugin', 'maven-source-plugin',
        'maven-surefire-provider-junit', 'maven-local',
        'maven-dependency-plugin', 'maven-antrun-plugin',
        'apache-commons-collections', 'apr-util', 'lorax',
        ]:
          ensure => latest,
      }

      yumrepo{'patternfly':
        descr    => 'Copr repo for patternfly1 owned by patternfly',
        baseurl  => 'http://copr-be.cloud.fedoraproject.org/results/patternfly/patternfly1/fedora-$releasever-$basearch/',
        gpgcheck => 0,
        enabled  => 1,
      }

    }
    ## CentOS machines
    /^RedHat.*/: {
      case $::operatingsystemmajrelease {
        7: {
          package {['maven', 'junit']:
            ensure => latest,
          }
        }
        default: {
          ## Special maven3 specifying version as jpackage repos introduce a
          ## new one that we don't want yet (and requires enabling devel
          ## jpackage repos right now for deps
          package {'maven3':
            ensure => '3.0.3-4.jdk7'
          }
          package {'junit4':
            ensure => latest,
          }
          file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage':
            owner  => root,
            group  => root,
            mode   => '0444',
            source => 'puppet:///modules/ovirt_jenkins_slave/jpackage.repo.gpg.key';
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
        }
      }

      # Common to all CentOS
      include epel

      Package {
        require => Class['epel'],
      }

      package {['apache-commons-logging', 'dom4j', 'ant',
                'apache-commons-collections']:
                  ensure => latest,
      }

      ## Use a file resource instead of yumrepo because skip_if_unavailable is not supported yet
      file {'/etc/yum.repos.d/gluster.repo':
        ensure => present,
        mode   => '0664',
        owner  => 'root',
        group  => 'root',
        source => 'puppet:///modules/ovirt_jenkins_slave/gluster.epel.repo';
      }

      yumrepo{'patternfly':
        descr    => 'Copr repo for patternfly1 owned by patternfly',
        baseurl  => 'http://copr-be.cloud.fedoraproject.org/results/patternfly/patternfly1/epel-$releasever-$basearch/',
        gpgcheck => 0,
        enabled  => 1,
      }
    }
    default: {
      fail("Unsupported ${::osfamily}-${::operatingsystem}")
    }
  }

}
