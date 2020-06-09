# The user for Gil Shinar
class ovirt_infra::user::gshinar($password = undef) {
  ovirt_infra::user { 'gshinar':
    ensure => absent,
  }
}
