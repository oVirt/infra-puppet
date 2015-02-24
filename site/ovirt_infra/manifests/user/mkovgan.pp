# The user for Max Kovgan
class ovirt_infra::user::mkovgan($password = undef) {
  ovirt_infra::user {'mkovgan':
    key      =>
    'AAAAB3NzaC1yc2EAAAABIwAAAQEApkNFpP8gLGtl1BT7wRzj8FDN6oDvceig/TlGcHntcI+YNPT71ytiTBPFSZlGga052K7Ux6USMRPjGwqohaE/Eh82YZP+E2o3RkFUGyPrchbSLORDzKFskAMaVMlUwwMjJ8nNQYDPXUA8UX8ZxZZIS9uAn34J+t4LuLPW316jBaQTQMaE+en80TbfiwnjcxTFjPtkIqJHcVmsjCvalgBlQzrKkN2GJWezZE6AQq2Nlkz+QpG7PCS/yYLWxYsTZoJidAch/iykGwjX2vbhNkKIEaiBZOubCn1Pu7zqGQnhUPLsBol+YFrsnxYOHlH60jfpcPHdCxCzMUizRkARfFiB1w==',
    password => $password,
  }
}
