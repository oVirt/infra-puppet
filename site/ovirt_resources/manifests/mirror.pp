# Handles the configuration nessary to support repository mirroring
class ovirt_resources::mirror(
  $mirror_user = 'mirror',
  $resources_dir = '/data/repos',
) {
  $mirror_path       = '/var/www/html/' # This path was announced to the mirrors
  $rsynclog_bin_path = "/home/${mirror_user}/bin"
  $rsynclog_log_path = '/var/log/mirrors'
  $rsynclog          = "${rsynclog_bin_path}/rsynclog"
  $mirrorlist_file   = '/srv/resources/pub/yum-repo/mirrorlist'

  # Till all mirror configs updated to use $resources_dir we need to keep this
  file { $mirror_path:
    ensure => 'link',
    force  => true,
    target => $resources_dir,
  }

  user {$mirror_user:
    ensure     => present,
    managehome => true,
  }

  file {$rsynclog_bin_path:
    ensure  => 'directory',
    recurse => true,
    owner   => $mirror_user,
    group   => $mirror_user,
    mode    => '0775',
  }

  file {$rsynclog_log_path:
    ensure => 'directory',
    owner  => $mirror_user,
    group  => $mirror_user,
    mode   => '0775',
  }

  package {'rsync':
    ensure  => latest,
  }

  file { $rsynclog:
    owner   => $mirror_user,
    group   => $mirror_user,
    mode    => '0775',
    content => template('ovirt_resources/rsynclog.erb'),
  }

  file { $mirrorlist_file:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ovirt_resources/mirrorlist',
  }

  ssh_authorized_key { 'mirror@archive.linux.duke.edu':
    ensure  => present,
    name    => '"Drew Stinnett" <drew.stinnett@duke.edu>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAsISn76QEkZNR35lht/L9IrQfHIEliEcBG2yXONnVBta8ObLaz+eMlz9yPcpuQbUCtzTNKy85zwnTejYnb2tGhM4HY+UqumjVBGNBx7djYxCI3xioRZJCtnjJG7keBH+oH3J/i8MTWhvw/YAl07sKlgCow4i2Wvudb8mvMSXLVSIdZdMcnv3xDsWwGCGghUU4f1AOzqfP/Oe6AAACoACqmSBjwPm8K0S+xa37oHTQNd2nCt7RFnyYr+mrD2tEYBGCvY2tKv2Oy4W1Xfs64AZ6nS7njUYUgvp1VTwk9JJdE10UdMBFmAWOU+zRWjgKNcs9p1xqmEVuzTnKJnW0jW6uYw==',
    options => ["command=\"${rsynclog} duke.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirrors.rit.edu':
    ensure  => present,
    name    => '"Paul Mezzanini" <pfmeec@rit.edu>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAm8+mKHuhgla4A07IRzNScDfq7kv3WXrssDh9VqC3I/eHvlSxNjGrO8dyCIHkqzyuP65SBGbFt2RZ90pXxPAPbudwEbiJD7+jIkB7ilHaY3bQcnsWzEJFclf3Q3O2gRsETa5NGzMYa6yfiIt5AXemcbOxd0gJVYn0Cwsu2vDSlCNHOiDP5FICFpWijVWMTBYZdvwY95WUvFnlAGV/6VqQmG6fsYVel13UFPSJ+kzdC76h65RkWG8l/IQzI0FDXDJbYYT1qKbLVeV/6jrerJmlpUc0PrFHjFYyIoQhVz5IJs8QbFESXMCOVwZ0F9rUPKH6Oc1i/o4og3tBIIKwIon390O6QwY44cRMjQX7GxhfwIcw2eoBF8gv7N3lEpqrKYwSG5wOPCd9juUpgoh+K1G2kJrs5oVFybfjWGUgjLpybY2aAcKYjuKzqqcntmqM/PGXs8FeZWIjc3jXimlWYFJ9ZIUWL4Xcy/Q/d2chGcNlXECWt8vkRBGylV6QNZt813NZUeZZo6oSIZvECO5hJexpUQf+c48g/zx1y4b9ZYu++XfiLJu4jW28zH0rcJ5xJvEUcspiPFi2CKr7a9bzXGCbjpUFesEwWhNevkEvFZoi2jV8bmaYwoJgJ3vhoYPn2isyN35eUNLgp5aH7Vwqyxo/oCsA2lW78p66NNgVY5dfnpU=',
    options => ["command=\"${rsynclog} rit.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'ibiblio.org':
    ensure  => present,
    name    => '"Cristobal Palmer" <cmpalmer@ibiblio.org>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtySjt642Nt8/JI8KxG769XJkMTwE1HUebbYopZPUnFXtzPFpf8wbdr/r0+odu6kix++sRp+mN93MzwuybkmnNCH8c8Y9AIh1zAxNOHBCLSFE+zcxwt61mEtbGLQXW5TuS4GY99ROvJXKuqFSpI0pMaNyyjxMDpvNl9rt8Q/qSWfyPXEu+Q8i21NGlAMIoG4DhWLpsN9kIejWXWrWWkZSZrtTjRUxdIQJsuCPOQbEPIDDIYa0g6dnjxv+AkbYXA+jBJpjTYidf3yKQPcDOiNiFhuIyBvwB8ZC0j1KKc8gKIpv9/naPfV8g31V0VDlwXrbqFRY6Zzg/7pk+BCOnMZ8AQ==',
    options => ["command=\"${rsynclog} ibiblio.org --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'ovirt@sagres':
    ensure  => present,
    name    => '"Carlos Carvalho" <carlos@fisica.ufpr.br>',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC03tEfOdANAs3DAA3C+bMC1/+x7EbhCgDoFpe8J7LTcXB4+Dna3BOaSpgyYTd2THlIa8g4vLfRrOWclaOMCTgljwad2Gr2syb5lhVHzbMDnVfhAK4agqnxhgw+Nq938mSvFRG6oUnWCzNrT9/QdCL8T/4atEZafaLgxvopK44klcIXE3v9KGJOqoQ/e6mV66GChm2XIlEMKHm+s+JdZX//3x3+bomM5KyWR1s+oKnjL2m22xApGkd5TcHAifTvrjUm6ZJQpHXf6GIylhQHTkZuiwrpq+71L1YuAQAGyRtqOJNgLgE3tQac8e8rjYgxgXG26Jg5tIttnVI9K3iJ0onF',
    options => ["command=\"${rsynclog} fisica.ufpr.br --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@jobbot1.ibiblio.org':
    ensure  => present,
    name    => '"Cristobal Palmer" <cmpalmer@ibiblio.org> (2)',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvnwlNzB9DKC7pjqI7yhE8qvzItP9gzVRcS8nUFCF0Yx057zr+LvgI2LBeDmLzJAC2lKpnpWXff3v4UDRTmO/VvQUXoBsDavameYlWcxzbGmEl01Gy87Yk1qLexIK3ixN+3azecm9gkXdAcPQCqKuT1nFa8hBLfR1AcX4WIgk9m4exT+0rd+T/2UqezmFjZwQVJLw/XmV/aIREG5F6HsU1XNPbQElg2oRHrF7H2B6AWBnLSZZFUk+jVeYXt3JAoO0LO2vUTiZ0uJHYQcnzj25z2smT2lFM8PmA5hr6ck2XrZijMSx4KUv/lzPcbGUbBKN9s1No7mRVOd3NAdgDb2oYItu8+BnZH+U6X4/BSIqF5oJWAKFB4smSXru6AKAERu20bPyA6avHwnBLbyotuTwJLgpzTLIQ8Rg4UjvADAy+j5B7DhtEtqtOSbZ77JNGGFiB4OBpRfLEtIXualI890ljLHPIDJtKu0C3HJJrr4jWaHR56TzOLsojUHF3eNh8MjyFBClPv/rPmSV9hro7UjriRGW5ICFMi50J0wIBGYPnL6H0TIlmz0Pvpz77AObu74r/8EvVg636VtrzV8sNLxcOq4MkRPXXi2xCMxmEB+D4WF1jTogPZpvOfXZqBpACr0C2qDSjNyHBAesp2zkL2JF3yf3BPgWDzpuHhMtbSPrnb8=',
    options => ["command=\"${rsynclog} ibiblio.org --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'oit.gatech.edu':
    ensure  => present,
    name    => '"Neil Bright" <neil.bright@oit.gatech.edu>',
    key     => 'AAAAB3NzaC1kc3MAAACBAOuv943GhG5UdTTsWNCRiIakrJ9cyQzQd13foTt8UzR28J6SDFH9Y93E41w/rQy4KisofQ0fa+sjBeiVafSW2pOOVg0NZ+PDipcKKe/k1YpEIYF+OCB/zuLgxe84Im6Mm150T+VeT2QsVV+kp8kMp7Za6DNt9aJtRk5QrlOBy4/dAAAAFQD7YUXrMyXpKNEYIEQYY8vL/eEYzQAAAIALs61b45SwS5hWPpboL0B8DOFQRSgSnmVixhzdoCdYzhen2p9nMEOe6CRauJSa5urIqk11mGorAQatKrPBy+iB0WjzOn5hzTQBfq6Z4SqPsx1IlRHzXVpHrxkGLLTHvMxByKyUuZcLCxndv41tULtsMUvT8jzUpYuSyEwVNFCSEAAAAIEAys0/xfB7wbbo/LDZRDZN0HXhXiSAjtNeH8l/5ybVlzkPxRNkaZ2BC4wwTIiAhX0xP9iwXbvAIKAiv1QhN0IlJMzjz71p7VtZdI/q29lpXW4h31uGoGRvNvd8n1iSZLP1xMnsqcBKWjL0HTonRQ6DJkVFf9l+GSHdciNUHkpa52A=',
    options => ["command=\"${rsynclog} oit.gatech.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-dss',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'maarten@vlaai':
    ensure  => present,
    name    => '"Maarten Aertsen" <maarten@snt.utwente.nl> - ftpcom@snt.utwente.nl',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDcEujUQ3DLIGiuOCg0ZlLqZhQY/uHFw2O9cMY6SrlG11tZ0oiwk6+x8dZsBN0kAN7zd1IIOo4+E0cMYUrkiwj6dzVc/oKY9RtTCOKhmqq1tnPxKSpOXY+CZxm7e63uVx8CpVjhj/lOMnfL3jzyBbNfURsSgY+6edSkDGzy3ptaXBDlrVI4F5+2rjKI3VgflshjUUZo1Di22snnZ5zoB8tT/Q8MBMjnMtQcPqjPL/VgfbgKwFfgLOnZtXzTnAjMK14IA5XLN9PCrPtEajRM8mtesqkYSMoZ1KqKPGwZspIijKrnoYNeKjkZxZAq9xijboj4GboHxsKRxckaw686qrfpPdPHNrgtKZZNxO5RB+/tgNLBM1l0g/9rEAN2Pvytg2Ifahk20oEodCzW1qsCBWl6+4NwV8iW87rgN+AgibNg/QmEd2SKNHAhOldEPFpHQqDRHo6ZJY5XbOEepK/ti3UOzV/mQ4u1PnKpZBoqWmM9MWBOEMZP7Ems4DHR5vdAvYs8TrzgTasoOe/MkFZ9FZ31XRL4loyPU9gid06ENA+Yc9xyRssUtjNsQfCNV+enSzbMBr4FvWmSoJNoVbQyi3tj13emflBqP+rROpeG7mgol+aP49z3RW56wOS0dhFqg8AXRyp1QLld/rJXzb3UH5l7WTXhX7DCuySezxhEyi1lGw==',
    options => ["command=\"${rsynclog} snt.utwente.nl --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@cbr-a-hvd.cdn.aarnet.edu.au':
    ensure  => present,
    name    => '"Alex Dodsom <alex.dodson@aarnet.edu.au> - AARNet Pty Ltd (Australia)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEArzGSTAdAW1VbDiZv5N5l8HBFusj0KZ1T3m5U68H9vI3BgZDUGozR5jhyCPl7xnwFSADm9BH5MGNIYiJir+ZU1a9Bt26J/mD1kdoD7NDEKebukuQ8276RJKDMHQbHiC7pvP4TaZ6ERckrFid5ddDsqf6HrY/PIbJWBaRlIwE7b28eug6jmwrNq+W+5tmIit8QtOEKc6Mtnb7xEacX6Ziwd112bSpd7kCb4joiQys7/MmyzMhI6hAZFpycSM+QFU1IlR8EbXSt1Y8Zf7k3bk4SmJQbkIJJI/pILHa8jmol9eL8+d8KlW2oussJrYEkLzeJg50t2CDVWM6+jc6AGYtglQ==',
    options => ["command=\"${rsynclog} aarnet.edu.au --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'Ovirt key pair NLUUG':
    ensure  => present,
    name    => '"Mike Hulsman <ftpmirror-beheer@nluug.nl> - NLUUG (Netherlands)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAzBB3SdSByC0NvfGbKeIsQJitInN0igWOqomM7dArLLjfHpR/sdSMWrM9IUWfVzCrv36/wxi/4/cb1BtR+uSjatIIH/s0n6JyunJYio+fNLax7QnfxwJ0pME7q6rYLXklRbFaNJk6IomkkdxvAOx1CL82jZc09TbWFwUGbz9L/dDVjFgUhzLpJtnFk955lqpc5uSik1xSnF2Z4d7i11kryKER2zz+1G1bUdtm7gOe16+CLPUXDLV+72uxPpwAMrb5KEeGRCWgl/tdyrGv3ooTS8EQDUZWJEgi0xwi16Cscl+sDYois41oqij84932L3alCg1HugLu8feBVwp3X0ZZUw==',
    options => ["command=\"${rsynclog} nluug.nl --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'root@dev-19.rhev.lab.eng.brq.redhat.com':
    ensure  => present,
    name    => '"Barak Korren <bkorren@redhat.com> - RedHat internal mirror"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAvrvqQaqwT6cgBSs1skVO57R5eQ5x+GF/4eNoLSfHrYkh1R96BsMB7k/s0EQmXCbA99x/q0goQxHzCp4DZZ34gnCmN4GHhCIqc6gezD5AHNtszDn7lFrE802guOykRXM2DYCBwFQTXoI2RO3Faz4T555r9NUwNphEgXE+FYEvwG9NxtKeHt3lbymOn/SjlgsK/gEyzN2t17lQusKzp9cXo/xDfSL48eFGurM5GssVgpwKRYKDnrypknrATRFGOoHsUg0LbqK+vFgbeZzI2oe56YGrmkKly6ZnFd9ejQPrsmNlKkzoJNcQVCmZqDCKIPcNxcYh6niJUXpYSlgHNzLOEQ==',
    options => ["command=\"${rsynclog} redhat.tlv --server --sender -vzrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'tecnosfera.com':
    ensure  => present,
    name    => '"Pedro Aleluia <pedro.aleluia@tecnosfera.com> - Eyeplug (Portugal)"',
    key     => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIx4LK96J6JrMu12F9HXlOV+/eLOfXdm+WH5WbSryXdtDsyMlUf/MUpBy5rUoiTOYhi/A0J7MuKnuIo6LoLnN6E=',
    options => ["command=\"${rsynclog} eyeplug.com --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ecdsa-sha2-nistp256',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'hbxfwjww@gmail.com':
    ensure  => present,
    name    => '"<hbxfwjww@gmail.com> - internal for he\'s lan"',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCq7P0UMU+uEqvyH1NlQKncbTyIpRzxcG2ELf7p10uI7YQTKiE8mpWz+MJrjByj9sB0GpYrhJ+U8aPwFuYqxI2dhMQMA0A5mWHO2NDszds+5mmkmsN0DAHloGftGf4hpTk0fRI/z3MYxxSMDeFwGCmNxSFs5oeFYcR945nuiADtNBiXPOO0aKQZ3/YHUQUH1IzrmxH6LW0ud13ZbumS5mMKC2CBubQ8Isnye7Q/H6u2yMrTN0nCHtxrE6xCcM3cFICX2Oe2nyCk1npuDmIEKmHnRGKEMYFewuTpa9B9BrvqANa5sWPduP8h2MmJUAhqIVhzkr8/iT5vyP+6yiBxDXVN',
    options => ["command=\"${rsynclog} hbxfwjwwATgmail.com --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@mirror.slu.cz':
    ensure  => present,
    name    => '"Jiri Slezka <jiri.slezka@slu.cz> - Slezska univerzita v Opave (Czech Republic)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAukrWv656+P15nZc4hOLNaxngvV6s/PKWfajQ9kT4zfB8/YAeO/nr9al5zOvcYYIA/JFtSGRPU8BHTp+9I1CTN71x7r2+I75B0ar5bZ0upnX8tSJy6Nf5hYsgNp9V/U/qrBMRsXpiTmlNX0G5GusW8cercAk2IU882tdZ4nWej1CUqjEx3uujifw8ddO18bylaACQ4c90sXcT/cyormsoYDmcqOJAnh95O41HtXYZZzCuxOmaJgYcKxqCaB7PQV7L/EUrqiqvIr71CcJ/l11HglXDpmXVYepGgZS4rIPQ5TDzR/otUEXHHB+eRps8nIiwaWMmEni6yscpu1tBRronBw==',
    options => ["command=\"${rsynclog} slu.cz --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'jsiml@plusline.net':
    ensure  => present,
    name    => 'Jan Siml <jsiml@plusline.net> - Plus.line (Germany)',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAxchnpLrvkMvK8OecW/myX8gug/Q38qXf8jjy+KO54ecO1493gFniEmGd/d5AC1zIRwPAVOkE0nTKQPObaPn6Alu3TugtP2j1pOhOt9e4TttD4cMcBgbOMuNLkrHrAvixQy4Nr4vKGboHZ6gvHU5mWpuFzJMC1Rm9jJ4jPfq59ZEBbIrTPmh6veuOw2wN3pH3V6HOLobLRw6MrEiRsUNJOqo0IrSgrc7xinaqaBexy68uIhYfov5zxAXeFvAurQg5BduK+izgYV+uHieS2kDdf9j6/7zRXMIfXXzEoarG0aCovYpmMtPNPiy3XeJwlFtjJPEurbKNbmZkl0/EItfQKl/TNpVeQ8y3u/qwvN8UsgQloaNDBYzZ67j1XRQ861RmqKxuV12rqugv+53wTPBP1KAvQkj52Wk39ZZPvLYFwPUaNKC8aPaj/MX8v4tnLQZhiFgg/Og7HuMOVStlh3lr5T+g/+hRSBqBxdbi+IyvtcEKxmtzkfJ2k0yQVBa2TELWxseJQOkQhJA6UDHjUbAczv/lpxWm+8ld5XnqXQ4iQZro6ewLC1+WGGcrSqIBDC9Xo2WFxsg2ac51Yc41HxwLNt4iVWifz2UsbHiV/6lfSTL0OaF1+BEqw5culpBAeBnx0lYBnAj+JzasBF45WFoCmU4mMa5mk5xdWuuDxHCEyXs=',
    options => ["command=\"${rsynclog} plusline.net --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }


  ssh_authorized_key { 'kaplanlior@gmail.com':
    ensure  => present,
    name    => 'Mirror http://mirror.isoc.org.il/ - kaplanlior@gmail.com',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDO1w2Hq1Kls2NhNfmv09SwD6bYbpaEaywoqqafQ/37g9K6iT0jtuS3BhnSSV8p5oWC+7VWmf64jD0+n2bKsMaBY2XK77RbWwsErmHqAEzaY4/coMPTmoIMV67Y34tVgzAgbqV6XUQpnrsFbla6N8DNYoE6LPHprF3/rP66UJOuyYC/gd3Zyx5r7TQQLoReC0NYjCmq0bjc6hLfV9cyslkFGJXZGTIZrCFenuAsa/XXdN7NKGoSwh+47sSEKhR5qR7mtgXh4e7Pxo1OoQQ/gF9QzJT+8esxGntTRBP5by5amPt2w7WFNUE2daLkUUWAtrfOMPXwEwsM7WHdNpaFbRmp',
    options => ["command=\"${rsynclog} mirror.isoc.org.il --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'network@nfrance.com':
    ensure  => present,
    name    => 'Mirror http://ovirt.repo.nfrance.com/ - network@nfrance.com',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCxDuAJ0utqeqWqsq2zGJ4Ay87xDnmAZlMLQ7K/LvJXQAX/lh0w6lMUlLScR0FFWBa3guysU9vqfpxPIqnbdJJbEpnWrliEyVezd5CusdYCWI5GuVJHRmXI4yO3UnoYuiQ7Av6GO1jtncNUZtBbDmPG8eWccEPg0x9OO5c3GDaxqqtu7WeTB7BfO8W8KygsvqDffZ7ryBWeftQgykHejju9Mao51de1Q0U5ksYqjahusoEpLuG5dSEIS0LziM38lCukBGvtFopMMItKjuAOwqf4XSwp/f2e6u71geBzWRLMugpZtEnQRUgqwXti/fx9485ipp+EnSN1/hkXiIKHrEGL',
    options => ["command=\"${rsynclog} ovirt.repo.nfrance.com --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirroradmin@rackspace.com':
    ensure  => present,
    name    => 'Mirror http://mirror.rackspace.com/ovirt/ - mirroradmin@rackspace.com',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQDWcQoDeK5Y4yQRRgEnMr68qv6HN0plTP3L5uCpDH8Ji0UdyUU85MT6VjaAwePq4tMW9EjP/I2BK7L6qVhWrvh76SKfnNYBwWntQ5cr3hhWTkAPwkKe6ceOqmO6F2EBiCSnXBSGM2gLaFEoZoExtRwQL3ID+VSF/oOaDuqBaZg9kvMWv2+G+AGItY7OTvoycPHqFNdqdGIUEOEIjAyTLo8F3UWmYyGeR/JNYpPJYlWMBEPUbpv6M/KU2HMT9H21yM//fAgqxgG5PsrHwTjhRbecbhG0YDHjWsRx2S6Z1+Rii6xM1ikD9NZGHTqK0e7US20iN6eZhmamUkw1og2/WBC7xDAoET5s8E3IMUw+SVGVv89JCVijqZHO6K+qGIa1JGUPV+5jD0XwBrzfjPBEqw4y6bh2cxrx5C0HvSpr1poyQQXE62l4w7WD9UoTSnAEnNk7P3ttkVbPpy37eIVKBAu4Rgq1+DBsR2b8+BpBpzHWyoe2wL1m3NThFZENeBvboxE=',
    options => ["command=\"${rsynclog} mirror.rackspace.com --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'zhao_jda@massclouds.com':
    ensure  => present,
    name    => 'Mirror http://mirror.massclouds.com/ovirt/ - zhao_jda@massclouds.com',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ6qvjWVmrVbzJXbZ8+mSHfFZB30IFQRNNtJh7Sa2MUxez6YKgrG2+5QuEN/5tuCOPj1U88z4xP6xgPk/hNV/UyNVAj45LmvHxbTE+OR1GgIXJVAXE61QhYFRPPcuvZ9YOpYq3wWzPcG24X3H48TpEKgLf2Ve8AWnMVE85EeuuOX1wBhRKpANAZR85GtOv3888WQaCEbiPcJN9MO9g+PXGJ00R9u8p7FJoNF6ea1GDyxdBDUuvdhjcCfNfxxZgDJEWrECUjaD0nsSFIS/EnEUH+/BaiYk4UbJP+Vlrk8IoD7iQ8n+rryI7WJHTNL+DiTsjVG4e8hB7G7v1PGbfDz9B',
    options => ["command=\"${rsynclog} mirror.massclouds.com --server --sender -vrltH . ${mirror_path}pub/\"",
                'no-port-forwarding',
                'no-X11-forwarding',
                'no-agent-forwarding',
                'no-pty'],
    type    => 'ssh-rsa'.
    user    => $mirror_user,
  }

}
