#this class configures the jnlp service

class ovirt_infra::jnlp ($secret_key = $::secret_key, $jnlpurl = $::jnlpurl) {

  if $::operatingsystem == 'Fedora' {
    file {'/lib/systemd/system/jnlp.service' :
      ensure  => file,
      mode    => '0600',
      content => template('ovirt_infra/jnlp.systemd.erb'),
    }

    service {'jnlp' :
      ensure  => running,
      enable  => true,
    }

    File['/lib/systemd/system/jnlp.service'] ~> Service['jnlp']
  } else {
    notice("Unsupported operatingsystem ${::operatingsystem}")
  }
}
