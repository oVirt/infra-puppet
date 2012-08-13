define ovirt_infra::user (
    $key = undef,
    $sudo = true,
    $ensure = present,
) {
  user { $name:
    ensure     => $ensure,
    managehome => true,
  }

  if ($key != undef) {
    ssh_authorized_key {"key-$name":
      key     => $key,
      type    => 'ssh-rsa',
      user    => $name,
    }
  }

  case $sudo {
    true: {
      augeas { "Allow sudo $name":
        context => '/files/etc/sudoers',
        changes => [
          "set spec[user = '$name']/user $name",
          "set spec[user = '$name']/host_group/host ALL",
          "set spec[user = '$name']/host_group/command ALL",
          "set spec[user = '$name']/host_group/command/runas_user root",
          "set spec[user = '$name']/host_group/command/tag NOPASSWD",
        ],
      }
    }
    default: {
      augeas { "Disallow sudo $name":
        context => '/files/etc/sudoers',
        changes => [
          "clear spec[user = '$name']/user $name",
        ],
      }
    }
  }
}
