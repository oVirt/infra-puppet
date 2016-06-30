# A class to provision an artifactory instance and configure apache on that
# server
#
# === Parameters
# [*auth_user*]
# The user to authenticate to an artifactoy server to copy configuration
# from
#
# [*auth_password*]
# auth_user's password
#
# [*copy_configuration_from*]
# An existing artifactory instance (fqdn) to grab the config from
#
# [*ssl_cert*]
# SSL certificate path for apache https
#
# [*ssl_key*]
# SSL key path for apache https
#
# [*ssl_chain*]
# SSL chain path for apache https
# if not all of the above 3 SSL parameters are provided, a new SSL
# certificate will be autogenerated.
#
# [*users*]
# users hash for creation upon installation, example:
# users = {
#            'user1' => { 'username': 'bobo',
#                         'password': 'pass',
#                         'salt': 'salt',
#                         'email': 'bobo@koko.com',
#                         'admin': 'false',
#         },}
# anonymous user with read access will be added on startup.
# this configuration will be applied only once, unless
# $security_import_puppet_lock file will be removed. each user addition
# will force a restart of artifactory.
#
# [*pv*]
# physical volume to add to LVM group
#
# [*vg*]
# volume group name for LVM
#
# [*lg*]
# logical volume name for LVM
#
# [*lv_size*]
# lv size to create

