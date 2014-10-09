# Handles the apache configuration for a machine that has the
# repositories in it, that is, a resources machine
class ovirt_resources(
  $resources_dir='/data/repos',
) {

  include ::apache
  include ::apache::mod::prefork
  include ::apache::mod::php
  include ::apache::mod::ssl

  apache::vhost {$::fqdn:
    vhost_name     => '*',
    docroot        => $resources_dir,
    directoryindex => 'index.html index.html.var /_h5ai/server/php/index.php',
    manage_docroot => false,
  }

  apache::vhost {"plain.${::fqdn}":
    vhost_name     => '*',
    docroot        => "${resources_dir}.plain",
    directoryindex => 'index.html',
    manage_docroot => false,
  }
}
