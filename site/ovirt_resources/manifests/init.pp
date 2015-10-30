# Handles a resources machine: http service serving repositories
# with support for mirroring and uploading files
class ovirt_resources(
  $resources_block_dev = '/dev/vdb',
  $resources_dir       = '/srv/resources',
  $mirror_user         = 'mirror',
  $server_alias        = 'resources.ovirt.org',
) {

  file { $resources_dir:
    ensure  => directory,
  }

  mount { $resources_dir:
    ensure  => mounted,
    atboot  => true,
    device  => $resources_block_dev,
    fstype  => 'ext4',
    options => 'defaults,noatime',
    require => File[$resources_dir],
  }

  class { 'selinux':
    mode => 'permissive'
  }

  class{'ovirt_resources::apache':
    resources_dir => $resources_dir,
    server_alias  => $server_alias,
  }

  include ovirt_infra::user::system::jenkins

  class{'ovirt_resources::mirror':
    mirror_user   => $mirror_user,
    resources_dir => $resources_dir,
  }
}
