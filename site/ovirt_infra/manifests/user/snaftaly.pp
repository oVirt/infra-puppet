# The user for Sharon Naftaly
class ovirt_infra::user::snaftaly($password = undef) {
  ovirt_infra::user {'snaftaly':
    ensure => absent,
  }
}
