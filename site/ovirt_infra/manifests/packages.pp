# Packages we want on all servers
class ovirt_infra::packages {
  package {'vim-minimal':
    ensure => latest,
  }
  package {'vim-enhanced':
    ensure => installed,
  }
  Package['vim-minimal']
  -> Package['vim-enhanced']
}
