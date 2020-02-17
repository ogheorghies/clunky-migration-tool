#!/usr/bin/env bash

set -e

. ../../dependencies/assert.sh
. ../../dependencies/do-test.sh
. ../../../bin/target/debug/main.sh

export STOP=1

function test_target_get_current_version_works {
    CMT_TARGET_VERSION=
    assert_raises "target_get_current_version" 1

    CMT_TARGET_VERSION="v0001"
    assert_raises "target_get_current_version" 0
    assert "target_get_current_version" "v0001"
}

function test_target_accept_changes_works {
    CMT_TARGET_VERSION=
    assert_raises "target_accept_changes" 1

    CMT_TARGET_VERSION="v0001"
    assert_raises "target_accept_changes" 0
    assert "echo 'abc.sql' | target_accept_changes" "-- Importing abc.sql."
    assert "echo -e '1\n2' | target_accept_changes" "-- Importing 1.\n-- Importing 2."
}

do_test test_target_get_current_version_works
do_test test_target_accept_changes_works