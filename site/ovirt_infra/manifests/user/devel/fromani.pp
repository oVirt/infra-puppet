# The user for Francesco Romani
class ovirt_infra::user::devel::fromani($password = undef) {
  ovirt_infra::user {'fromani':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCeoQRXWHWfDjIrFA4VrL5NhLFc539IhZfjAXkbQ4svvt5TkV5CoH/uwmBQgDq8p/+JRQDDbv6jq8yWSsaYobWuKQ/ErxKvcooU9vXozvMTlTnOgogFg+T2rjs6jhRSQt9n6wWfKNhpJRu9AH+8Mdgtskr4nO8AOoFHqtqE/ASqYbmJpLTc3UrFsHgziUZHn0TFW/yF9mMrRDy8CA5ZJ295hm6FpfmeKjclUgF9MA5JZ2voVuOAgQUwLnBsFFbnCYa2vyyS/7VxpnBpJXhIKe1zNYywkTSJ6NAmVcO+BSedd9T4AIvzG8Xy1of8/IsMJrRSMgqLeJF2aqaSalsXCZ35',
    password => $password,
  }
}
