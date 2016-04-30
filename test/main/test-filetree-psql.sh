#!/usr/bin/env bash

set -e

. ./../dependencies/assert.sh
. ./../dependencies/pg-docker-tool.sh

export STOP=1

function test_filetree_psql_upgrade_from_scratch_to_last_version_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    pushd ../source/filetree/sql1-some-versions >/dev/null

    ../../../../bin/clunky-migration-tool -m filetree:psql last >/dev/null 2>&1
    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item2' 2>/dev/null)
    assert "echo ${COUNT}" 0

    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item' 2>/dev/null)
    assert "echo ${COUNT}" 2

    popd >/dev/null
}

function test_filetree_psql_upgrade_from_scratch_to_specific_version_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    pushd ../source/filetree/sql1-some-versions >/dev/null

    ../../../../bin/clunky-migration-tool -m filetree:psql v0002 >/dev/null 2>&1
    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item2' 2>/dev/null)
    assert "echo ${COUNT}" ""

    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item' 2>/dev/null)
    assert "echo ${COUNT}" "2"

    popd >/dev/null
}

function test_filetree_psql_upgrade_between_specific_versions_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    pushd ../source/filetree/sql1-some-versions >/dev/null

    ../../../../bin/clunky-migration-tool -m filetree:psql v0002 >/dev/null 2>&1
    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item2' 2>/dev/null)
    assert "echo ${COUNT}" ""

    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item' 2>/dev/null)
    assert "echo ${COUNT}" "2"

    ../../../../bin/clunky-migration-tool -m filetree:psql v0004 >/dev/null 2>&1

    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item2' 2>/dev/null)
    assert "echo ${COUNT}" 0

    local COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from item' 2>/dev/null)
    assert "echo ${COUNT}" 2

    popd >/dev/null
}