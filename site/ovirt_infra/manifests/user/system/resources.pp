# The user for the resources user. used for deployment of rpms to resources.ovirt.org
class ovirt_infra::user::system::resources($password = undef) {
  ovirt_infra::user { 'resources':
    key      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAvSGgC58ycKfCRAHLQSssZCFaMxYn+ZHS5+JEN4UB5nD701CoEBmDqnemSlOgcf4FX0LZc41/G5kn7fvitvFEyf7cXGT7CA+t5JRddhN2f2NgYpnC59xrLLdAk6of5HgtDML3aqKH+YOaw9yHoFMZPj+qGJPH/K5YbkED43qL6PRL6egjG6LlY9dpBDwV4SZGXYSprSFBGo8B+PeLiJIM9HkSiUqjOlIDdBCTWC4ml1Shkmtv+9eeVtx+CclX0htVPq0j42a+xuWhaiEU2pycku2dB7tQbkh+q5G4171N2PxAiIwK3GD9euIC7Nl5flh93N5kLRy+t76XbNesmR4quQ== resources@linode01.ovirt.org',
    password => $password,
    sudo     => false,
  }
}
