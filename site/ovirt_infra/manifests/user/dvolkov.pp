# The user for Denis Volkov
class ovirt_infra::user::dvolkov($password = undef) {
  ovirt_infra::user { 'dvolkov':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDPBJLzmUqG9bHHCXUsouGo0a+M/NsmClSJCPEc4F47NWlEEJ8LQX+kFmPmTwCf6UBWCz3FdRvU70peiYD0tdumckjnDFVruKtfAhIHxU19jI4oVmSB0pDKwWZU8DgDgIdKh3H7sGzi7YJXBsE7iesCjzTQAwxu+Pe5rv3/zVfZEFdj5FiQoliar/YNyuOT13NTGTjoqyUopMF+7io9buENWS6m3WKjAyGenVGPh5qRC+y/bbvYxqxUXljaTIRM593iPkogDiWsyYb3lKE2jfM0OUxqh08NBkbIwV3Z6JBFczxQrAE4DEQp9laybNn65RulRUi9TJDYGJWuniQLkaOL',
    password => $password,
  }
}
