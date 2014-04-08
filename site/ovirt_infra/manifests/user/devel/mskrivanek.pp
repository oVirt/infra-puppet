# The user for Michal Skrivanek
class ovirt_infra::user::devel::mskrivanek($password = undef) {
  ovirt_infra::user {'mskrivanek':
    key      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAogap5Muk2LAqB7wyyNEtRHQxP/bl6PpJUdc3EVs25Rx+icoo8WMGVw3RIJczx12H6YlRTMTb3mrqwBmtwb8pZAh3Me3GYJYFxHmy7Ln27f+8Z2Gb0kjGWpTzfyEOjzuMb4khwf8wBqo/hEroc/bIe87A1LFgCHLbyCGhVYaCOd6ZoWQv+L2DC4bw/zhAn3FKuaHgRAKHn4Lr7N5NbWgWSWOhUS2d8COgTGnK0rUWvYmzE1uFJRJuzKxJNA9Z2kV/WnFWBPWCROL9Uy/IX7b6sXp+J/7Qo6hFmasm1g4LLvCJKrH63Xz5D1jVebDSgGj9H41ecVpekaBkWciDd1+1dQ==',
    password => $password,
  }
}
