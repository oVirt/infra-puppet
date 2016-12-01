#!/bin/bash -e
REPO_PATH="/srv/resources/repos/ovirt/experimental"
read version

wrong_version() {
    local test_repo
    echo "Wrong version supplied, available versions under testing are:"
    for test_repo in $(find "$REPO_PATH" -maxdepth 2 -type d -name latest -print); do
        test_repo="${test_repo%/*}"
        echo "${test_repo##*/}"
    done
}


latest_path="${REPO_PATH}/${version}/latest"
if \
    [[ "${version}" == "" ]] \
    || ! [[ -d "$latest_path" ]];
then
    wrong_version
    exit 1
fi

latest_path="$(realpath "${REPO_PATH}/${version}/latest")"
if ! [[ "$latest_path" =~ ^$REPO_PATH ]]; then
    wrong_version
    exit 1
fi

test_repo="${latest_path}.under_testing"
echo "Creating a temporary testing repo for version $version at $test_repo"
rm -rf "${test_repo?}"
cp -la "$latest_path" "$test_repo"
repoman "$test_repo" \
    --verbose \
    --option "main.allowed_repo_paths=$REPO_PATH" \
    createrepo
exit 0
