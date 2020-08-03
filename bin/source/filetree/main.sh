#!/usr/bin/env bash

function __cmt_source_filetree_validate {
    local FILE_MARKER=.clunky-migration-tool-source-filetree
    local FILE_MARKER2=.cmt.env
    if [ ! -f "$FILE_MARKER" -a ! -f "$FILE_MARKER2" ]; then
        >&2 cat <<-EOM
                Error CMT-FILETREE002: The working directory is not marked as a filetree source.

                A filetree source root must contain a file named "${FILE_MARKER}" or "${FILE_MARKER2}".

                Working directory is: ${PWD}

                For more information, see: ${CMT_HELP_URI}
EOM
        return 1
    fi
}

function source_get_version {
    __cmt_source_filetree_validate || return 1

    [ ! -z ${CMT_DEBUG} ] && >&2 echo -e "\033[0;49;96msource_get_version $1\033[0m"
    local VERSION_ID=""

    case $1 in
        "scratch")
          VERSION_ID="scratch"
          ;;
        "first")
          VERSION_ID=$(ls -d */ | head -n 1)
          VERSION_ID=${VERSION_ID%?}
          ;;
        "last")
          VERSION_ID=$(ls -d */ | tail -n 1)
          VERSION_ID=${VERSION_ID%?}
          ;;
        *)
          if [ -d $1 ]; then
                VERSION_ID=$1
          fi
          ;;
    esac

    if [ -z "${VERSION_ID}" ]; then
        >&2 cat <<-EOM
            Error CMT-FILETREE001: The version name you supplied corresponds to no actual directory.

            Supplied version name: $1
            Search directory     : ${PWD}

            For more information, see: ${CMT_HELP_URI}
EOM
        return 1
    else
        echo ${VERSION_ID}
    fi
}

function source_get_changes {
    __cmt_source_filetree_validate || return 1

    START_VERSION=$(source_get_version $1)
    END_VERSION=$(source_get_version $2)

    [ -z ${START_VERSION} ] && return 1
    [ -z ${END_VERSION} ] && return 1

    if [ "${START_VERSION}" == "scratch" ]; then
        find -L ${END_VERSION}/from-scratch -type f | sort
    else
        find -L . -path "*/from-previous/*" -type f | \
            awk \
                -v s="${START_VERSION}" \
                -v e="${END_VERSION}" \
            'BEGIN { FS = "/" } { if ($2 > s && $2 <= e) {print $0} }' | \
            sort
    fi
}