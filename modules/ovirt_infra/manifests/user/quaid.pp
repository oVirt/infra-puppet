# The user for Karsten Wade
class ovirt_infra::user::quaid($password = undef) {
  ovirt_infra::user { 'quaid':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCfjnxEmcpPFKjdn/swdAZkhQgVL8Ngc1AG4CLFpeiW3z2KnQoF17wnqTEe7fPDtPHTxJyvsHFEUZHetBe351e8zH2USBV3IcYnQBosTG2086TWjxCBQ2N9Zi8aXLXHnv4vNQhC0ZNRbCuJ7MseKryScnPK5sFhh9u6IyaDG7ClnWtWvmR7y8dCYLb0ZAIJtSxdGHou/7K1b07AZul3L9cvOkLjSPKrSanLgWIOUjgXKbP+s9hZuiO0T7hX1Va46hvu3fthDqs7gMRLwvSUmZKjwSzlCrm8ftNhjK1snyzkoYtgC6i/1MM62EJ32qsAvudbt5tTEiXb69hHP4cGp0Hn',
    password => $password,
  }
}
