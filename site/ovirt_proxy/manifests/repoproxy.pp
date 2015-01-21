# == Class: ovirt_proxy::repoproxy
#
# Starta a repoproxy instance, a small service used to proxy yum repos so the
# clients have a static url for them (leverages the mirror selection and
# cycling from them)
#
# === Parameters
# basedir
#   Base directory where to install the app
#
# user
#  User for the files and process
#
# group
#   Group for the file and process
#
# ip
#   Ip to bind to
#
# port
#   Port to listen to
#
# logfile
#   Path to the logfile for the daemon
#
class ovirt_proxy::repoproxy (
  $basedir = '.',
  $user = 'root',
  $group = 'root',
  $ip = '127.0.0.1',
  $port = '5000',
  $logfile = '/var/log/repoproxy.log',
) {

  File {
    owner => $user,
    group => $group,
  }

  file {
    $basedir:
      ensure => directory,
      mode   => '0700';
    "${basedir}/repoproxy.py":
      ensure => file,
      source => 'puppet:///modules/ovirt_proxy/repoproxy.py',
      mode   => '0700';
    "${basedir}/repos.yaml":
      ensure => file,
      source => 'puppet:///modules/ovirt_proxy/repos.yaml',
      mode   => '0400';
    $logfile:
      ensure => file,
      mode   => '0622';
  }

  package {['python-requests', 'python-flask', 'PyYAML', 'python-gevent']:
    ensure => installed,
  }

  $cmd = 'repoproxy.py -d --pid repoproxy.pid'

  exec{
    'Start repoproxy':
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', $basedir],
      command => "${cmd} -i ${ip} -p ${port} --log ${logfile}",
      cwd     => $basedir,
      user    => $user,
      group   => $group,
      unless  => "${cmd} --status";
    'Restart repoproxy':
      path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', $basedir],
      command     => "${cmd} -i ${ip} -p ${port} --log ${logfile} --restart",
      cwd         => $basedir,
      user        => $user,
      group       => $group,
      refreshonly => true;
    'add_firewalld_repoproxy_now':
      command => "firewall-cmd --add-port ${port}/tcp",
      unless  => "firewall-cmd --query-port ${port}/tcp",
      path    => '/bin';
    'add_firewalld_repoproxy_persist':
      command     => "firewall-cmd --persist --add-port ${port}/tcp",
      refreshonly => true,
      path        => '/bin';
  }


  Package['python-requests', 'python-flask', 'PyYAML', 'python-gevent']
  -> File[$basedir]
  -> File["${basedir}/repoproxy.py", "${basedir}/repos.yaml"]
  -> Exec['Start repoproxy', 'Restart repoproxy']

  File["${basedir}/repos.yaml", "${basedir}/repoproxy.py"]
  ~> Exec['Restart repoproxy']
  Exec['add_firewalld_repoproxy_now']
  ~> Exec['add_firewalld_repoproxy_persist']
}
