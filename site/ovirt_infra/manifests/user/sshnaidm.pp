# The user for Sagi Shnaidman
class ovirt_infra::user::sshnaidm($password = undef) {
  ovirt_infra::user {'sshnaidm':
    key      =>
    'AAAAB3NzaC1yc2EAAAADAQABAAABAQDKPB9W9cYK19yJ4q3GzfXkCsqRiJ9gMugoaa2+HuKUH15/yht3uaP6XMOo9v4PwdWaB7c1d7Uc6xLcc2DWzLX4AIu2AurVmvHbIY0OpJqhEKcYcQQfEug7W7ckkvSZFjtkrvopYoZck0tHH/GZOOMjB5D+uIH8LKJ40ecAWTTGca18ogw4NVuRviCrloXBDSMGGgxYLxkaObdn7ilrELXHyOrqdL8CaR4ahySg18CacyuWPwvpKg3lcGk3MOJsHBqRSuyoFwmR9tsxo+D48ZFfYABdP3V9wB4YiLWEDd3ekvdSera/a3kUuXSB0gld8mMZicSyULRSoAbzx9z0jfr9',
    password => $password,
  }
}
