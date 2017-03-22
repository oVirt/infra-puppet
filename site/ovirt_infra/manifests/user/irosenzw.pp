# The user for Ido Rosenzwig
class ovirt_infra::user::irosenzw($password = undef) {
  ovirt_infra::user { 'irosenzw':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDiwvY0GGKk34GHr5/Ui+C0qfNKLRgjOa1HqH072EO5Dr9JU35ySzNi+S+pRWTGtUFi9oUzPZJHkROKUV2E06XxkMrxp25JqB1dOjyvALy6oiKrmXMYVGymp9kzRVTBb6N3FM0cgfkeD/VCF+e5W4RYHEM33G6zfYfaEJe1dGwQFCi5NNcguQP9Jm/lyXpwm4gMgQUBXaKT3jVL/XSmzHoGpaP4SLFMEXu1hwR8/4Wma5MEXl4Jrn3h+xThjvOiy6bqmojV1JduiAUgbb9qVNHIQ9szjts0VP6En9DfFB9SF915ldzrtdxEEPcEfQ95bFnQxcUhcPCQvKvzUSeI8rf3',
    password => $password,
  }
}
