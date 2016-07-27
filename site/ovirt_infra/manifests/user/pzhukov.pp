# The user for Pavel Zhukov
class ovirt_infra::user::pzhukov($password = undef) {
  ovirt_infra::user { 'pzhukov':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDUBdY4lw+fLjhDyxWL6NmxfQ0lSXmsLCOqISkJVh6Z44n86q2UQw0j+aXYKgSdrPuc/jzOmXHyXMFF32RMI4fz6ekKdjYnCYxf7Q/ypoWTS5I3PBgj3YIFs3OLReUPBsp5tEkscYLZG0xMwFRHsuNTTjX+N18ur5aTXecfIZfGXB7JslqW5pd3fh1mr22A5R8FvUBZtJPchUC6/YYW5Jzc5+7bCSxCEz8cP88q1e5CBq6M1ZflKWhqjXpLyO54u1pn/S/HoXkcxkDFCUw0WlFW1rbYEJ2Ns0+HQJg6+ktiU/HwfPNyYTxYeQT0c1omCgCN9EtM1KX0UVR62gzlXqLP',
    password => $password,
  }
}
