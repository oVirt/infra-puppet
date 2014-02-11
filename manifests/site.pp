Exec {
  path => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
}

## Make sure the repos are setted up before the packages
Yumrepo <| |> -> Package <| |>
