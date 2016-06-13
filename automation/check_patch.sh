#!/bin/bash
#
IFS=$'\n'
changed_files=($(git show --format=format: --name-only HEAD))
changed_manifests=($(printf "%s\n" "${changed_files[@]}" | grep '\.pp$'))
changed_puppetfile=($(printf "%s\n" "${changed_files[@]}" | grep -F Puppetfile))
unset IFS

let failed=0

if [[ ${#changed_manifests[@]} -gt 0 ]]; then
    echo Checking changed manifests
    make test-bundle
    for manifest in "${changed_manifests[@]}"; do
        echo Checking: $manifest
        if ! bundle exec puppet parser validate "$manifest"; then
            let failed++
            echo "Failed puppet parser validation!"
            continue
        fi
        if ! bundle exec puppet-lint \
            -c automation/puppet-lint.rc "$manifest"
        then
            let failed++
            echo "Failed puppetlint validation!"
            continue
        fi
    done
fi

if [[ ${#changed_puppetfile[@]} -gt 0 ]]; then
    echo Checking changed Puppetfile
    make deployment-bundle
    for puppetfile in "${changed_puppetfile[@]}"; do
        if ! bundle exec r10k puppetfile check; then
            let failed++
            echo "Failed Puppetfile syntax validation!"
            continue
        fi
        if ! bundle exec r10k puppetfile deploy; then
            let failed++
            echo "Failed Puppetfile deployment validation!"
            continue
        fi
    done
fi

[[ $failed -gt 0 ]] && echo $failed failures detected
exit $failed
