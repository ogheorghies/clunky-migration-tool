#!/usr/bin/env bash

if [ -n "${CMT_TARGET_PSQL_URI}" ]; then
    CMT_TARGET="psql ${CMT_TARGET_PSQL_URI}"
else
    CMT_TARGET="${CMT_TARGET:-psql}"
fi

echo "CMT_TARGET=${CMT_TARGET}"

function target_initialize {
    ${CMT_TARGET} -c "select version()" >/dev/null || {
            >&2 cat <<-EOM
                Error CMT-PSQL002: Failed to connect to the database.

                CMT_TARGET is set to "${CMT_TARGET}".

                For more information, see: ${CMT_HELP_URI}
EOM
        return 1;
    }

    ${CMT_TARGET} >/dev/null <<-SQL
        CREATE TABLE IF NOT EXISTS clunky_migration_tool_metadata (
            version varchar PRIMARY KEY CHECK (version <> ''),
            tag varchar default null,
            ts timestamp default (now())
        );
SQL
}

function target_get_current_version {
    VERSION=$(${CMT_TARGET} -t -A <<-SQL
        SELECT version FROM clunky_migration_tool_metadata ORDER BY VERSION DESC LIMIT 1
SQL
    );

    echo ${VERSION:-scratch}
}

function target_accept_changes {
    {
        echo "BEGIN;"

        CHANGES=0
        while read change_id; do
            >&2 echo "-- Importing ${change_id}."
            cat ${change_id}
            echo # Ensure SQL command validity even when change_id contents does not end in newline

            CHANGES=$((CHANGES+1))
        done
        if [ "${CHANGES}" -eq "0" ]; then
            echo "ROLLBACK;"
        else
            echo "INSERT INTO clunky_migration_tool_metadata (version) VALUES ('$1');"
            echo "COMMIT;"
        fi
    } | ${CMT_TARGET} -v ON_ERROR_STOP=1
}
