Source type: filetree
=====================

This source type interprets a directory structure of the following kind:

    .clunky-migration-tool-source-filetree
     v0001
         from-scratch
             000-schema.sql
             010-data.sql
     v0002
         from-previous
             000-patch-schema.sql
             010-update-data.sql
         from-scratch
             000-schema.sql
             010-data.sql
     v0003
         from-previous
             000-patch-schema.sql
         from-scratch
             000-schema.sql
             010-data.sql

Function `source_initialize` is not needed and therefore not defined.

Function `source_get_changes` accepts a start version and an end version parameter. Version `first`
references the first version, `v0001` in the example above, and version `last` references the last version,
`v0003` in the example above.

Versions are considered in the lexicographical order of their names - using semantic versioning alone won't work. Downgrades are currently not supported: supplying a start version that is after or equal to the end version produces an empty result.

If the start version is `scratch`, the files in the `from-scratch` directory corresponding to the supplied end version
are returned. Otherwise, the list of files in the `from-previous` directories spanning from the start version, but not
including it, up to the end version is returned.

Examples
--------

    source_get_changes scratch v3
    ./v0003/from-scratch/000-schema.sql
    ./v0003/from-scratch/010-data.sql

    source_get_changes v0003 v0003
    # empty response

    source_get_changes v0001 v0003
    ./v0002/from-previous/000-patch-schema.sql
    ./v0002/from-previous/010-update-data.sql
    ./v0003/from-previous/000-patch-schema.sql

