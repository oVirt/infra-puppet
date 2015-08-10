# The user for Sharon Naftaly
class ovirt_infra::user::snaftaly($password = undef) {
  ovirt_infra::user {'snaftaly':
    key      => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2BYuc8SYAY+hsgb66QM60LZ3rvO6BzgIKdkCdiPffn1D7rtT2pG1Au2mxp8PElbCsLGotbFCDclCaOxRemi42b+p0MaSzlQtXYfN9QQmjGt9PZUDpyqonVwybtQF/kkOPK1FpOy4WFkGqr7h4HLQKg2/uHVhwRUkOCqIytaN3vTmlK0kkyR2ORGDAstWp1IC6NTwfhfM9wqSTzjfTLeXMAHsI0LrNsRWs6PYcAE821mniAJepJ/vu2KBIQnSRKurCGs8DWL4hSpKU60/T+yQdkpqeCADFjDWmD3jUaMtm2nJihSDJDVDw/xobLt5zpTwJMi8Auhv9oj63WA0Y3DO2Q== snaftaly@snaftaly.csb',
    password => $password,
  }
}
