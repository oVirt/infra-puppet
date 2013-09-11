# The user for Ohad Basan
class ovirt_infra::user::obasan($password = undef) {
  ovirt_infra::user {'obasan':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDUHfDVi+l1Mv/qF7oThINAmSpGtkw+Mi8kPk3m8funyj+goa/thUq6rGfk4PvToetmMVZmLFJt+eljiX01cZPzihdKRVK4OE3KfX8xDAiF93m2NhOpoPi6N3GS9q8crs5jLhV9A3ciAZaXOF3xtrffBvXVmdBKcqQUvoLQeXIMDq4/XrpP4HYPvlzEx5w2s06j1oWhthOjYm7bugwumn6VCBLo32jHRnKnqZI68Fig22KJlkt23i90gVycBOyVW2qCWBQZTxbwwXE98ujUVyvjFnr8+7H7llHchj5VpcW63I1fjXyMrgUgakzTZ2RwtByAxxgWevDXP34/P/SFYmkD',
    password => $password,
  }
}
