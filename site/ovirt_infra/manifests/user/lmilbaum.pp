# The user for Liora Milbaum
class ovirt_infra::user::lmilbaum($password = undef) {
  ovirt_infra::user {'lmilbaum':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCyYThx+E9lB+j989hxvnl7XAiG/lD/ZoEokoTdbuSGxIAgIx2ai7jbfBf6rn5S0KyfLw86bT4FCJ2F1sJzi9c7lzkfXRdEAfoGfWsxLBP1KgKgG9CccBlNr9PEPV6f2Czg02NSWb2kfcLxhIcYSkqZQj9wYknMG4esm0isE+EGjbnRa5h6Okjmbicf2Gtwg3hmcHdgdZ657Je1AQ75blVkcByBsVbnjfIDhkaJfMqjIKY/N2acELTZ76AB2bT0A5JzTFz3vwyhMhrYKDpBzLImvOhWkOlFERL/tGuPJ7YYT1KYfjt1VRqeDXgNgsJs14SrFbJQuea8T7WSRjYqhEwn',
    password => $password,
  }
}
