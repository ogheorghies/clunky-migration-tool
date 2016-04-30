#!/usr/bin/env bash

CMT_TARGET_PSQL_IMPORTER=psql

function _cmt_target_psql_validate_environment {
    if [ -z "${CMT_TARGET_PSQL_URI}" ]; then
        >&2 cat <<-EOM
            Error CMT-PSQL001: Environment variable CMT_TARGET_PSQL_URI not defined.

            For more information, see: ${CMT_HELP_URI}
EOM
        return 1
     fi
}

function target_initialize {
    _cmt_target_psql_validate_environment || return 1

    ${CMT_TARGET_PSQL_IMPORTER} ${CMT_TARGET_PSQL_URI} >/dev/null <<-SQL
        CREATE TABLE IF NOT EXISTS clunky_migration_tool_metadata (
            version varchar PRIMARY KEY CHECK (version <> ''),
            tag varchar default null,
            ts timestamp default (now())
        );
SQL
}

function target_get_current_version {
    _cmt_target_psql_validate_environment || return 1

    VERSION=$(${CMT_TARGET_PSQL_IMPORTER} -t -A ${CMT_TARGET_PSQL_URI} <<-SQL
        SELECT version FROM clunky_migration_tool_metadata ORDER BY VERSION DESC LIMIT 1
SQL
    );

    echo ${VERSION:-scratch}
}

function target_accept_changes {
    _cmt_target_psql_validate_environment || return 1

    {
        echo "BEGIN;"

        CHANGES=0
        while read change_id; do
            >&2 echo "-- Importing ${change_id}."
            cat ${change_id}
            CHANGES=$((CHANGES+1))
        done
        if [ "${CHANGES}" -eq "0" ]; then
            echo "ROLLBACK;"
        else
            echo "INSERT INTO clunky_migration_tool_metadata (version) VALUES ('$1');"
            echo "COMMIT;"
        fi
    } | ${CMT_TARGET_PSQL_IMPORTER} ${CMT_TARGET_PSQL_URI}
}
