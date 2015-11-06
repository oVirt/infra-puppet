# Handles the apache configuration for a machine that has the
# repositories in it, that is, a resources machine
class ovirt_resources::apache(
  $resources_dir ='/data/repos',
  $server_alias  ='resources.ovirt.org',
) {
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

  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http',
  }

}
