# The user for Shlomi Zidmi
class ovirt_infra::user::szidmi($password = undef) {
  ovirt_infra::user {'szidmi':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCd9R3JkVrtp4obsjKFR621AGpPSyWbC5iu2hjQ0stWU3BRNECqSP6yQOiCsUKDdgBfE8GqEAvtry8A5OkijdWb2007Ly7mrv3OJrDmDaa8NPXApVOANjDhSyZNOLk5bu5Ap1vLGAQScjiG/75LUNzA0+P9/E5liTbGvJnT+lOwHwWI5MLIVSG/Utq+nVCLmvJyJBVY1AYpsXdvE5mtOSzDT/bYD6XpcmbEP+a9wODvyOQCpVkyjHdMTQna7O5P34Ud6M4gOdfkAO0n5f8GCo+u9qZZ1ooanaBOOcR+yfWOpqUgrz6c1tFLXEZek6hkl1vpvZbk5jcKCDN30f5jBOxL',
    password => $password,
  }
}
