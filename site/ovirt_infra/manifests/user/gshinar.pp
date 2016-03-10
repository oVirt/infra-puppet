# The user for Gil Shinar
class ovirt_infra::user::gshinar($password = undef) {
  ovirt_infra::user { 'gshinar':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQClCIGs0etBlsQo0ZK5uKAMRsio58UbdTVAQPriheuWS9fql8VCxe0mIoeZMZweToQIJVNCLg2byi4wT8mudyrnCE0FQKSVQRoCPbAzJeDpAplG2lE4BhxpYGNN0wNOgbu4JOoLFsSe16lo97So1hWMShaaJJIX0j6HvvJ5ujClzicwxsLcJLatL1vl9q3K9yW6QgS4JBlXV1gmR2nEU6aKpkR9PP09fUFhsRXiVU73gym7hHH+lOuhgxbtaIftKnDGIAg3GZ4UxOVHvLqKGi3qVvqnNF+kK7heoRNJZOVhQF6uQI/42j0X1k3SvuzlQDKnmfnfFZp7to2XBT3h9x01',
    password => $password,
  }
}
