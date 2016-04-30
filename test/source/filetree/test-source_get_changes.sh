#!/usr/bin/env bash

__TO_LINE=" | tr '\n' ' ' | sed 's/[[:blank:]]*$//'"

function test_source_get_changes_works_with_multiple_versions {
    pushd sql1-some-versions &>/dev/null

    assert "source_get_changes scratch scratch ${__TO_LINE}" \
           ""

    assert "source_get_changes last first" ""

    assert "source_get_changes scratch v0001 ${__TO_LINE}" \
           "v0001/from-scratch/000-schema.sql v0001/from-scratch/100-data.sql"

    assert "source_get_changes scratch v0002 ${__TO_LINE}" \
           "v0002/from-scratch/000-schema.sql v0002/from-scratch/100-data.sql"

    assert "source_get_changes scratch v0003 ${__TO_LINE}" \
           "v0003/from-scratch/000-schema.sql v0003/from-scratch/100-data.sql"

    assert "source_get_changes scratch v0004 ${__TO_LINE}" \
           "v0004/from-scratch/000-schema.sql v0004/from-scratch/100-data.sql"

    assert "source_get_changes scratch first ${__TO_LINE}" \
           "v0001/from-scratch/000-schema.sql v0001/from-scratch/100-data.sql"

    assert "source_get_changes scratch last ${__TO_LINE}" \
           "v0004/from-scratch/000-schema.sql v0004/from-scratch/100-data.sql"

    assert "source_get_changes v0001 v0002 ${__TO_LINE}" \
           "./v0002/from-previous/000-schema.sql ./v0002/from-previous/010-data-update.sql ./v0002/from-previous/100-data-new.sql"

    assert "source_get_changes first v0002 ${__TO_LINE}" \
           "./v0002/from-previous/000-schema.sql ./v0002/from-previous/010-data-update.sql ./v0002/from-previous/100-data-new.sql"

    assert "source_get_changes v0001 v0003 ${__TO_LINE}" \
           "./v0002/from-previous/000-schema.sql ./v0002/from-previous/010-data-update.sql ./v0002/from-previous/100-data-new.sql ./v0003/from-previous/000-schema.sql ./v0003/from-previous/010-data-update.sql"

    assert "source_get_changes v0001 v0004 ${__TO_LINE}" \
           "./v0002/from-previous/000-schema.sql ./v0002/from-previous/010-data-update.sql ./v0002/from-previous/100-data-new.sql ./v0003/from-previous/000-schema.sql ./v0003/from-previous/010-data-update.sql ./v0004/from-previous/000-schema.sql"

    assert "source_get_changes first last ${__TO_LINE}" \
           "./v0002/from-previous/000-schema.sql ./v0002/from-previous/010-data-update.sql ./v0002/from-previous/100-data-new.sql ./v0003/from-previous/000-schema.sql ./v0003/from-previous/010-data-update.sql ./v0004/from-previous/000-schema.sql"

    popd &>/dev/null
}

function test_source_get_changes_works_with_no_versions {
    pushd sql2-no-versions &>/dev/null

    assert        "source_get_changes scratch first" ""
    assert_raises "source_get_changes scratch first" 1

    assert        "source_get_changes first last" ""
    assert_raises "source_get_changes first last" 1

    popd &>/dev/null
}