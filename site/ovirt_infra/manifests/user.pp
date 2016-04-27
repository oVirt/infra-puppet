# Define an ovirt_infra user
define ovirt_infra::user (
    $key = undef,
    $sudo = true,
    $ensure = present,
    $password = undef,
    $type = 'ssh-rsa',
) {
  user { $name:
    ensure     => $ensure,
    managehome => true,
    password   => $password,
  }

  if ($key != undef) {
    ssh_authorized_key {"key-${name}":
      key  => $key,
      type => $type,
      user => $name,
    }
  }

  case $sudo {
    true: {
      augeas { "Allow sudo ${name}":
        context => '/files/etc/sudoers',
        changes => [
          "set spec[user = '${name}']/user ${name}",
          "set spec[user = '${name}']/host_group/host ALL",
          "set spec[user = '${name}']/host_group/command ALL",
          "set spec[user = '${name}']/host_group/command/runas_user root",
          "set spec[user = '${name}']/host_group/command/tag PASSWD",
        ],
      }
    }
    default: {
      augeas { "Disallow sudo ${name}":
        context => '/files/etc/sudoers',
        changes => [
          "rm spec[user = '${name}']/user ${name}",
        ],
      }
    }
  }
}
