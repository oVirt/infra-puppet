# The user for Daniel Belenky (dbelenky)
class ovirt_infra::user::dbelenky($password = undef) {
  ovirt_infra::user { 'dbelenky':
    ensure => absent,
  }
}
