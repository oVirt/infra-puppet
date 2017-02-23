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

find \
    /srv/resources/repos/ovirt/experimental/*/* \
    -maxdepth 0 \
    -type d \
    -not -name 'latest.*' \
    -and \
    -not -name 'latest' \
    -and \
    -not -name 'el7Server' \
    -and \
    -mtime +1 \
    -exec rm -rf {} \;
