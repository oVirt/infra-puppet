# The user for Shlomi Ben-David
class ovirt_infra::user::sbendavi($password = undef) {
  ovirt_infra::user { 'sbendavi':
    ensure => absent,
  }
}
