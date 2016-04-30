#!/usr/bin/env bash

function source_initialize {
    touch .source_initialized
}

function source_get_version {
    local VERSION_ID=""

    case $1 in
        "scratch")
            VERSION_ID="scratch"
            ;;
        "first")
            VERSION_ID="v0001-fake"
            ;;
        "last")
            VERSION_ID="v0002-fake"
            ;;
        "v0001-fake")
            VERSION_ID="v0001-fake"
            ;;
        "v0002-fake")
            VERSION_ID="v0002-fake"
            ;;
        *)
            return 1
            ;;
    esac

    echo ${VERSION_ID}
}

function source_get_changes {
    local VERSION_START=$1
    local VERSION_END=$2

    # return the empty set of changes
    echo -n
}