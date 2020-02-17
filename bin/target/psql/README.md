Specify the target database by setting the environment variable `CMT_TARGET_PSQL_URI` or `CMT_TARGET`.

`CMT_TARGET` defaults to `psql`. If `CMT_TARGET_PSQL_URI` is set, then `CMT_TARGET` is set to `psql ${CMT_TARGET_PSQL_URI}`.

Note that if the variable is set with the parameter `-D`, `CMT_` is automatically prepended to its name.

Example use:

```
    clunky-migration-tool --mode filetree:psql -D TARGET="psql postgres://db_user:db_pass@localhost/db"
```
