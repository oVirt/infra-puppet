# The user for Marc Dequènes (Duck)
class ovirt_infra::user::duck($password = undef) {
  ovirt_infra::user { 'duck':
    key      => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFF7fG1/v1CJmIGjRMlPKOwPt6gUOxmoWMLGh79PakIngrj/We3fZRDj8OOgtW07SmYqfeoIpg168UMTbJBwrEw=',
    type     => 'ecdsa-sha2-nistp256',
    password => $password,
  }
}
