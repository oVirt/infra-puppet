# Packages we want on all servers
class ovirt_infra::packages {
  package { 'vim-enhanced':
    ensure => installed,
  }
  package { 'mlocate':
    ensure => installed,
  }
}
