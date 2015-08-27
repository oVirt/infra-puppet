# Handles the configuration nessary to support repository mirroring
class ovirt_resources::mirror(
  $mirror_user = 'mirror',
  $resources_dir = '/data/repos',
) {
  $mirror_path       = '/var/www/html/' # This path was announced to the mirrors
  $rsynclog_bin_path = "/home/${mirror_user}/bin"
  $rsynclog_log_path = '/var/log/mirrors'
  $rsynclog          = "${rsynclog_bin_path}/rsynclog"
  $common_ssh_opts   = ['no-port-forwarding',
                        'no-X11-forwarding',
                        'no-agent-forwarding',
                        'no-pty']

  # Till all mirror configs updated to use $resources_dir we need to keep this
  file { $mirror_path:
    ensure => 'link',
    force  => true,
    target => $resources_dir,
  }

  user {$mirror_user:
    ensure         => present,
    home           => "/home/${mirror_user}", # purge_ssh_keys needs this
    managehome     => true,
    purge_ssh_keys => true,
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

  ssh_authorized_key { 'mirror@archive.linux.duke.edu':
    ensure  => present,
    name    => '"Drew Stinnett" <drew.stinnett@duke.edu>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAsISn76QEkZNR35lht/L9IrQfHIEliEcBG2yXONnVBta8ObLaz+eMlz9yPcpuQbUCtzTNKy85zwnTejYnb2tGhM4HY+UqumjVBGNBx7djYxCI3xioRZJCtnjJG7keBH+oH3J/i8MTWhvw/YAl07sKlgCow4i2Wvudb8mvMSXLVSIdZdMcnv3xDsWwGCGghUU4f1AOzqfP/Oe6AAACoACqmSBjwPm8K0S+xa37oHTQNd2nCt7RFnyYr+mrD2tEYBGCvY2tKv2Oy4W1Xfs64AZ6nS7njUYUgvp1VTwk9JJdE10UdMBFmAWOU+zRWjgKNcs9p1xqmEVuzTnKJnW0jW6uYw==',
    options => ["command=\"${rsynclog} duke.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirrors.rit.edu':
    ensure  => present,
    name    => '"Paul Mezzanini" <pfmeec@rit.edu>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAm8+mKHuhgla4A07IRzNScDfq7kv3WXrssDh9VqC3I/eHvlSxNjGrO8dyCIHkqzyuP65SBGbFt2RZ90pXxPAPbudwEbiJD7+jIkB7ilHaY3bQcnsWzEJFclf3Q3O2gRsETa5NGzMYa6yfiIt5AXemcbOxd0gJVYn0Cwsu2vDSlCNHOiDP5FICFpWijVWMTBYZdvwY95WUvFnlAGV/6VqQmG6fsYVel13UFPSJ+kzdC76h65RkWG8l/IQzI0FDXDJbYYT1qKbLVeV/6jrerJmlpUc0PrFHjFYyIoQhVz5IJs8QbFESXMCOVwZ0F9rUPKH6Oc1i/o4og3tBIIKwIon390O6QwY44cRMjQX7GxhfwIcw2eoBF8gv7N3lEpqrKYwSG5wOPCd9juUpgoh+K1G2kJrs5oVFybfjWGUgjLpybY2aAcKYjuKzqqcntmqM/PGXs8FeZWIjc3jXimlWYFJ9ZIUWL4Xcy/Q/d2chGcNlXECWt8vkRBGylV6QNZt813NZUeZZo6oSIZvECO5hJexpUQf+c48g/zx1y4b9ZYu++XfiLJu4jW28zH0rcJ5xJvEUcspiPFi2CKr7a9bzXGCbjpUFesEwWhNevkEvFZoi2jV8bmaYwoJgJ3vhoYPn2isyN35eUNLgp5aH7Vwqyxo/oCsA2lW78p66NNgVY5dfnpU=',
    options => ["command=\"${rsynclog} rit.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'ibiblio.org':
    ensure  => present,
    name    => '"Cristobal Palmer" <cmpalmer@ibiblio.org>',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtySjt642Nt8/JI8KxG769XJkMTwE1HUebbYopZPUnFXtzPFpf8wbdr/r0+odu6kix++sRp+mN93MzwuybkmnNCH8c8Y9AIh1zAxNOHBCLSFE+zcxwt61mEtbGLQXW5TuS4GY99ROvJXKuqFSpI0pMaNyyjxMDpvNl9rt8Q/qSWfyPXEu+Q8i21NGlAMIoG4DhWLpsN9kIejWXWrWWkZSZrtTjRUxdIQJsuCPOQbEPIDDIYa0g6dnjxv+AkbYXA+jBJpjTYidf3yKQPcDOiNiFhuIyBvwB8ZC0j1KKc8gKIpv9/naPfV8g31V0VDlwXrbqFRY6Zzg/7pk+BCOnMZ8AQ==',
    options => ["command=\"${rsynclog} ibiblio.org --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'ovirt@sagres':
    ensure  => present,
    name    => '"Carlos Carvalho" <carlos@fisica.ufpr.br>',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC03tEfOdANAs3DAA3C+bMC1/+x7EbhCgDoFpe8J7LTcXB4+Dna3BOaSpgyYTd2THlIa8g4vLfRrOWclaOMCTgljwad2Gr2syb5lhVHzbMDnVfhAK4agqnxhgw+Nq938mSvFRG6oUnWCzNrT9/QdCL8T/4atEZafaLgxvopK44klcIXE3v9KGJOqoQ/e6mV66GChm2XIlEMKHm+s+JdZX//3x3+bomM5KyWR1s+oKnjL2m22xApGkd5TcHAifTvrjUm6ZJQpHXf6GIylhQHTkZuiwrpq+71L1YuAQAGyRtqOJNgLgE3tQac8e8rjYgxgXG26Jg5tIttnVI9K3iJ0onF',
    options => ["command=\"${rsynclog} fisica.ufpr.br --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@jobbot1.ibiblio.org':
    ensure  => present,
    name    => '"Cristobal Palmer" <cmpalmer@ibiblio.org> (2)',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvnwlNzB9DKC7pjqI7yhE8qvzItP9gzVRcS8nUFCF0Yx057zr+LvgI2LBeDmLzJAC2lKpnpWXff3v4UDRTmO/VvQUXoBsDavameYlWcxzbGmEl01Gy87Yk1qLexIK3ixN+3azecm9gkXdAcPQCqKuT1nFa8hBLfR1AcX4WIgk9m4exT+0rd+T/2UqezmFjZwQVJLw/XmV/aIREG5F6HsU1XNPbQElg2oRHrF7H2B6AWBnLSZZFUk+jVeYXt3JAoO0LO2vUTiZ0uJHYQcnzj25z2smT2lFM8PmA5hr6ck2XrZijMSx4KUv/lzPcbGUbBKN9s1No7mRVOd3NAdgDb2oYItu8+BnZH+U6X4/BSIqF5oJWAKFB4smSXru6AKAERu20bPyA6avHwnBLbyotuTwJLgpzTLIQ8Rg4UjvADAy+j5B7DhtEtqtOSbZ77JNGGFiB4OBpRfLEtIXualI890ljLHPIDJtKu0C3HJJrr4jWaHR56TzOLsojUHF3eNh8MjyFBClPv/rPmSV9hro7UjriRGW5ICFMi50J0wIBGYPnL6H0TIlmz0Pvpz77AObu74r/8EvVg636VtrzV8sNLxcOq4MkRPXXi2xCMxmEB+D4WF1jTogPZpvOfXZqBpACr0C2qDSjNyHBAesp2zkL2JF3yf3BPgWDzpuHhMtbSPrnb8=',
    options => ["command=\"${rsynclog} ibiblio.org --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'oit.gatech.edu':
    ensure  => present,
    name    => '"Neil Bright" <neil.bright@oit.gatech.edu>',
    key     => 'AAAAB3NzaC1kc3MAAACBAOuv943GhG5UdTTsWNCRiIakrJ9cyQzQd13foTt8UzR28J6SDFH9Y93E41w/rQy4KisofQ0fa+sjBeiVafSW2pOOVg0NZ+PDipcKKe/k1YpEIYF+OCB/zuLgxe84Im6Mm150T+VeT2QsVV+kp8kMp7Za6DNt9aJtRk5QrlOBy4/dAAAAFQD7YUXrMyXpKNEYIEQYY8vL/eEYzQAAAIALs61b45SwS5hWPpboL0B8DOFQRSgSnmVixhzdoCdYzhen2p9nMEOe6CRauJSa5urIqk11mGorAQatKrPBy+iB0WjzOn5hzTQBfq6Z4SqPsx1IlRHzXVpHrxkGLLTHvMxByKyUuZcLCxndv41tULtsMUvT8jzUpYuSyEwVNFCSEAAAAIEAys0/xfB7wbbo/LDZRDZN0HXhXiSAjtNeH8l/5ybVlzkPxRNkaZ2BC4wwTIiAhX0xP9iwXbvAIKAiv1QhN0IlJMzjz71p7VtZdI/q29lpXW4h31uGoGRvNvd8n1iSZLP1xMnsqcBKWjL0HTonRQ6DJkVFf9l+GSHdciNUHkpa52A=',
    options => ["command=\"${rsynclog} oit.gatech.edu --server --sender --include=releases/ --include=pub/ --include=releases/** --include=pub/** --exclude=* -vrzltH . ${mirror_path}\""]
                + $common_ssh_opts,
    type    => 'ssh-dss',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'maarten@vlaai':
    ensure  => present,
    name    => '"Maarten Aertsen" <maarten@snt.utwente.nl> - ftpcom@snt.utwente.nl',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDerIFETYL1uFrRjCVyy61LgQOM2GWH2xPrRIeoUe7ekgFgCo2qjlkBtELmi+2kNGqC7rcXRcQTffIfG/4LLbqcS+7GAdBjqjzkX29xkCwfxIu0B0R3XNt0UUh+C7E22e3GSmI6/C2myBfaNpbdKDuk79SDQl/OOKVpPhe88peLUc0rXcRD93vi9aphDcEhgliH3ykAqi8VubZjPZXDETDY+QCKYcFEXibh68UBkLhHb5jYxGH3qd4dPBRBLAB/hCF9B/f1fFHmDpqtFYMTQUFqwco/OIGJf68v0DWGLFJ9ABAZRCxEa3zTX3rcz2YztTwdTKvJ46GZsEcSBUv54PUL',
    options => ["command=\"${rsynclog} snt.utwente.nl --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@cbr-a-hvd.cdn.aarnet.edu.au':
    ensure  => present,
    name    => '"Alex Dodsom <alex.dodson@aarnet.edu.au> - AARNet Pty Ltd (Australia)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEArzGSTAdAW1VbDiZv5N5l8HBFusj0KZ1T3m5U68H9vI3BgZDUGozR5jhyCPl7xnwFSADm9BH5MGNIYiJir+ZU1a9Bt26J/mD1kdoD7NDEKebukuQ8276RJKDMHQbHiC7pvP4TaZ6ERckrFid5ddDsqf6HrY/PIbJWBaRlIwE7b28eug6jmwrNq+W+5tmIit8QtOEKc6Mtnb7xEacX6Ziwd112bSpd7kCb4joiQys7/MmyzMhI6hAZFpycSM+QFU1IlR8EbXSt1Y8Zf7k3bk4SmJQbkIJJI/pILHa8jmol9eL8+d8KlW2oussJrYEkLzeJg50t2CDVWM6+jc6AGYtglQ==',
    options => ["command=\"${rsynclog} aarnet.edu.au --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'Ovirt key pair NLUUG':
    ensure  => present,
    name    => '"Mike Hulsman <ftpmirror-beheer@nluug.nl> - NLUUG (Netherlands)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAzBB3SdSByC0NvfGbKeIsQJitInN0igWOqomM7dArLLjfHpR/sdSMWrM9IUWfVzCrv36/wxi/4/cb1BtR+uSjatIIH/s0n6JyunJYio+fNLax7QnfxwJ0pME7q6rYLXklRbFaNJk6IomkkdxvAOx1CL82jZc09TbWFwUGbz9L/dDVjFgUhzLpJtnFk955lqpc5uSik1xSnF2Z4d7i11kryKER2zz+1G1bUdtm7gOe16+CLPUXDLV+72uxPpwAMrb5KEeGRCWgl/tdyrGv3ooTS8EQDUZWJEgi0xwi16Cscl+sDYois41oqij84932L3alCg1HugLu8feBVwp3X0ZZUw==',
    options => ["command=\"${rsynclog} nluug.nl --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'root@dev-19.rhev.lab.eng.brq.redhat.com':
    ensure  => present,
    name    => '"David Caro <dcaroest@redhat.com> - RedHat internal mirror"',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCve0SRK1qh+BD5Xv8fozC1puqPoqKNHGS6L3GWH+oBKFpU98c/ZJjIXZU8iZunE81fDQww9fDOZF6Vrv+YqiWoyqcf1AakG4a3iDWw5OAaGW5ZDQRytR7Uux7uRh8B+/c1+rzwWkWHxqyHvTvBoL3P+aXJswcUQDP+YP3LRlzlLMZ0x7Ti9pxOW5e5neBHkdsPBbIEVab67rskd2Rdes3ZTUcdPzMDoTS4E5SQZ31r4kr+zfLYAfzhl9QGND64mUaLheT3HWyoTwikVHo65EuVNGu+3XGx3ITlNJgbIZKqmLTOvCHm7KfTccVGRBfvF36nd64BLyiLl+F5QWJCDGr3',
    options => ["command=\"${rsynclog} redhat.tlv --server --sender -vzrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'tecnosfera.com':
    ensure  => present,
    name    => '"Pedro Aleluia <pedro.aleluia@tecnosfera.com> - Eyeplug (Portugal)"',
    key     => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIx4LK96J6JrMu12F9HXlOV+/eLOfXdm+WH5WbSryXdtDsyMlUf/MUpBy5rUoiTOYhi/A0J7MuKnuIo6LoLnN6E=',
    options => ["command=\"${rsynclog} eyeplug.com --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ecdsa-sha2-nistp256',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'hbxfwjww@gmail.com':
    ensure  => present,
    name    => '"<hbxfwjww@gmail.com> - internal for he\'s lan"',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCq7P0UMU+uEqvyH1NlQKncbTyIpRzxcG2ELf7p10uI7YQTKiE8mpWz+MJrjByj9sB0GpYrhJ+U8aPwFuYqxI2dhMQMA0A5mWHO2NDszds+5mmkmsN0DAHloGftGf4hpTk0fRI/z3MYxxSMDeFwGCmNxSFs5oeFYcR945nuiADtNBiXPOO0aKQZ3/YHUQUH1IzrmxH6LW0ud13ZbumS5mMKC2CBubQ8Isnye7Q/H6u2yMrTN0nCHtxrE6xCcM3cFICX2Oe2nyCk1npuDmIEKmHnRGKEMYFewuTpa9B9BrvqANa5sWPduP8h2MmJUAhqIVhzkr8/iT5vyP+6yiBxDXVN',
    options => ["command=\"${rsynclog} hbxfwjwwATgmail.com --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

  ssh_authorized_key { 'mirror@mirror.slu.cz':
    ensure  => present,
    name    => '"Jiri Slezka <jiri.slezka@slu.cz> - Slezska univerzita v Opave (Czech Republic)"',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAukrWv656+P15nZc4hOLNaxngvV6s/PKWfajQ9kT4zfB8/YAeO/nr9al5zOvcYYIA/JFtSGRPU8BHTp+9I1CTN71x7r2+I75B0ar5bZ0upnX8tSJy6Nf5hYsgNp9V/U/qrBMRsXpiTmlNX0G5GusW8cercAk2IU882tdZ4nWej1CUqjEx3uujifw8ddO18bylaACQ4c90sXcT/cyormsoYDmcqOJAnh95O41HtXYZZzCuxOmaJgYcKxqCaB7PQV7L/EUrqiqvIr71CcJ/l11HglXDpmXVYepGgZS4rIPQ5TDzR/otUEXHHB+eRps8nIiwaWMmEni6yscpu1tBRronBw==',
    options => ["command=\"${rsynclog} slu.cz --server --sender -vrltH . ${mirror_path}pub/\""]
                + $common_ssh_opts,
    type    => 'ssh-rsa',
    user    => $mirror_user,
  }

}
