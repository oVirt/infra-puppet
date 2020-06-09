# The user for Max Kovgan
class ovirt_infra::user::mkovgan($password = undef) {
  ovirt_infra::user {'mkovgan':
    ensure => absent,
  }
}
