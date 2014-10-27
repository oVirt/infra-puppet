# == Class: ovirt_jenkins_slave::sudo
#
# This class makes sure the host has all that's needed to run sudo in
# a jenkins slave
#
# === Parameters
#
# [*user*]
#
# User to give sudo rights to
#
class ovirt_jenkins_slave::sudo (
  $user='jenkins',
) {

  augeas { 'jenkins full sudo':
    context => '/files/etc/sudoers',
    changes => [
      # cleanup before creating the entry
      "rm spec[user = \"${user}\"]",
      "set spec[user = \"${user}\"]/user ${user}",
      "set spec[user = \"${user}\"]/host_group/host ALL",
      "set spec[user = \"${user}\"]/host_group/command ALL",
      "set spec[user = \"${user}\"]/host_group/command/runas_user ALL",
      "set spec[user = \"${user}\"]/host_group/command/tag NOPASSWD",
    ],
  }


  augeas { 'jenkins !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      "set Defaults[type=\":${user}\"]/type :${user}",
      "clear Defaults[type=\":${user}\"]/requiretty/negate",
    ],
  }

  augeas { 'allow passing HOME through':
    context => '/files/etc/sudoers',
    changes => [
      'rm Defaults[always_set_home]',
    ],
  }

  augeas { 'root !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      'set Defaults[type=":root"]/type :root',
      'clear Defaults[type=":root"]/requiretty/negate',
    ],
  }
}
