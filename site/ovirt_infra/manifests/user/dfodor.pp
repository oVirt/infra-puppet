# The user for Dusan
class ovirt_infra::user::dfodor($password = undef) {
  ovirt_infra::user { 'dfodor':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC2J9ephq7Bd2rkMr+8CVD1n+eizQpk2TCVJf+yqXEra285vysYg5km7HqV/+650bLDG3PyqD4xVnP6woF1FYV7GenBSft98ww042wqNsFcOI6fyRpkQj+3ZLoRfdItkeowZ1s5183QJrmTu/XDCBEe80VQxFsuD4E19FBVfHcp2c9k2X2C8NhcVeGr1oPV48aiAjtL2mlKCYXD5WfzFhk0czwWzygUUGWHGoDA70tQr6w47u90n7yk2ptnJV8EeXdK8nb3ocVoDa2GOvymzoXySf/2Euu1wG3Y19t5Ymj97WGY+90ZVHOmc2AMx5iiSsYrHk93fWgujfg8unPJ/Hq5',
    password => $password,
  }
}
