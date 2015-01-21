# == Class: ovirt_proxy
#
# Configures a local network proxy with yum repo proxying
#
# === Parameters
# allow
#   Allow entry to handle which networks have permission to use the proxy
#
# cache_mem
#   Size of the RAM cache to use, if set to detect, it will autodetect it
#
class ovirt_proxy(
  $allow='66.187.230.0/26',
  $cache_mem='detect',
) {

  if($cache_mem == 'detect') {
    $guessed_mem = $::memorysize_mb * 3 / 4
    # cast to string is required for the split function
    # lint:ignore:only_variable_string
    $int_guessed_mem = split("${guessed_mem}", '\.')
    # lint:endignore
    $real_cache_mem = "${int_guessed_mem[0]} MB"
  } else {
    $real_cache_mem = "${cache_mem} MB"
  }

  class {'::squid3':
    acl                 => [
      "allowed src ${allow}",
      'PURGE method PURGE',
      'REPOS url_regex repomd.xml$',
    ],
    http_access         => [
      'allow allowed',
      'allow PURGE localhost',
      'deny PURGE',
    ],
    cache_mem           => $real_cache_mem,
    cache_dir           => [
      'ufs /var/spool/squid 180000 16 256',
    ],
    maximum_object_size => '1024 MB',
    config_hash         => {
      'cache_replacement_policy' => 'heap LFUDA',
      'no_cache'                 => 'deny REPOS',
    },
    template            => 'short',
  }

  class {'ovirt_proxy::repoproxy':
    basedir => '/opt/repoproxy',
    user    => 'squid',
    group   => 'squid',
    ip      => '127.0.0.1',
    port    => '5000',
  }

  host { $::fqdn:
      ip => '127.0.0.1',
  }

  exec {'add_firewalld_squid_now':
    command => 'firewall-cmd --add-port 3128/tcp',
    unless  => 'firewall-cmd --query-port 3128/tcp',
    path    => '/bin',
  }

  exec {'add_firewalld_squid_persist':
    command     => 'firewall-cmd --persist --add-port 3128/tcp',
    refreshonly => true,
    path        => '/bin',
  }

  Host[$::fqdn]
  -> Class['::squid3']

  Exec['add_firewalld_squid_now']
  ~> Exec['add_firewalld_squid_persist']
}
