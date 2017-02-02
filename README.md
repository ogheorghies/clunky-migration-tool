Clunky migration tool
=====================

A version migration tool, written in Bash - fast and well tested. May be used for database schema and data migrations.

> **clunky** ˈklʌŋki/', *adjective*. Solid, heavy, and old-fashioned.

Upgrade a PostgreSQL database to the most recent schema, as described by a [SQL file tree](../master/bin/source/filetree/README.md):

    CMT_TARGET_PSQL_URI=postgres://user:pwd@localhost:5432/app
    clunky-migration-tool -m filetree:psql

Display the files involved in a migration from version `v3` to version `v5`:

    CMT_TARGET_DEBUG_VERSION=v3
    clunky-migration-tool -m filetree:debug v5

Command line
------------

    clunky-migration-tool
      -v|--verbose              enable verbose mode
      -m|--mode source:target   upgrades taken from source type and applied to target type
      -D name=value             defines a variable 'name' set to 'value'
      -C directory              run in the specified directory
      <to-version>              "last" or empty (equivalent), or a given version (e.g. "v5")
    
Overview
--------

"Clunky migration tool" uses a "source" to update a "target". If a target is at version 3, but a source contains
upgrades up to version 5, an upgrade from version 3 to version 4 may be first applied, followed by
an upgrade from version 4 to version 5. A fresh target may be directly populated to the desired version, without
going through incremental upgrades.

In common scenarios, a target may be a database, and a source may be a file tree containing SQL files, organized
by version.

However, this project does not prescribe what a target or a source may be. Instead, it defines the interfaces that
sources and targets must implement.

Sources and targets
-------------------

A *source* must define the following interface:

    source_initialize
    source_get_version ${VERSION_NAME}
    source_get_changes ${VERSION_START} ${VERSION_END}

The function `source_initialize` is optional, and may perform initialization tasks.

The function `source_get_version` returns the actual identifier that corresponds to a given version name.
An actual version identifier must be return for the special version names `first` and `last`, for example `v1` and `v5`,
respectively.
If the given `${VERSION_NAME}` cannot be resolved, the function must exit with an error code. If `${VERSION_NAME}`
is `scratch`, then `scratch` must be returned. The names `first`, `last`, and `scratch` have a special meaning
and cannot be used to denote specific application versions.

The function `source_get_changes` returns a set of handles to patches that need to be applied in order to migrate
from `${VERSION_START}` to `${VERSION_END}` (both parameters are passed through `source_get_version`).
If `${VERSION_START}` is `"scratch"`, the function may return the changes needed to directly create the
target at `${VERSION_END}`. If downgrades are not supported, namely when `${VERSION_END}` is before `${VERSION_START}`,
the function must return an empty string.

A *target* must define the following interface:

    target_initialize
    target_get_current_version
    target_accept_changes ${VERSION}

The function `target_initialize` is optional, but it is likely needed to perform initialization tasks.

The function `target_get_current_version` returns the current version of the target, or `scratch` if the
target has not been populated with any version.

The function `target_accept_changes` transactionally applies changes to the target, and sets the
current version to its parameter `${VERSION}`. It must allow the output of `source_get_changes` to be piped
into it. Moreover, it must not change the version if the set of changes provided by the source is empty.

For example, the following code template is expected to work.

    source_initialize
    target_initialize
    BEGIN=$(target_get_current_version)
    END=$(source_get_version "last") # or other version to upgrade to
    source_get_changes ${BEGIN} ${END} | target_accept_changes ${END}

Custom sources and targets
--------------------------

The type of the source and the type of the target are specified in the mode parameter, `-m`, and are separated by a
column. In the example below, the source is of type `filetree`, and the target of type `psql`.

    clunky-migration-tool -m filetree:psql v5

These two types are standard, and their interfaces are defined within the library, respectively, at:

    ${LIBRARY_ROOT}/source/filetree/main.sh
    ${LIBRARY_ROOT}/target/psql/main.sh

User-specified types can be used and implemented as follows:

    ls -l ./clunky-migration-tool/target/sqlite/main.sh
    clunky-migration-tool -m filetree:sqlite v5

The library first searches for user-defined source and target types, thus unintentional name clashes with
library-defined types are avoided.

Postgres migration example
--------------------------

This library was initially written to populate and upgrade Postgresql databases from SQL files grouped
by version into directories. In this scenario, the source is of type `"filetree"`, and the target is
of type `"psql"`. The corresponding implementations and tests are available in the `${LIBRARY_ROOT}/source/filetree` and
`${LIBRARY_ROOT}/target/psql` directories, respectively.

A source of type `filetree` may contain directories and files as follows:

    v0001-0.0.0
        from-scratch
            000-schema.sql
            010-data.sql
    v0002-0.0.1
        from-previous
            000-patch-schema.sql
            010-update-data.sql
        from-scratch
            000-schema.sql
            010-data.sql

A target of type `psql` stores the current version into a specially created table, executes the SQL code
contained in the SQL files whose names are supplied by the source, and updates the current version only if everything
goes well during the upgrade.
