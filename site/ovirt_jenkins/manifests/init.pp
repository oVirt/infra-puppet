# this manifest is in charge of installing Jenkins
# and its plugins.
# plugin list is taken from hiera.
class ovirt_jenkins(
  $data_dir = '/var/lib/data',
  $block_device = '/dev/mapper/jenkins_lvm-data',
  $jenkins_ver = 'latest',
  $manage_java = true,
  $plugins = {},
  $jnlp_port = '56293',
  )
{
  file { $data_dir:
    ensure => directory,
  }
  mount { $data_dir:
    ensure  => mounted,
    atboot  => true,
    device  => $block_device,
    fstype  => 'xfs',
    options => 'defaults,noatime',
  }
  class { '::jenkins':
    version       => $jenkins_ver,
    localstatedir => "${data_dir}/jenkins",
    install_java  => $manage_java,
    cli           => true,
    config_hash   => {
      'JENKINS_HOME'         => {
        'value' => "${data_dir}/jenkins"
      },
      'JENKINS_JAVA_OPTIONS' => {
        'value' => '-Djava.awt.headless=true -Xmx8G -XX:MaxPermSize=3G'
      },
    },
  }

  file { 'userContent':
    path         => "${data_dir}/jenkins/userContent",
    source       => 'puppet:///modules/ovirt_jenkins/userContent',
    recurse      => true,
    recurselimit => 1,
    owner        => 'jenkins',
    group        => 'jenkins',
  }


  class {'jenkins::cli_helper':
      ssh_keyfile => "${data_dir}/jenkins/.ssh/id_rsa",
  }

  create_resources('jenkins::plugin', $plugins)

  File[$data_dir]
  ->Mount[$data_dir]
  ->Class['::jenkins']

  class { '::apache':
    require       => Class['jenkins'],
    default_vhost => false,
  }

  apache::vhost { $::fqdn:
    port                  => '80',
    manage_docroot        => false,
    docroot               => false,
    proxy_pass            => [ {
      'path'     => '/',
      'url'      => 'http://localhost:8080/',
      'keywords' => ['nocanon'],
    }, ],
    allow_encoded_slashes => 'on',

  }
  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http',
  }

  firewalld_port { 'jnlp port for jenkins slave':
    ensure   => 'present',
    zone     => 'public',
    port     => '56293',
    protocol => 'tcp',
  }

  class { '::selinux':
    mode => 'enforcing',
  }
  selinux::boolean { 'httpd_can_network_relay': }

  class {'::epel': }
  package { ['python-pip', 'git']:
    ensure => latest,
  }
  package {'ordereddict':
    ensure   => present,
    provider => 'pip',
  }
  package { ['puppet-lint', 'rspec' ]:
      ensure   => present,
      provider => 'gem',
  }
  Class['epel']
  ->Package['python-pip']
  ->Package['ordereddict']

  file { "${data_dir}/jenkins/.jenkinsjobsrc-defaults":
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => template('ovirt_jenkins/jenkinsjobsrc.erb'),
  }
}
