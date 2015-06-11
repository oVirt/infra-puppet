# The user for Anton Marchukov
class ovirt_infra::user::amarchuk($password = undef) {
  ovirt_infra::user {'amarchuk':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDAe/So2oWKe8OHGu+5ntdg8MquN+b6JGsgTc8t11ZHgrUUKPjVfEcDnwGokoiGXZ5HQawo3v9zNUVgQIqHr0ChDAbauH8cUghwkziSBRRtgPk/CfiS82+kR0NiMbCeXPhU1e3kh2oGbwQ3eZ/GkSY5CqvSqw3o9ya49pVh94qR7nCh4zBLGFICenNDsJrbsIY8uKK+CZ9iDO+DgFwA6AYNku9FNuzxanwKwccdT4FLhp4xZab8Zi1xK3e9M4IuzCy1UwWq+CahwkHV+FqcvVhBzt1tmxTeZbV+r1XAERx6tk3Ug93nYpNv5U3xv5DL7dgb9Jlk4ZRiiLYCoc6mK3LP',
    password => $password,
  }
}
