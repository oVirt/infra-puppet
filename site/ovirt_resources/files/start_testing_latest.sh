#!/bin/bash -e

MAX_LOCK_ATTEMPTS=120
LOCK_WAIT_INTERVAL=5
LOCK_PATH=$HOME/experimental_repo.lock

wait_for_lock() {
    for ((i = 0; i < $MAX_LOCK_ATTEMPTS; i++)); do
        if (set -o noclobber; > $LOCK_PATH) 2> /dev/null; then
            trap "rm -f '$LOCK_PATH'" EXIT
            return
        fi
        sleep $LOCK_WAIT_INTERVAL
    done
    echo "Timed out waiting for lock" >&2
    exit 1
}

wait_for_lock

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
