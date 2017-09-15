# this manifest is in charge of installing Jenkins
# and its plugins.
# plugin list is taken from hiera.
class ovirt_jenkins(
  $data_dir = '/var/lib/data',
  $block_device = '/dev/mapper/jenkins_lvm-data',
  $jenkins_ver = 'installed',
  $manage_java = false,
  $plugins = {},
  $jnlp_port = '56293',
  $icinga_ip = '',
  $graphite_host = 'localhost',
  $graphite_port = '2003',
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
    lts           => true,
    localstatedir => "${data_dir}/jenkins",
    install_java  => $manage_java,
    cli           => true,
    config_hash   => {
      'JENKINS_HOME'         => {
        'value' => "${data_dir}/jenkins"
      },
      'JENKINS_JAVA_OPTIONS' => {
        'value' => '-Djava.awt.headless=true -Xmx12G -Xms4G -XX:MaxPermSize=3G'
      },
      'JENKINS_ARGS'         => {
        'value' =>  ' --sessionTimeout=400 --httpKeepAliveTimeout=60000 ',
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

  file { 'includes':
    ensure => directory,
    path   => "${data_dir}/jenkins/includes",
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file { 'Monitor.groovy':
    ensure  => file,
    path    => "${data_dir}/jenkins/includes/Monitor.groovy",
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('ovirt_jenkins/Monitor.groovy.erb'),
  }
  file {'groovy-events':
    ensure  => file,
    path    => "${data_dir}/jenkins/includes/events.groovy.template",
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('ovirt_jenkins/groovy-events.groovy.erb'),
  }


  create_resources('jenkins::plugin', $plugins)

  File[$data_dir]
  ->Mount[$data_dir]
  ->Class['::jenkins']
  ->File['includes']
  ->File['Monitor.groovy']
  ->File['groovy-events']

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
      'params'   => {
        'connectiontimeout' => '2400',
        'timeout'           => '2400',
      },
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
  package { ['python2-pip', 'git']:
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
  class { '::ovirt_backup::jenkins::client': }

  Class['epel']
  ->Package['python2-pip']
  ->Package['ordereddict']
  ->Class['::ovirt_backup::jenkins::client']

  package {['java-1.8.0-openjdk-devel','java-1.8.0-openjdk',
            'java-1.8.0-openjdk-headless']:
    ensure => latest
  }

  file { "${data_dir}/jenkins/.jenkinsjobsrc-defaults":
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => template('ovirt_jenkins/jenkinsjobsrc.erb'),
  }

  if  $::jenkins_sshrsa {
    @@ssh_authorized_key { "jenkins@${::fqdn}":
      user => 'jenkins',
      type => 'ssh-rsa',
      key  => $::jenkins_sshrsa,
      tag  => 'jenkins_sshrsa',
    }
  }
  # monitoring
  class { '::nrpe':
    allowed_hosts => [$icinga_ip, ],
    purge         => true,
    recurse       => true,
  }

  @@nagios_hostgroup { "${::fqdn}_hostgroup":
    hostgroup_name => "${::fqdn}_hostgroup",
    alias          => "${::fqdn}_hostgroup",
    tag            => 'monitoring',
    target         => "/etc/icinga/conf.d/hostgroups/${::fqdn}_hostgroup.cfg",
  }

  @@nagios_host { $::fqdn:
    ensure     => present,
    alias      => $::hostname,
    address    => $::ipaddress,
    use        => 'linux-server',
    hostgroups => "${::fqdn}_hostgroup",
    target     => "/etc/icinga/conf.d/hosts/${::fqdn}.cfg",
    tag        => 'monitoring',
  }

  nrpe::command {
    'check_data_disk':
      ensure  => present,
      command => "check_disk -w 15% -c 10% ${data_dir}",
    ;
    'check_root_disk':
      ensure  => present,
      command => 'check_disk -w 20% -c 10% /',
    ;
    'check_jenkins_war':
      ensure  => present,
      command => "check_procs -a '/usr/lib/jenkins/jenkins.war' -u jenkins -c 1:"
    ;
    'check_httpd':
      ensure  => present,
      command => "check_procs -a '/usr/sbin/httpd' -u apache -c 1:",
    ;
  }

  $service_defaults = {
    use                 => 'local-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    target              => "/etc/icinga/conf.d/services/${::fqdn}_services.cfg",
    hostgroup_name      => "${::fqdn}_hostgroup",
    tag                 => 'monitoring'
  }
  $service_checks = {
    "check_data_disk_${::fqdn}" => {
      check_command             =>  'check_nrpe!check_data_disk',
      service_description => "${::fqdn} ${data_dir} disk",
    },
    "check_root_disk_${::fqdn}" => {
      check_command             => 'check_nrpe!check_root_disk',
      service_description       => "${::fqdn} root disk",
    },
    "check_jenkins_war_${::fqdn}" => {
      check_command       => 'check_nrpe!check_jenkins_war',
      service_description => "${::fqdn} jenkins.war",
    },
    "check_httpd_${::fqdn}" => {
      check_command       => 'check_nrpe!check_httpd',
      service_description => "${::fqdn} httpd",
    },
    "check_ping_${::fqdn}" => {
      check_command       => 'check_ping!200.0,20%!500.0,60%',
      service_description => "${::fqdn} ping",
    }
  }
  create_resources('@@nagios_service', $service_checks, $service_defaults)

  firewalld_rich_rule { 'NRPE port':
    ensure => present,
    zone   => 'public',
    source => "${icinga_ip}/32",
    action => 'accept',
    port   => {
      'port'     => $::nrpe::server_port,
      'protocol' => 'tcp',
    }
  }

}