class ovirt_artifactory (
  $auth_user               = undef,
  $auth_password           = undef,
  $copy_configuration_from = undef,
  $ssl_cert                = undef,
  $ssl_key                 = undef,
  $ssl_chain               = undef,
  $users                   = undef,
  $pv      = '/dev/vdb',
  $vg      = 'jfrog_vg',
  $lv      = 'jfrog_lv',
  $lv_size = '30G',
  ) {

  unless "${::osfamily}-${::operatingsystem}-${::operatingsystemrelease}" =~ /^(RedHat-RedHat-7.*|RedHat-CentOS-7.*)$/ {
    fail("unsupported OS. ${module_name} was tested on CentOS 7.2 only,\
    if you wish to use it on a different platform, remove this line")
  }

  $security_import = '/etc/opt/jfrog/artifactory/security.import.xml'
  $config_import = '/etc/opt/jfrog/artifactory/artifactory.config.xml'
  $jfrog_dir = '/var/opt/jfrog'
  $jfrog_base = '/opt/jfrog'

  # packages
  $packages = ['epel-release', 'lvm2', 'java-1.8.0-openjdk',
      'ovirt-guest-agent-common']
  ensure_packages($packages, {'ensure' =>  'present'} )

  package { 'jfrog-artifactory-oss':
    ensure => 'present',
  }

  # LVM
  $jfrog_fs_dev = "/dev/${vg}/${lv}"

  file { $jfrog_dir:
    ensure => directory,
  }
  physical_volume { $pv:
    ensure => 'present',
  }
  volume_group { $vg:
    ensure           => 'present',
    physical_volumes => $pv,
  }

  logical_volume { $lv:
    ensure          => 'present',
    volume_group    => $vg,
    size            => $lv_size,
    size_is_minsize => true,
  }
  filesystem { $jfrog_fs_dev:
    ensure  => 'present',
    fs_type => 'xfs',
  }
  mount { $jfrog_dir:
    ensure  => 'mounted',
    atboot  => true,
    device  => $jfrog_fs_dev,
    fstype  => 'xfs',
    options => 'noatime',
  }


  # setup SSL certs for apache
  $ssl_dir = '/etc/ssl/autog/'
  file { $ssl_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if ($ssl_cert == undef) or ($ssl_key == undef) or ($ssl_chain == undef)
  {
    # see https://github.com/TwP/inifile/issues/35
    package { 'inifile':
      ensure   => '2.0.2',
      provider => gem,
    }->
    openssl::certificate::x509 { "${::fqdn}_x509_autog":
      ensure       => present,
      country      => 'US',
      organization => 'ovirt.org',
      commonname   => "${::fqdn}_autog",
      email        => 'infra@ovirt.org',
      days         => 1095,
      base_dir     => $ssl_dir,
      owner        => $::apache::params::user,
      group        => $::apache::params::group,
      force        => false,
    }
  }
  $real_ssl_cert = pick($ssl_cert, "${ssl_dir}/${::fqdn}_x509_autog.crt")
  $real_ssl_key = pick($ssl_key, "${ssl_dir}/${::fqdn}_x509_autog.key")
  $real_ssl_chain = pick($ssl_chain, $real_ssl_cert)

  # setup apache
  class { '::apache':
    default_vhost => false
  }
  apache::vhost { "${::fqdn}-nossl":
    servername          => $::fqdn,
    port                => 80,
    docroot             => '/var/www/html',
    rewrites            => [
      {
        rewrite_rule => ['^/$ /artifactory [R=302,L]']
      }
    ],
    proxy_preserve_host => true,
    proxy_pass          => [
      {
        'path' => '/artifactory',
        'url'  => "http://${::fqdn}:8081/artifactory"
      },
    ]
  }
  apache::vhost { "${::fqdn}-ssl":
    servername          => $::fqdn,
    port                => 443,
    docroot             => '/var/www/html',
    ssl                 => true,
    ssl_cipher          => 'ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW',
    ssl_cert            => $real_ssl_cert,
    ssl_key             => $real_ssl_key,
    ssl_chain           => $real_ssl_chain,
    rewrites            => [
      {
        rewrite_rule => ['^/$ /artifactory [R=302,L]']
      }
    ],
    proxy_preserve_host => true,
    proxy_pass          => [
      {
        'path' => '/artifactory',
        'url'  => "http://${::fqdn}:8081/artifactory"
      },
    ]
  }

  # selinux and firewall
  class { '::selinux':
    mode => 'enforcing',
  }
  firewalld_service { 'http':
    ensure  => 'present',
    service => 'http',
  }
  firewalld_service { 'https':
    ensure  => 'present',
    service => 'https',
  }
  selinux::boolean { 'httpd_can_network_relay': }
  selinux::boolean { 'httpd_can_network_connect': }

  # setup artifactory
  yumrepo { 'artifactory':
    baseurl  => 'https://jfrog.bintray.com/artifactory-rpms',
    descr    => 'artifactory',
    enabled  => 1,
    gpgcheck => 0
  }


  if $artifactory::params::copy_configuration_from {
    exec { 'retrieve configuration':
      command => "/usr/bin/curl --u ${artifactory::params::auth_user}:\
${artifactory::params::auth_password} \
${artifactory::params::copy_configuration_from}\
/api/system/configuration -o /tmp/artifactory.config.current.xml",
      creates => '/tmp/artifactory.config.current.xml',
      notify  => File['/etc/opt/jfrog/artifactory/artifactory.config.xml']
    }
    $afconf = 'file:///tmp/artifactory.config.current.xml'

  }
  else
  {
    $afconf = "puppet:///modules/${module_name}/artifactory.config.xml"
  }

  service { 'artifactory':
    ensure   => running,
    provider => 'systemd',
    enable   => true,
  }

  service { 'ovirt-guest-agent':
    ensure   => running,
    provider => 'systemd',
    enable   => true,
  }

  if $users {
    validate_hash($users)
    create_resources('ovirt_artifactory::user', $users)
  }

  file { "${security_import}_template":
    ensure  => present,
    replace => false,
    owner   => 'artifactory',
    group   => 'artifactory',
    source  => 'puppet:///modules/ovirt_artifactory/security.import.xml',
  }
  exec { 'lock_security':
    command => "cp -p ${security_import}_template ${security_import} && touch ${security_import}_puppet_lock",
    creates => "${security_import}_puppet_lock",
  }
  file { $config_import:
    ensure => file,
    owner  => 'artifactory',
    group  => 'artifactory',
    mode   => '0644',
    source => $afconf,
  }


  file { '/usr/lib/systemd/system/artifactory.service':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => "puppet:///modules/${module_name}/artifactory.service",
  }

  file { '/etc/sysconfig/artifactory':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/artifactory.erb"),
  }

  file { "${jfrog_dir}/artifactory":
    ensure       => directory,
    owner        => 'artifactory',
    group        => 'artifactory',
    replace      => false,
    recurse      => true,
    recurselimit => 1,
  }
  file { "${jfrog_base}/artifactory":
    ensure       => directory,
    owner        => 'artifactory',
    group        => 'artifactory',
    replace      => false,
    recurse      => true,
    recurselimit => 1,
  }

  exec {'systemd-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  # ordering

  Yumrepo['artifactory']->
  Package['epel-release']->
  Package['lvm2'] ->
  Package['ovirt-guest-agent-common']->
  Service['ovirt-guest-agent']->
  File[$jfrog_dir] ->
  Physical_volume[$pv] ->
  Volume_group[$vg] ->
  Logical_volume[$lv] ->
  Filesystem[$jfrog_fs_dev] ->
  Mount[$jfrog_dir]->
  Package['java-1.8.0-openjdk']->
  Package['jfrog-artifactory-oss'] ->
  File["${jfrog_dir}/artifactory"] ->
  File["${jfrog_base}/artifactory"] ->
  File[$config_import] ->
  File["${security_import}_template"] ->
  Ovirt_artifactory::User <| |> ->
  Exec['lock_security'] ->
  File['/usr/lib/systemd/system/artifactory.service'] ->
  File['/etc/sysconfig/artifactory'] ->
  Exec['systemd-reload']->
  Service['artifactory']
  if defined(Openssl::Certificate::X509["${::fqdn}_x509_autog"]) {
    File[$ssl_dir]->
    Openssl::Certificate::X509["${::fqdn}_x509_autog"]->
    Class['::apache']
  }

  # if ${security_import}_puppet_lock is removed it will re-deploy
  # the security file
  Exec['lock_security'] ~>
  Service['artifactory']
}