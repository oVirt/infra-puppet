# The user for Ryan Barry
class ovirt_infra::user::rbarry($password = undef) {
  ovirt_infra::user { 'rbarry':
    ensure => absent,
  }
}
