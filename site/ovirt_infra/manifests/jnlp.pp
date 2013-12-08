#this class configures the jnlp systemd service

class ovirt_infra::jnlp ($secret_key = $::secret_key, $jnlpurl = $::jnlpurl) {


  file {'/lib/systemd/system/jnlp.service' :
    ensure  => file,
    mode    => '0600',
    content => template('ovirt_infra/jnlp.erb'),
  }

  service {'jnlp' :
    ensure  => running,
    enable  => true,
    require => File['/lib/systemd/system/jnlp.service'],
  }
}
