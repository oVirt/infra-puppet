# The user for David Caro
class ovirt_infra::user::dcaro($password = undef) {
  ovirt_infra::user {'dcaro':
    ensure => absent,
  }
}
