#!/bin/bash -e

MAX_LOCK_ATTEMPTS=120
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
PUBLISH_PATH="/srv/resources/repos/ovirt/tested"
PUBLISH_MD_COPIES=50
read version

testing_path="${REPO_PATH}/${version}/latest.under_testing"
tested_path="${testing_path%.*}.tested"

published_path="${PUBLISH_PATH}/${version}"

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

echo "Copying to published repo"
install -o "$USER" -m 755 -d "$published_path"
(
    cd "$tested_path"
    find . -type d \! -name 'repodata' | tac | while read dir; do
        install -o "$USER" -m 755 -d "$published_path/$dir"
        find "$dir" -maxdepth 1 \! -type d -print0 | \
            xargs -0 -r cp -RPpl -t "$published_path/$dir"
            if [[ -d "$dir/repodata" ]]; then
                createrepo \
                    --update \
                    --retain-old-md "$PUBLISH_MD_COPIES" \
                    --workers 8 \
                    "$published_path/$dir"
            fi
    done
)
exit 0
