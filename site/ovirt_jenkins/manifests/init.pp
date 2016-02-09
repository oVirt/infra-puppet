# this manifest is in charge of installing Jenkins
# and its plugins.
# plugin list is taken from hiera.
class ovirt_jenkins(
  $data_dir = '/var/lib/data',
  $block_device = '/dev/mapper/jenkins_lvm-data',
  $jenkins_ver = 'latest',
  $manage_java = true,
  $plugins = {},
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
    'JENKINS_HOME' => {
      'value' => "${data_dir}/jenkins"
    }
    },
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
  class { '::selinux':
    mode => 'enforcing',
  }
  selinux::boolean { 'httpd_can_network_relay': }

}
