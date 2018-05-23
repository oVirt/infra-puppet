# Handles the apache configuration for a machine that has the
# repositories in it, that is, a resources machine
class ovirt_resources::apache(
  $resources_dir ='/data/repos',
  $server_alias  ='resources.ovirt.org',
  $ssl_certnames = [$::fqdn],
  )
{
  class{'::apache':
    # We are not serving anything from /var/www/html
    default_vhost => false,
  }
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl

  $common_aliases = [
    { scriptaliasmatch => '^/repos/jpackage/generate_mirrors.cgi',
      path             => "${resources_dir}/repos/jpackage/generate_mirrors.cgi",
    },
  ]

  $common_rewrites = [
    { rewrite_rule => '^/pub/yum-repo/(mirrorlist-ovirt-.*)$  /pub/yum-repo/mirrors.cgi?$1' },
  ]

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

  apache::vhost {$::fqdn:
    vhost_name     => '*',
    port           => 80,
    serveraliases  => [$server_alias],
    docroot        => $resources_dir,
    manage_docroot => false,
    directories    => [
      { path           => $resources_dir,
        options        => ['+Indexes', '+FollowSymLinks', '+MultiViews'],
        directoryindex => 'index.html index.html.var /_h5ai/server/php/index.php',
      },
      { path        => "${resources_dir}/pub/yum-repo",
        options     => ['+ExecCGI'],
        addhandlers => [{ handler    => 'cgi-script',
                          extensions => ['.cgi']}],
      },
    ],
    aliases        => $common_aliases,
    rewrites       => $common_rewrites,
    require        => Mount[$resources_dir],
    default_vhost  => true,
  }

  apache::vhost {"${::fqdn}-ssl":
    vhost_name     => '*',
    port           => 443,
    ssl            => true,
    ssl_cert       => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/cert.pem",
    ssl_key        => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/privkey.pem",
    ssl_chain      => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/chain.pem",
    ssl_cipher     => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    serveraliases  => [$server_alias],
    docroot        => $resources_dir,
    manage_docroot => false,
    directories    => [
      { path           => $resources_dir,
        options        => ['+Indexes', '+FollowSymLinks', '+MultiViews'],
        directoryindex => 'index.html index.html.var /_h5ai/server/php/index.php',
      },
      { path        => "${resources_dir}/pub/yum-repo",
        options     => ['+ExecCGI'],
        addhandlers => [{ handler    => 'cgi-script',
                          extensions => ['.cgi']}],
      },
    ],
    aliases        => $common_aliases,
    rewrites       => $common_rewrites,
    require        => Mount[$resources_dir],
    default_vhost  => true,
  }

  apache::vhost {"plain.${server_alias}":
    vhost_name     => '*',
    port           => 80,
    docroot        => $resources_dir,
    manage_docroot => false,
    directories    => [
      { path           => $resources_dir,
        options        => ['+Indexes', '+FollowSymLinks', '+MultiViews'],
        directoryindex => 'index.html',
      },
      { path        => "${resources_dir}/pub/yum-repo",
        options     => ['+ExecCGI'],
        addhandlers => [{ handler    => 'cgi-script',
                          extensions => ['.cgi']}],
      },
    ],
    aliases        => $common_aliases,
    rewrites       => $common_rewrites,
    require        => Mount[$resources_dir],
  }

  apache::vhost {"plain.${server_alias}-ssl":
    vhost_name     => '*',
    port           => 443,
    ssl            => true,
    ssl_cert       => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/cert.pem",
    ssl_key        => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/privkey.pem",
    ssl_chain      => "/etc/letsencrypt/live/${ssl_cert_primary_domain}/chain.pem",
    ssl_cipher     => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    docroot        => $resources_dir,
    manage_docroot => false,
    directories    => [
      { path           => $resources_dir,
        options        => ['+Indexes', '+FollowSymLinks', '+MultiViews'],
        directoryindex => 'index.html',
      },
      { path        => "${resources_dir}/pub/yum-repo",
        options     => ['+ExecCGI'],
        addhandlers => [{ handler    => 'cgi-script',
                          extensions => ['.cgi']}],
      },
    ],
    aliases        => $common_aliases,
    rewrites       => $common_rewrites,
    require        => Mount[$resources_dir],
  }

  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http',
  }

  firewalld_service { 'Allow HTTPS':
    ensure  => 'present',
    service => 'https',
  }

  exec {'Restart Apache':
    command     => '/bin/systemctl restart httpd.service',
    refreshonly => true,
  }

  Apache::Vhost<|ssl == false|> ~> Exec['Restart Apache'] -> Letsencrypt::Certonly<||> -> Apache::Vhost<|ssl == true|>

}
