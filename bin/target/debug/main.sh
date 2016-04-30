#!/usr/bin/env bash

function _validate_environment {
    if [ -z "${CMT_TARGET_DEBUG_VERSION}" ]; then
        >&2 cat <<-EOM
            Error CMT-DBG001: Environment variable CMT_TARGET_DEBUG_VERSION not defined.

            For more information, see: ${CMT_HELP_URI}
EOM
        return 1
     fi
}

function target_get_current_version {
    _validate_environment || return 1

    echo "${CMT_TARGET_DEBUG_VERSION}"
}

function target_accept_changes {
    _validate_environment || return 1

    while read change_id; do
        echo "-- Importing ${change_id}."
    done
}