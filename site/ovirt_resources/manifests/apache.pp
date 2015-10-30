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

  apache::vhost {$::fqdn:
    vhost_name     => '*',
    port           => 80,
    serveraliases  => [$server_alias],
    docroot        => $resources_dir,
    directoryindex => 'index.html index.html.var /_h5ai/server/php/index.php',
    manage_docroot => false,
    aliases        => $common_aliases,
    require        => Mount[$resources_dir],
    default_vhost  => true,
  }

  apache::vhost {"plain.${::fqdn}":
    vhost_name     => '*',
    serveraliases  => ["plain.${server_alias}"],
    docroot        => $resources_dir,
    directoryindex => 'index.html',
    manage_docroot => false,
    aliases        => $common_aliases,
    require        => Mount[$resources_dir],
  }

  firewalld_service { 'Allow HTTP':
    ensure  => 'present',
    service => 'http',
  }

}
