class ovirt_infra::puppet_deploy (
  $username = 'puppet-repos',
) {
  $homedir = "/home/${username}"
  $update = "${homedir}/bin/update"
  $r10k = "${homedir}/bin/r10k"

  user {$username:
    ensure  => present,
    home    => $homedir,
  }

  file {"${homedir}/bin":
    ensure => directory,
    owner  => $username,
  }

  file {$update:
    content => "#!/bin/sh\nscl enable ruby193 '${r10k} deploy environment'",
    owner   => $username,
    mode    => '0755',
  }

  exec {'scl enable ruby193 "gem install r10k"':
    creates     => $r10k,
    user        => $username,
    cwd         => $homedir,
    environment => "HOME=${homedir}",
  }

  file {'/etc/r10k.yaml':
    content => template('ovirt_infra/r10k.yaml.erb'),
  }

  ssh_authorized_key { "Allow jenkins to update puppet for ${username}":
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAykXy+X1qUI/TyblF5J35A1bexPeFWj7SmzzcClS3GzQ8jEaV7AaOzbvyl2dQ8P4nh8tr2nSeT7LAFYWhIGscy6V7p5vMRr3mUzRA/E/g3r9wdmdDcPLOqfpJWiLTDlA3XQyFhJnwQopGRBSf5yzFGWFezH+rjzlwBDDN2mQkI/WuSEBh+UT/9+E7JvQBVhg2hapXszfSrrtrVniw/1TvNJEvR+wdwxCUkJWP+LZOtdbGIYQZMkmw8yMNy/fkEfxR3CLge65rDCbxqlDkqFff0VWcwd3SBXdIo4T1401kIjcPiPR9npib7Ra88QiWXIazHW05ejp+m2W136zmYmfxFw==',
    type    => 'ssh-rsa',
    user    => $username,
    options => "command=\"${update}\"",
  }
}
