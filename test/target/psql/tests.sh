#!/usr/bin/env bash

set -e

. ../../dependencies/assert.sh
. ../../dependencies/do-test.sh
. ../../dependencies/pg-docker-tool.sh
. ../../../bin/target/psql/main.sh

export STOP=1

function test_target_initialize_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    target_initialize
    COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from clunky_migration_tool_metadata')

    assert "echo ${COUNT}" 0
}

function test_target_get_current_version_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    target_initialize
    assert "target_get_current_version" "scratch"

    psql ${CMT_TARGET_PSQL_URI} -c "INSERT INTO clunky_migration_tool_metadata (version) VALUES ('v0001')" >/dev/null
    assert "target_get_current_version" "v0001"

    psql ${CMT_TARGET_PSQL_URI} -c "INSERT INTO clunky_migration_tool_metadata (version) VALUES ('v0000')" >/dev/null
    assert "target_get_current_version" "v0001"

    psql ${CMT_TARGET_PSQL_URI} -c "INSERT INTO clunky_migration_tool_metadata (version) VALUES ('v0002')" >/dev/null
    assert "target_get_current_version" "v0002"
}

function test_target_accept_changes_works {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    target_initialize
    cat >.sql1 <<-SQL
        CREATE TABLE t1 (idx integer);
SQL

    echo ".sql1" | target_accept_changes "v0001" >/dev/null 2>&1

    COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from t1')
    assert "echo ${COUNT}" 0

    assert "target_get_current_version" "v0001"

cat >.sql2 <<-SQL
        CREATE TABLE t2 (idx integer);
SQL

    echo ".sql2" | target_accept_changes "v0002" >/dev/null 2>&1

    COUNT=$(psql ${CMT_TARGET_PSQL_URI} -t -A -c 'SELECT count(*) from t2')
    assert "echo ${COUNT}" 0

    assert "target_get_current_version" "v0002"

    rm .sql1 .sql2
}

function test_target_accept_changes_rollbacks_when_no_changes {
    pg_docker_tool_fresh ${CMT_TARGET_PSQL_URI} >/dev/null

    target_initialize
    echo -n | target_accept_changes "v0001" >/dev/null 2>&1
    assert "target_get_current_version" "scratch"

    cat >.sql1 <<-SQL
        CREATE TABLE t1 (idx integer);
SQL
    echo ".sql1" | target_accept_changes "v0001" >/dev/null 2>&1

    echo -n | target_accept_changes "v0002" >/dev/null 2>&1
    assert "target_get_current_version" "v0001"

    rm .sql1
}

pg_docker_operational

DOCKER_NAME="cmt-test-pg-EA33214F8216"
TEST_LOG=/tmp/.cmt-psql.log

echo "Creating test database, this should take a while. Run \"tail -f ${TEST_LOG}\" for details."
CMT_TARGET_PSQL_URI=$(pg_docker_tool_up ${DOCKER_NAME} 2>${TEST_LOG})
echo -e "Working with ${CMT_TARGET_PSQL_URI}\n"

do_test test_target_initialize_works
do_test test_target_get_current_version_works
do_test test_target_accept_changes_works
do_test test_target_accept_changes_rollbacks_when_no_changes

pg_docker_tool_down ${DOCKER_NAME} 2>>${TEST_LOG}