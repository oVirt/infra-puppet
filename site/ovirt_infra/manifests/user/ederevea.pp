# The user for Evgheni
class ovirt_infra::user::ederevea($password = undef) {
  ovirt_infra::user { 'ederevea':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCkvKo7+VPy++WsFOosPNyZu6MxRTak2juGVu+xOLbsUEJruVTouDSB0cIM35lA0cT9Zx3yC3U2hzOA12B6IULQpZNeqg4xM66PlEt+Y996hWbxK5G0xlHROyP4sYBK9j4nZVXmykII90h475JUXEEAZ0JjnTwCcdUp4P89KMcsxoZNj7k+f5A8/a0817xb9Af13oWaxc+dTis/IfBabH4ozY4Z8guFmOIrlgQ1faleAo3LrTsYWrcI4hV2jjKGTQr0V3CVmYKfNTs6/i3IYfq8TvvPxoq5Pt2K9cOdq8QiaF5Qv+S9fS3bkDQc6ObBHr0x7YMBvXRkzc+30QYKw5DR',
    password => $password,
  }
}
