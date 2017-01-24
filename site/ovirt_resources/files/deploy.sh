#!/bin/bash

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

repoman \
    --verbose \
    --temp-dir generate-in-repo \
    --option main.allowed_repo_paths=/srv/resources/repos/ovirt/experimental \
    --create-latest-repo \
    '/srv/resources/repos/ovirt/experimental' \
    add conf:stdin
