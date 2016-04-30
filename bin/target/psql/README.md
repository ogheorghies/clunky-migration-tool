Define shell variable CMT_TARGET_PSQL_URI for this target to work.

Example use:

    CMT_TARGET_PSQL_URI=postgres://db_user:db_pass@localhost/db
    clunky-migration-tool -m filetree:psql
