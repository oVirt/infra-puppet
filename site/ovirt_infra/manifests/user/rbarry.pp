# The user for Ryan Barry
class ovirt_infra::user::rbarry($password = undef) {
  ovirt_infra::user { 'rbarry':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJalCjLFWybpcuoNQ+vBILEboZuD7ozi+QyiJod3o6ot20ijJWgt29qgGnR7AP+T+g3RajkWDDsfoMi3lD4GXqfZO49uiwPEY/iUlGApwLH8pZ4P3vPXemoV4prJRE1lMj7f3k2hqSoeL+5Bi2+UBqyAM1nFn6nbsQinOp9kASCEXsTbajCrAI+Sa6yEz7iD9W42fKvldrt2p7wTXjARWzcU8DQfCFgOXpXhCyJd5cG0ZH3Di8RoLP/5OYvOEpgwTFtb8FOz15O/E9HdOocSKV1zn0MECMrxRwYHZc8nTNulGX03pWcHS31gL+/B021HCpdjRd3pu0KHFpS5yivkrB',
    password => $password,
  }
}
