# The user for Martin Polednik
class ovirt_infra::user::devel::mpolednik($password = undef) {
  ovirt_infra::user {'mpolednik':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDKmqV4B65sCXgphhlRu8vGAyFns1oHtmJIZ2Y/rN1vzoCR38nAmiC2rzPDuydD0o8wd6j6GTsPHxlPpoiLg/arLWW5wsjcVMUSCc9n4TMGWG/DfcAmFFEuDCeaOopORAmOMwISn7TJ5Wb8/Dz6OfjwNx/6TomBdKX81GfPBBshuP061MVnLZc5UC4GQwRc5Z/AF4YAAJ9D/Q0nFwPxY4rnt6dWeG5dYkKbO2otMwg9rCx3tSqMvYuz60l1cUnOKKiLCEcm9aoM5Op9Y63Hp5TsalzV2UhaTBDeDhmpNav6o1KroeSqxrqOkF93WQCW+xIxw4F2zEQxD53dyvHPEvn3',
    password => $password,
  }
}
