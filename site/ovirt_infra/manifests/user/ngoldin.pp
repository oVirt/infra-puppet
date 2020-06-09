# The user for Nadav Goldin
class ovirt_infra::user::ngoldin($password = undef) {
  ovirt_infra::user {'ngoldin':
    ensure => absent,
  }
}
