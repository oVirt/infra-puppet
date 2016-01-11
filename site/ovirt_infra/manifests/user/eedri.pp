# The user for Eyal Edri
class ovirt_infra::user::eedri($password = undef) {
  ovirt_infra::user { 'eedri':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC288XR5mM3oZNwYoUjsRTzyxzSPFT+MxFwOmIOAhhOGmLHDQi0lDWbSmIwXFo17Ph5A88ucl1Iu0uHZAJ7RSImjHejZCNEcwLmB6/ytVVWacDAKgZk6eEL/2dIqREqHub2X19wIMfFgrQ1aC2C6B52IdOB8O8TbBIOD5V6wqTwgj+rPosCgI10KBsWcpS0vjQT5RPi2jizlRLDj4y6lOvaMH70vaX6ZU0w1HzANK751jWMgrYFt9eKiLcKA+YcRDqJ9WNVwZgrwHelxiUNbEgsz6pv402c8pPZGx4C8L3OvlCJ86S9tpm7kx1R11SJZbxvV/KUV85t7+Bkp8Pj4RYF',
    password => $password,
  }
}
