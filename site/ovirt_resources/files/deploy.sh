#!/bin/bash
repoman \
    --verbose \
    --temp-dir generate-in-repo \
    --option main.allowed_repo_paths=/srv/resources/repos/ovirt/experimental \
    --create-latest-repo \
    '/srv/resources/repos/ovirt/experimental' \
    add conf:stdin
