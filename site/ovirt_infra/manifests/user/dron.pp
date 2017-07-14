# The user for Dafna Ron
class ovirt_infra::user::dron($password = undef) {
  ovirt_infra::user {'dron':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDV8apnlzi42RhE5YBrAYwt5BZKAqsn3SAMvPMoqudAOQdERgQR/HXKOAFmcOP5U1Ld7hdlrTcCMbAVCHKddn1q/MDm6H36py7m4d5j5lxch1l1fELSurfrm97lot+AMPW5CeKntgOarAW+TK53WTIzG+924zeArIEc62RYgTa5kiqUpOk/eFVykB1lH4Ameme0dxSpaKhiCTAL1ZpH+GIxdERPdUIOL3kFz/6B6G46joX8tHkC7iJkVxDm6vmt0RL8OO3RJzkVrd6TBjym5DIIMaBQOLB9pke9i/8TQErzc1c/dCruSf2LGBI9pf2opyFV5LfHy/NLDAkVilqKwhlD',
    password => $password,
  }
}
