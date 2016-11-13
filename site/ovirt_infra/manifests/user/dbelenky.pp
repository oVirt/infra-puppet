# The user for Daniel Belenky (dbelenky)
class ovirt_infra::user::dbelenky($password = undef) {
  ovirt_infra::user { 'dbelenky':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDcpdqbtiU5Y1V5Pz1O/jq4ON26tdVqUfvXjBWdnGVy/PiqJqqt1bmNcfSndJ9yU+YLbFyEhljcLur4DwIae2uUimNw9WLo0yYBGSnOrhKyAxSnsVnWUmhnaL03Fpq/eU6qBd8l+PMtoayMMS3Cj/ThI/BgYFwvO/kdxwudq74RGy9Zvg8uCaU7iYGEQWnJfarE1FGRQtM46TUSMvbhe0HshwX+EEG1fn1vJlL7D6E3LTABY5QMXUhTMjLN1N2vdsoqSptpuW0x2WllWYxW8A2QDeYmEwVDdJb7+RtoBhDb6qT27NuK7XoLCCd0DLzG2dbXYokP0FuHx7Br8hKbgYjb',
    password => $password,
  }
}
