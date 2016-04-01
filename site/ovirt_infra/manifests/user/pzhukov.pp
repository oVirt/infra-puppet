# The user for Pavel Zhukov
class ovirt_infra::user::pzhukov($password = undef) {
  ovirt_infra::user { 'pzhukov':
    key      => 'AAAAB3NzaC1kc3MAAACBAMebx93t5MedSKNju67yHFyg6Ih8MvVERjktPQz2Sx4xBZHqSC3O9+T+va6LyBENRO+49k5BDbRnXMh8dpRQJTtIGoA5Egp2P1E0k7t9+7YwTujw7F7RyCXuZN/nSJsMXtGNGzlNADDiFcknn297rOUjJtSSxtDkdrrzHeGJJ5MjAAAAFQDZ/BVtDxD6POoKr8qgh53PKkOw/QAAAIBpU/hsN7YrwVEuiJTUhSPthfx9CrXKegziUEA+QAr8vVlM/lkmGat4qqbu7VExmsj+l4or3qXkxAONdKYqi/WFUOzpoEmtmEax8R4Z6uvxCGEBrkWD5uKf4NARcbpYYISho791TFvN16p1BHYf2mmrvg9u9vl6GtuP9+0g4FPdMAAAAIEAsNTDtNd5N/ExcOlhHOFgRSByliFfU6IAZvHIpHocPcoM/OJqxE2wbIuhHn5PlCmZh9Bj8qpFxx1RGbkvuyQC+hHEbOfs05u/qwKi+gV4Tb8R+j4OoJVqoNqwdbUm3Zp3h4PcKJ1Lv+sL6aYnBch1WHfVgYahqnAxNhdLtOr2yB0',
    password => $password,
  }
}
