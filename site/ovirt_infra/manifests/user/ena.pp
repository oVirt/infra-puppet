# The user for Emil Natan
class ovirt_infra::user::ena($password = undef) {
  ovirt_infra::user {'ena':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCmUO+zG3Vgm12R2VoUNtQypqtl1mUZ8zddhYzYGRCw+bspX6IgQ6otzBI5/qatt1bFWmbD7Wpr3pT+yiKnefLbiu2osORh2EaVvY1knpfZbqcQT8EgI17jkGwQ+d/tZAHuiglU3Ol9vNQQKJZoZZv3+2lE8stdRaI+pAeSLZrENtEfZUp515vDGae/tSTl5A6Twj3Kf+k7q+vZ6O79aLm7m5/mL0CGNYC9BLUAEwNcTlWld/2PXJsbmpSOqX0T5tfKD/54vhHJWI7BGjDLoNrelQPY9KaPGE6BVDnZVLqOwklrqNK6CBdlTZP4O2SpXIa9B27JfYIQSSVHBjD9OBcV',
    password => $password,
  }
}
