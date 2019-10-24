# The user for Jeffrey
class ovirt_infra::user::jburke($password = undef) {
  ovirt_infra::user { 'jburke':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDK/lCdY3yFPzyGUuTLaWqr9iYaqVGMteCJhPx091zcw6N2rZycP5+n4BW7kyVOHXJj2mu6YKkluZcJ8gESoU++QG/rbWRKo0+XBP2UbbcBsPLm2sQPLb1qoN9EAjP3xPbgjxITKVwweV4E/Rizj/RxlFxXtLdWcXCCj2KlyKneGE1PJS3QvJ0BcsuT5k4kujNpbjB5X7ePyuyqdz5kyOeTGgkIQ+0Tosh+zqQk8QNnh+8xLjqa0D56YR/ykdnZU58D6wdRahuXUju+JwFjGQlCbAJzdpmEOYDDJNsJ/O/t+t4+rNmh0xAHF0EAPhAvAqHZatrtMQVOMbNLPYNN6Qs1',
    password => $password,
  }
}
