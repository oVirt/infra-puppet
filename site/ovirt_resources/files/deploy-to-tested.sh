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

    # cleaning ISOs
    iso_cleanup "$pkg_dst"
    (
        cd "$pkg_src"
        find . -type d \! -name 'repodata' | tac | while read dir; do
            install -o "$USER" -m 755 -d "$pkg_dst/$dir"
            find "$dir" -maxdepth 1 \! -type d -print0 | \
                xargs -0 -r cp -RPplf -t "$pkg_dst/$dir"
            if [[ -d "$dir/repodata" ]]; then
                # The command produces 2 FD which contains packages that are
                # 14+ days older and whitelisted packages of latest version RPM.
                # the comm command whitelist the 2nd output and produces a new
                # list containing only the old packages that are safe to remove.
                comm -23 <(\
                    find "$pkg_dst/${dir#./}" \
                    -name *.rpm -type f -mtime +14 | sort
                ) \
                <(\
                    repomanage -k1 --new -c "$pkg_dst/$dir" | sort
                ) \
                | xargs -L 1 -P 8 -r rm -f
                createrepo_c \
                    --update \
                    --retain-old-md "$PUBLISH_MD_COPIES" \
                    --compatibility \
                    --workers 8 \
                    "$pkg_dst/$dir"
            fi
        done
    )
}

iso_cleanup() {
    local max_file_age=8
    local minimal_files_allowed=3
    # find all non-hidden sub directories under the given path(for example: master, 4.2, 4.3)
    list_of_sub_dirs=$(find ${1} -mindepth 1 -maxdepth 1 -type d ! -name ".*")

    # if no sub-dirs were found - return
    if test -z "$list_of_sub_dirs"; then
        echo "no sub dirs under ${1}"
        return
    fi

    # looping through dirs that may contain iso files
    for dir in ${list_of_sub_dirs[@]}; do
        # creating the absolute path
        full_path="$dir/iso/ovirt-node-ng-installer"
        # avoiding non-existing dirs
        if [ ! -d $full_path ]; then
            echo "following path does not exist: ${full_path}"
            continue
        fi
        isos_matching_policy=($(find ${full_path} -type f -name "*.iso" -mtime +${max_file_age}))

        # if there are no files matching the policy (no further work is needed) - continue
        if test -z "$isos_matching_policy"; then
            echo "no iso files matching policy under ${dir}"
            continue
        fi

        # finding all ISOs under the given directory
        all_isos=($(find ${full_path} -type f -name "*.iso"))

        if [ ${#all_isos[@]} -lt $minimal_files_allowed ]; then
            echo "there are less than ${minimal_files_allowed} isos  under ${full_path}"
            continue
        fi

        #checking if the contents of the two arrays is equal
        isos_for_deletion_str=${isos_matching_policy[@]}
        all_isos_str=${all_isos[@]}
        # string comparison
        if [ "$isos_for_deletion_str" == "$all_isos_str" ]; then
            # sorting the array lexicographically
            IFS=$'\n' sorted=($(sort <<<"${isos_matching_policy[*]}"))
            unset IFS
            # whitelist the two latest images
            unset 'sorted[${#sorted[@]}-1]'
            unset 'sorted[${#sorted[@]}-1]'
            to_be_deleted=("${sorted[@]}")
        else
            # arrays are not equal, so old isos can be deleted normally
            to_be_deleted=("${isos_matching_policy[@]}")
        fi
        # removing files
        for file in ${to_be_deleted[@]}; do
            rm $file
        done
        # deleting the remaining empty dirs
        find "$full_path" -type d -empty -delete
    done
}

main "$@"
