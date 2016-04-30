#!/usr/bin/env bash

set -e

. ./../dependencies/assert.sh
. ./../dependencies/do-test.sh

. ./test-filetree-psql.sh

function test_unknown_types_produce_error {
    assert_raises "./../../bin/clunky-migration-tool -m unknown-source:debug last" 2
    assert_raises "./../../bin/clunky-migration-tool -m filetree:unknown-target last" 3
}

function test_user_defined_types_are_accepted {
    rm .source_initialized 2>/dev/null || true
    rm .target_initialized 2>/dev/null || true

    assert_raises "./../../bin/clunky-migration-tool -m test:test last" 0
    assert_raises "cat .source_initialized" 0
    assert_raises "cat .target_initialized" 0

    rm .source_initialized
    rm .target_initialized
}

do_test test_unknown_types_produce_error
do_test test_user_defined_types_are_accepted

pg_docker_operational

DOCKER_NAME="cmt-test-pg-EA33214F8216"
TEST_LOG=/tmp/.cmt-psql.log

echo "Creating test database, this should take a while. Run \"tail -f ${TEST_LOG}\" for details."
export CMT_TARGET_PSQL_URI=$(pg_docker_tool_up ${DOCKER_NAME} 2>${TEST_LOG})
echo -e "Working with ${CMT_TARGET_PSQL_URI}\n"

do_test test_filetree_psql_upgrade_from_scratch_to_last_version_works
do_test test_filetree_psql_upgrade_from_scratch_to_specific_version_works
do_test test_filetree_psql_upgrade_between_specific_versions_works

pg_docker_tool_down ${DOCKER_NAME} 2>>${TEST_LOG}