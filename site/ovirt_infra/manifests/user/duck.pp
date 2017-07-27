# The user for Marc Dequènes (Duck)
class ovirt_infra::user::duck($password = undef) {
  ovirt_infra::user { 'duck':
    key      => 'AAAAC3NzaC1lZDI1NTE5AAAAINkTw3tpP6CFVAFKCGucuJUluJbgaqBInH91e8HyK46U',
    type     => 'ssh-ed25519',
    password => $password,
  }
}
