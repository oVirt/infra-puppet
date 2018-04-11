# The user for Ehud Yonasi
class ovirt_infra::user::eyonasi($password = undef) {
  ovirt_infra::user {'eyonasi':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCq1PlLWFYfn0LtD4GdDQRMFaCizbbqoD0gE6NYDHy4tIGrJ7HbKtzRweMHBh7SHcOmOMdvhEHx+1wuzYJ2cZCuRQebtqYbXYvvVbRAs8oOMXr23I0+qqpCcjZeNSKdqvIXgruuOPug4nRcyg3LxZ3xnsgQnxSIm9BQNjn2tvN6aAtAf9HmYW32qtE042pzJYRh8qQerKzoLpd/zd9hMccNeRCdxAXxHDZJO2GpfSbi1A7IKmwKcWS+V2pvuI6I1JQr+WJmna0T7VZdLQVAQq7RjPq0Kv9xFh0Ot+LyPX0Fdk/EHXW11JriyMNIXSjFX586UhS9At/UVZ6+utv3sRtT',
    password => $password,
  }
}
