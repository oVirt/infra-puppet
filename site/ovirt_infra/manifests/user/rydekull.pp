# The user for Alexander
class ovirt_infra::user::rydekull($password = undef) {
  ovirt_infra::user { 'rydekull':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDOvvQWRCr+BoQMLpVq9OTzmVfNqKbuzXYgColRawf5wz+06ZTvIWdzjc8JWqJO4myZ7S4i7qqDvsJCXzLtniodbx56oRLNgUeewTR6esm6WWhO+FZwxgX7Iv73sJ4PFC3OXspklPJ8yxiPs2x9W85Nq9Ml0sdPRWHPJ57H6eWHS+/833lJTUCSnyM//WBRoelpTJqCb5aojKNvXMONGmAuvwBL9i4ZVCFoFZkUyT+BRNnJKmORBOMvWTdtj8qehY9wk5EaAvR8Bx0tjKeiu8sfwmQM1gSTTNyrPBxQNg/qSwvgfNX9y2d0KEDui5VobMPqPY1dvJCLCx60KtE2SyL5',
    password => $password,
  }
}
