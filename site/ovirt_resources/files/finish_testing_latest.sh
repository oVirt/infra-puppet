#!/bin/bash -e
REPO_PATH="/srv/resources/repos/ovirt/experimental"
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
