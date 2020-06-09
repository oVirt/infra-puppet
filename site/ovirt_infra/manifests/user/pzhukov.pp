# The user for Pavel Zhukov
class ovirt_infra::user::pzhukov($password = undef) {
  ovirt_infra::user { 'pzhukov':
    ensure => absent,
  }
}
