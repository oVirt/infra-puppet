# The user for Daniel Belenky (dbelenky)
class ovirt_infra::user::dbelenky($password = undef) {
  ovirt_infra::user { 'dbelenky':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDGWNBWF2vLW1P+hi4hK7oFuyDKAtdHx4dgbLQiEY0QhCx6krUZCRXqE++wtanlzuFP2n7klFARst8GhBqjEtdG3xFIsmcb89VqaRvAMR/XO0nPOfFnvHQxUDxJVRxbrxoQiEc5mjfUeVTu3e5V/gKERPNIcd+yj6qJ4Zw3/fj/yfpJ4kUShzAJxsh1nbcxbwl8wEcjO/4K9Pvuje5m3QNl7QiuWrWOUzrWYotV8m0oUeqIdfhZlLzPj19I38Bgbs9+Iet21yOzcokovswruULb+WqL73BbtRBAITUErMSK8Ks5858gP+kf5cDWGaCRUazaMQxNvrBpql/eBVJNviS5',
    password => $password,
  }
}
