# == Class: ovirt_base::ci_tools_repo
#
# This class creates the repo file for the CI Tools
#
class ovirt_base::ci_tools_repo() {
  case $::operatingsystem {
    /^(CentOS|RedHat)$/: { $flavour_url = 'EL' }
    /^Fedora$/: { $flavour_url = 'fedora' }
    default: { fail("Unsupported operatingsystem ${::operatingsystem}") }
  }

  yumrepo { 'ci-tools':
    baseurl  => "http://resources.ovirt.org/repos/ci-tools/${flavour_url}/\$releasever",
    descr    => 'CI Tools repository',
    enabled  => '1',
    gpgcheck => '0',
  }
}
