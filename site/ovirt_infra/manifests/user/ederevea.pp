# The user for Evgheni
class ovirt_infra::user::ederevea($password = undef) {
  ovirt_infra::user { 'ederevea':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQDuIRn6Kw6orQQGeXgqa2JGZIvVWWzk+lnpmzZpRi0GZdKECFpuy1+LRdeUy86OGDm9MN0BIyS/Tdkg17GCDPFquDw2tyi40ZARLo6osDvnsYk6xNeFNh4i0NpHdUlsD62Sfnwbjoi3HWcTtVcB4FadQG0I8o4WYfeKoEwRZ9pxuXQkXVYg8slG8Aj3OvR/E60abcq4GWFqYM8cWsRqou3FegoCX+8aPI6ytRnhxm/GuFL0PVvXC/7zEEW+EsTmImxpULhxAkikAKNrSrxIJSiEMBBcWFZjTgvA4U0WSEiIZ0CFOwD73M5jhKDtOaHOqxvWHZIG4blI1Gn00fOAcYEbRaDYDECMI39IY+ic6cTiz4lRQa/HkjHmt3e89S6rqAeJ3JlEC4TeFLlIjUr84d/avPS6OT6JWYH31lKOuxiEqhZkoZZtmA+0OGule6hrYsOvFLGmXPYSQk7dVHaCSZyjQD7K1l/wqh4S2XOTwv6XDvkLEeHtXQci7pCj/2uantc=',
    password => $password,
  }
}
