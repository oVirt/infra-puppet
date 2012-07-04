node default {
  include ovirt_infra
}

node 'jenkins.ekohl.nl' inherits default {
  include ovirt_infra::jenkins
}
