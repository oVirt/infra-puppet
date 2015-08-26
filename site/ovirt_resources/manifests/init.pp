# Handles a resources machine: http service serving repositories
# with support for mirroring and uploading files
class ovirt_resources(
  $resources_dir='/data/repos',
) {
  class{'ovirt_resources::apache':
    resources_dir => $resources_dir,
  }

  include ovirt_infra::user::system::jenkins
}
