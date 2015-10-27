# An artifactory default user, appended to security.import.xml
define ovirt_artifactory::user(
  $username,
  $password,
  $salt,
  $email = '',
  $admin = false,
  $import_file = '/etc/opt/jfrog/artifactory/security.import.xml_template',
  $ensure = 'present',
)
{
  case $ensure {
    'present': {
      $changes = [
        "set security/users/#text[last() +1] '\n\t'",
        "defnode user security/users/user[username/#text = '${username}'] ''",
        "set \$user/#text[last() + 1] '\n\t\t'",
        "set \$user/username/#text[last() + 1] '${username}'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/password/#text[last() + 1] '${password}'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/email/#text[last() + 1] '${email}'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/salt/#text[last() + 1] '${salt}'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/admin/#text[last() + 1] '${admin}'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/enabled/#text[last() + 1] 'true'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/updatableProfile/#text[last() + 1] 'true'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/accountNonExpired/#text[last() + 1] 'true'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/credentialsNonExpired/#text[last() + 1] 'true'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/accountNonLocked/#text[last() + 1] 'true'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/realm/#text[last() + 1] 'internal'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/transientUser/#text[last() + 1] 'false'",
        "set \$user/#text[last() + 1] '\t\t'",
        "defnode groups \$user/groups ''",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/lastLoginTimeMillis/#text[last() + 1] '0'",
        "set \$user/#text[last() + 1] '\t\t'",
        "set \$user/lastAccessTimeMillis/#text[last() + 1] '0'",
        "set \$user/#text[last() + 1] '\t'",
      ]
      $match_count = '0'
    }
    'absent': {
      $changes = "rm security/users/user[username/#text = '${username}'"
      $match_count = '1'
      }
      default: {
        fail("unkown value for ${ensure}")
      }
    }
    augeas { "generate_user:${username}_xml":
      lens    => 'Xml.lns',
      incl    => $import_file,
      changes => $changes,
      onlyif  => "match security/users/user[username/#text = '${username}'] size == ${match_count}",
      require => File[$import_file],
    }
  }
