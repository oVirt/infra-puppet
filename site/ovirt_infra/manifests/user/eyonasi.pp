# The user for Ehud Yonasi
class ovirt_infra::user::eyonasi($password = undef) {
  ovirt_infra::user {'eyonasi':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQDqmYYwX/CJNkPYGqhy+EMg9mBaRsoUMZHqZjpMQiSNLkZ2vj034bqnEzaHf/+CF73mVyJLxLirQpaI4MtMJnaET0wLzW1Gg0VTEClXzn3J9K+0+UGAHKFCD2Hw3hEoaMhimzpSKFgwHRlVZMsOffJz8g5q+4PYUrxw6pTycqABINCvwADsbYCBw6xUCACVWwIqCCICR7rvm2ATfCIXj4YEXV4E+JKUlswVIuzhD++9x/3uYBJI9pCkg7YrzFPx0L35izktu7jnbhRUSAwzmuoNI8F8wjhhtgIXRXnKTBTA1J07r0Ei6MperVWelxLx5pZNSBOUCbpr71XLS5J1fQ0jcJf885zcQON9BiIdPSw3p9rwgXgXUCYO71zuoVpdH4lgwty0zhAK7j6vs9kNfiecSj1+rqahE7euFb0OHGVoGngr8Vj3hmo9Ns26HLVM2xOy7rE0a5kUBDYIWvB6jm9LtlO4BzD6ZOIjMlB4rjLVcz6YK4h6bX1pUKFuAxHXBNM=',
    password => $password,
  }
}
