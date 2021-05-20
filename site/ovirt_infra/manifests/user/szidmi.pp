# The user for Shlomi Zidmi
class ovirt_infra::user::szidmi($password = undef) {
  ovirt_infra::user {'szidmi':
    ensure => absent,
  }
}
