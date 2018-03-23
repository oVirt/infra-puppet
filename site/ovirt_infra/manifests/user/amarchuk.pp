# The user for Anton Marchukov
class ovirt_infra::user::amarchuk($password = undef) {
  ovirt_infra::user {'amarchuk':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC3VJHfmkhOgnu2zAEShdl/zpTJEon94oeWtQd/iNBfuJJOsuXcJEN0QT7s1hEdRNR+jHQ4qaLhtsZYx6pLhjUXiRT5YbY2UyYsGEvLOaa3WpqvxjeOf2rricU1Fcys0Pf2Mvu277oCRlNyfZretf5RcrWGOXlBmM3VRxsz6WB5POtlRhDZCOkqRCRZ/jygQ1A7MWlAfQI7xTQsfXyHIpz/0TT++kRiqQGpZGi0yYEXXmkbkboQlUtVK7g7O9ssQ7B5PFr1yeaf/Vsz/6l/ZgSsIJLFQoQxycMbJbEmIMwAuRol+A/KiHYNFsthaoeivYDJZ4MwsX6IXyz4hEDLKWjT',
    password => $password,
  }
}
