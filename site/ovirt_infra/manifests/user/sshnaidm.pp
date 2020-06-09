# The user for Sagi Shnaidman
class ovirt_infra::user::sshnaidm($password = undef) {
  ovirt_infra::user {'sshnaidm':
    ensure => absent,
  }
}
