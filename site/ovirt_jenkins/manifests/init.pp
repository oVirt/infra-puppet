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
  $ssl_certnames = [$::fqdn],
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
        'value' => '-server -Djava.awt.headless=true -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+ExplicitGCInvokesConcurrent -XX:+ParallelRefProcEnabled -XX:+UseStringDeduplication -XX:+UnlockDiagnosticVMOptions -Xmx16G -Xms8G -Dhudson.model.Run.ArtifactList.listCutoff=1 -Dhudson.model.Run.ArtifactList.treeCutoff=9999 -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts; default-src \'self\' https://cdnjs.cloudflare.com; img-src \'self\'; style-src \'self\' https://cdnjs.cloudflare.com;\"  -Djenkins.eventbus.web.asyncSupported=true -DsessionTimeout=72000 -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=100 -Dhudson.slaves.NodeProvisioner.MARGIN0=1.0'
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

  Apache::Vhost<|ssl == false|> ~> Exec['Restart Apache'] -> Letsencrypt::Certonly<||> -> Apache::Vhost<|ssl == true|>
  class { '::letsencrypt':
    configure_epel      => false,
    unsafe_registration => true,
  }
  package { ['python2-certbot-apache']:
    ensure => installed,
  }
  $ssl_cert_primary_domain = $ssl_certnames[0]
  letsencrypt::certonly { $ssl_cert_primary_domain:
    domains              => $ssl_certnames,
    plugin               => 'apache',
    manage_cron          => true,
    cron_success_command => '/bin/systemctl reload httpd.service',
  }
  apache::vhost { "${::fqdn}-ssl":
    port                  => '443',
    manage_docroot        => false,
    docroot               => false,
    ssl                   => true,
    ssl_cert              => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/cert.pem",
    ssl_key               => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/privkey.pem",
    ssl_chain             => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/chain.pem",
    ssl_cipher            => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    request_headers       => ['set X-Forwarded-Proto https', 'set X-Forwarded-Port 443'],
    proxy_preserve_host   => true,
    proxy_pass            => [ {
      'path'     => '/',
      'url'      => 'http://localhost:8080/',
      'keywords' => ['nocanon'],
      'params'   => {
        'connectiontimeout' => '2400',
        'timeout'           => '2400',
      },
    }, ],
    allow_encoded_slashes => 'nodecode',

  }
  exec {'Restart Apache':
    command     => '/bin/systemctl restart httpd.service',
    refreshonly => true,
  }
  firewalld_service { 'Allow HTTPS':
    ensure  => 'present',
    service => 'https',
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
    ensure => installed
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
