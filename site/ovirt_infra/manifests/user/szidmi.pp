# The user for Shlomi Zidmi
class ovirt_infra::user::szidmi($password = undef) {
  ovirt_infra::user {'szidmi':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDNTrgWpi5d8HXZvF3kObOKmp/ShsYRBKLd0nerZLKMUoL6+KCBKYznIXJtUytE3qd/loDAOaYzA1bqLQMVYYpuCKBfIn4bG0c5vN+4bcoSbwCsELnuC+RShnyJmk/Oqe05fdFEhirnt4Xrm9YexnALWbbbiIIzfK+KUeJEMQ9KV8qksCKoM23K87PTSsi/6elqaxDhlpDNb7YArXCnbxmuWjLV7FvWMAziVydaJHWnnLa5mf1LyiNpkFNZG/w+2bymRUFWKWDG4PQK93cXFf13kHhWCjGxwGRF72JSTJ54K7Mygk79omd0yqqdTxJWScrrF5lzKpyQVyXLyL0HAst1',
    password => $password,
  }
}
