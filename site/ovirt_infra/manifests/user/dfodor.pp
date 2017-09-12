# The user for Dusan
class ovirt_infra::user::dfodor($password = undef) {
  ovirt_infra::user { 'dfodor':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCXiP8/T3HRZ6JhyDGcgsTtAR+2jv/m58eOgf/67FMR0KwgMmVYL3B8BnmPDVxiUvMpSXGhEQgKmRpNIEgrP70/VPRFl2IdO/2sl+DmKVG7PlVYtHGda0mrhCI8KsG8N631olveJwqlYnCXLFMDUGexaTBguwBTIB9uJtHd2kD20vf8QgmX7pshpxAVuXvIbU6SBJOEMCLFbM+Gj7+LqqV/rdN4COxADzAs4wtHdWCunst2JSsyCCQ4Lpdoc7w1z6GvPzv+yrAohK7gDcgnB/v6+grtOeeFOGFiawWtgkU594MIrZ/3cxogqM+ZRvaU1z8nQpGNDNuMr77Wm5fyiSa/',
    password => $password,
  }
}
