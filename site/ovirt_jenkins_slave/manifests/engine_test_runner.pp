# == Class: ovirt_jenkins_slave::engine_test_runner
#
# This class makes sure the jenkins slave has all that's needed to run
# engine tests
#
# === Parameters
#
class ovirt_jenkins_slave::engine_test_runner {
  $packages = [
    'postgresql-jdbc', 'log4j','jasperreports-server','chrpath',
    'sos', 'mailcap',
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

    }
    ## CentOS machines
    /^RedHat.*/: {
      case $::operatingsystemmajrelease {
        7: {
          package {['maven', 'junit', 'assertj-core']:
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
        }
      }

      package {['apache-commons-logging', 'dom4j', 'ant',
                'apache-commons-collections']:
                  ensure => latest,
      }

      ## Use a file resource instead of yumrepo because skip_if_unavailable is
      ## not supported yet
      unless 'ppc' in $::architecture {
        package {['centos-release-gluster37']:
                    ensure => latest,
        }
      }
    }
    default: {
      fail("Unsupported ${::osfamily}-${::operatingsystem}")
    }
  }

}
