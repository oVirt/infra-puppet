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

  exec {
    'download slave.jar':
      cwd     => '/home/jenkins',
      command => 'wget -N http://jenkins.ovirt.org/jnlpJars/slave.jar -O /home/jenkins/slave.jar',
      creates => '/home/jenkins/slave.jar',
  }

  file {'/lib/systemd/system/jnlp.service' :
    ensure  => file,
    mode    => '0600',
    content => template('ovirt_infra/jnlp.erb'),
    require => Exec['download slave.jar'],
  }

  service {'jnlp' :
    ensure  => running,
    enable  => true,
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

    File['/lib/systemd/system/jnlp.service']
      ~> Exec['refresh_systemd']
      ~> Service['jnlp']
  } elsif $::operatingsystem == 'CentOS' and versioncmp($::operatingsystemrelease, '7.0') < 0 {
    file {'/etc/init.d/jnlp' :
      ensure  => file,
      mode    => '0755',
      content => template('ovirt_infra/jnlp.systemv.erb'),
    }

    file {'/var/log/jenkins/slave.log' :
      ensure  => file,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0660',
    }

    file {'/var/log/jenkins/slave.error.log' :
      ensure  => file,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0660',
    }

    File['/etc/init.d/jnlp']
    ~> File['/var/log/jenkins/slave.log']
    ~> File['/var/log/jenkins/slave.error.log']
    ~> Service['jnlp']

  } else {
    notice("Unsupported operatingsystem ${::operatingsystem}")
  }
}
