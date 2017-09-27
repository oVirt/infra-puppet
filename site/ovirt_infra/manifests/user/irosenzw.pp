# The user for Ido Rosenzwig
class ovirt_infra::user::irosenzw($password = undef) {
  ovirt_infra::user { 'irosenzw':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC4U760ZdughzAVILQF1BmzGREudMzRUVg7MW902Vx7BmOD868Hf3c+kIxaqha0T2UFvWKK6iqzFQM7H4+uGPP1gnv/1xiaF/KOrX6IBUDa1Z6dAL80JNmsuEJzB1aAoJBXTCSJY2qMO+uPzrObEVF5CnEyAY9rTVF0g2ocN7eXJpv5hhvKlLY3m4TOrun2U/dKVIfFt1aJxPb96G0j754T6gupa8RUiHc2+K4zn1q+UYDFVHlly25pQKzO7l/iaxAibQ9Fv2yFcxR/c03QBlbeVv6BamBVvkG5P/K6890CIZ5s3yMe/ZfOT6PMtZj1DHm02/m51fxMRdFB8FfKM2np',
    password => $password,
  }
}
