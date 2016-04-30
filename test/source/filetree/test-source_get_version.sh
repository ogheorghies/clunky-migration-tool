#!/usr/bin/env bash

function test_source_get_version_works_with_multiple_versions {
    pushd sql1-some-versions &>/dev/null

    assert "source_get_version scratch" "scratch"
    assert "source_get_version v0001"   "v0001"
    assert "source_get_version v0002"   "v0002"
    assert "source_get_version v0003"   "v0003"
    assert "source_get_version v0004"   "v0004"

    assert "source_get_version first"   "v0001"
    assert "source_get_version last"    "v0004"

    assert        "source_get_version foo" ""
    assert_raises "source_get_version foo" 1

    popd &>/dev/null
}

function test_source_get_version_works_with_no_versions {
    pushd sql2-no-versions &>/dev/null

    assert "source_get_version scratch" "scratch"

    assert "source_get_version first"   ""
    assert "source_get_version last"    ""

    assert_raises "source_get_version first"  1
    assert_raises "source_get_version last"   1

    popd &>/dev/null
}

function test_source_get_version_works_with_one_version {
    pushd sql3-one-version &>/dev/null

    assert "source_get_version scratch" "scratch"

    assert "source_get_version first"   "v0001"
    assert "source_get_version last"    "v0001"

    popd &>/dev/null
}