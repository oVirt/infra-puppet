#!/bin/bash -e

find \
    /srv/resources/repos/ovirt/experimental/*/* \
    -maxdepth 0 \
    -type d \
    -not -name 'latest.*' \
    -and \
    -not -name 'latest' \
    -and \
    -mtime +1 \
    -exec rm -rf {} \;
