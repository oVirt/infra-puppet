# The user for Shlomi Ben-David
class ovirt_infra::user::sbendavi($password = undef) {
  ovirt_infra::user { 'sbendavi':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCrHR+dDYbjFvtDKVSXbR4M1yALLnR8rZZralNzcrWDy9YRKTG35LYUi4nrr2fVPJwRkzmVksmgbnvf+34gNKGN5QAncuIyMAqHwv2xxvzsHdRDqaEetBzAj77omgzNpG23TehlRWsZkc/855V/QxH3XePnxoWWCMf6epmYbcdMUa3WD8sqyHpAwqunBGnlbTWVuIWlPVU/piRiRFAY0R0WQ3mAcHnQdrMN+mLdgh0UpitXnY7akymR+eM+3IBq0eMM2DO44pldXnV8Rbc/C0gnqg1NL7vmc8norZbXHKwi64zvP3LhP33Qqcqd7pdZ2quO9JZnt8xjqgMAIhWI5B8j',
    password => $password,
  }
}
