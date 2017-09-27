#!/bin/bash -ex
# deploy-to-tested.sh - Deploy packages to tested
#   This script get repoman conf via STDIN and then runs repoman to gather
#   packages and deploy them to the 'tested' repo
#
BASE_DIR="/srv/resources/repos/ovirt/tested"
PUBLISH_MD_COPIES=50

main() {
    local tmp_dir

    mkdir -p "$BASE_DIR"
    tmp_dir="$(mktemp -d "$BASE_DIR/.deploy.XXXXXXXXXX")"
    trap "rm -rf '$tmp_dir'" EXIT HUP

    echo "Collecting packages"
    collect_packages "$tmp_dir"
    echo "Publishing to repo"
    push_to_tested "$tmp_dir" "$BASE_DIR"
}

collect_packages() {
    local repoman_dst="${1:?}"

    repoman \
        --temp-dir generate-in-repo \
        --option main.allowed_repo_paths="$repoman_dst" \
        --option main.on_empty_source=warn \
        "$repoman_dst" \
        add conf:stdin
}

push_to_tested() {
    local pkg_src="${1:?}"
    local pkg_dst="${2:?}"

    (
        cd "$pkg_src"
        find . -type d \! -name 'repodata' | tac | while read dir; do
            install -o "$USER" -m 755 -d "$pkg_dst/$dir"
            find "$dir" -maxdepth 1 \! -type d -print0 | \
                xargs -0 -r cp -RPplf -t "$pkg_dst/$dir"
            if [[ -d "$dir/repodata" ]]; then
                createrepo_c \
                    --update \
                    --retain-old-md "$PUBLISH_MD_COPIES" \
                    --workers 8 \
                    "$pkg_dst/$dir"
            fi
        done
    )
}

main "$@"