#this class configures the jnlp service

class ovirt_infra::jnlp (
  $secret_key = $::secret_key,
  $jnlpurl = $::jnlpurl,
  $nofiles = $::nofiles,
) {

  if $nofiles == undef {
    $my_nofiles = 64000
  } else {
    $my_nofiles = $nofiles
  }

  if $::operatingsystem == 'Fedora' {
    file {'/lib/systemd/system/jnlp.service' :
      ensure  => file,
      mode    => '0600',
      content => template('ovirt_infra/jnlp.systemd.erb'),
    }

    exec {'refresh_systemd':
      command     => 'systemctl --system daemon-reload',
      refreshonly => true,
    }

    service {'jnlp' :
      ensure  => running,
      enable  => true,
    }

    File['/lib/systemd/system/jnlp.service']
      ~> Exec['refresh_systemd']
      ~> Service['jnlp']
  } else {
    notice("Unsupported operatingsystem ${::operatingsystem}")
  }
}
