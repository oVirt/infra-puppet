# The user for Michael Scherer
class ovirt_infra::user::misc($password = undef) {
  ovirt_infra::user {'misc':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCcn358haGHznlVENXrWDdr25+aWUrDj+15fkg/7UhnrqBI3VvTC8tjr8RiuxY8CPJsvT6LMdmG/D/uXov3uErnWT0gyXSVj7C9giOWWev0KTODco/xhTQ53nK1qLajLN49qCJT+8w21PTXUGIRO6Hubx1U3CYlH1xvuV3xtyn9jCigM5HxWCb7y4JkSM8vaJU+RedTieyxdH0e+Gstbilu0gsKwSm9LJm4MoGf/6T+IkuTvSuDngUFKkVIb0+65s6a6hh4Wam5HYqG4MKkdFrrqbV+D+D6y8UugQ9byud59UDodPSALYXe9YJYfgj5X/6yJSKJk2MPBTS5OGyu5OCX',
    password => $password,
  }
}
