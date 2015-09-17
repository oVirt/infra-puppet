# The user for Sandro Bonazzola
class ovirt_infra::user::sbonazzo($password = undef) {
  ovirt_infra::user {'sbonazzo':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDHzVwXaAy6Fe92U6NOII9JyNNDbwa4AYzaJIMBoXM0Vr2eL7v8VDBBYGoDlAq7Ux1VmGkLXdq5I2tKrZIFrtYziLXCxOO/43+WwlxVrVGQFElV69wx5MrsXIfGkXnEw+j68pg1gX+PWvWTqqLwPwrM9MWeQe+DkJKlymIdpHWSyA0LHzd+l9b4PCqtpkWAadYsgDFOHcAC8e/2h29Il59oWEB8SSWxnj0FAab4YiivVWOOqdWroo1LeuaEJrothqOPaMuFPq3u24+ZdjB9ShzGgWBdaEYSuQ7G2hsxpc3m+jCjqkCIdEZFXU8oXiamzIAFknC4TGYDwYMVdeiHQld/',
    password => $password,
  }
}
