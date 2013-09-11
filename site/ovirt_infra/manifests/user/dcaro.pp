# The user for David Caro
class ovirt_infra::user::dcaro($password = undef) {
  ovirt_infra::user {'dcaro':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDu48m2QO4o2CgX4/XEzEUJw53o+Ehjb3WoCxeMDda0kZ4AKXHwgOOf1VR/HyNHq7Ui0XgSdL638S+mvSMWZXTi1vuvmoaH29+zPRazID6xh1M7IaSoBRzaNjyX+Cpo7ZsleQ4RNJEfSoHNPGbnTGWZcX9KSwtRTLfZ59t0U4IPFddtwI4PJJBdygu/lLztdjpC5EjjfdG91EK8bCfhLf1/z4+b13/GGgShu56wnnbxyJXZnHHxiPhYRLgGfzufVhb7mWqv51AvO9wqlDp+IjDn/v/7nAwCdWf3mCukZQ/joMVsf+/HdDFtY+xchzLCfzEJy968wC2ias7bsS/qQD//',
    password => $password,
  }
}
