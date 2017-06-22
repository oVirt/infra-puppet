#!/bin/bash -e

MAX_LOCK_ATTEMPTS=180
LOCK_WAIT_INTERVAL=5
LOCK_PATH=$HOME/experimental_repo.lock

wait_for_lock() {
    for ((i = 0; i < $MAX_LOCK_ATTEMPTS; i++)); do
        if (set -o noclobber; > $LOCK_PATH) 2> /dev/null; then
            trap "rm -f '$LOCK_PATH'" EXIT HUP
            return
        fi
        sleep $LOCK_WAIT_INTERVAL
    done
    echo "Timed out waiting for lock" >&2
    exit 1
}

wait_for_lock

REPO_PATH="/srv/resources/repos/ovirt/experimental"
PUBLISH_MD_COPIES=50
read version

testing_path="${REPO_PATH}/${version}/latest.under_testing"
tested_path="${testing_path%.*}.tested"

wrong_version() {
    local test_repo
    echo "Wrong version supplied, available versions under testing are:"
    for test_repo in $(find "$REPO_PATH" -maxdepth 2 -type d -name \*.under_testing -print); do
        test_repo="${test_repo%/*}"
        echo "${test_repo##*/}"
    done
    exit 1
}


if \
    [[ "${version}" == "" ]] \
    || ! [[ -d "$testing_path" ]]; \
then
    wrong_version
fi

testing_path="$(realpath "${REPO_PATH}/${version}/latest.under_testing")"
if ! [[ "$testing_path" =~ ^$REPO_PATH ]]; then
    wrong_version
fi

echo "Moving to tested $tested_path"
rm -rf "${tested_path?}"
mv "$testing_path" "$tested_path"

exit 0
