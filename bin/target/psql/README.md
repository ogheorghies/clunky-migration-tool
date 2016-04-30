Define shell variable MIGRATION_TOOL_PG_URI for this target to work.

Example use:

    CMT_TARGET_PSQL_URI=postgres://db_user:db_pass@localhost/db
    migration-tool -m filetree:psql