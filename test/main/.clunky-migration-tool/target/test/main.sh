#!/usr/bin/env bash

function target_initialize {
    touch .target_initialized
}

function target_get_current_version {
    echo "scratch"
}

function target_accept_changes {
    END_VERSION=$1
    cat >/dev/null
}