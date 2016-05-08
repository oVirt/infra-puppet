# manifest for configuring icinga
class ovirt_monitoring::icinga()
{
  service { 'icinga':
    ensure    => running,
    hasstatus => true,
    enable    => true,
  }


  Nagios_hostgroup <<|tag == 'monitoring' |>>
  {
    mode => '0644',
  }->
  Nagios_service <<|tag == 'monitoring' |>>
  {
    mode   => '0644',
  }->
  Nagios_host <<| tag == 'monitoring' |>>
  {
    mode   => '0644',
    notify => Service['icinga'],
  }
}
