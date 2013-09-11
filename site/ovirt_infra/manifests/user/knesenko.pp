# The user for Kiril Nesenko
class ovirt_infra::user::knesenko($password = undef) {
  ovirt_infra::user {'knesenko':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC3lARddzwVFQu8WPibzkCz830OjzTztEOUE6uejgsqUTbd15VmAlUhm2UFZnElUVHk1cwpr7KYFWEmzFRzJ8w79j3AgfGqauvIXPfClsEfqp3UPPGDok7HakXnGj6zV4ePNzHsQfn38DxwLblyR9c+S2O4R4sL62J2BhESvZGG5RfzlJPZghgkuh8jjlWDqN4jTYISMOaZ+jOueFLanEEzOuqct5QhyA1ToseWTfotXm40PYQlfx2OP9ub9Wevb1Sj0b832KccP+xrrePuRqgpJdg0PZZb/HknIND44k5gm+sMvm8mX6R6YfDPZNli76kCGi8hqiKnUroCe2niRe8x',
    password => $password,
  }
}
