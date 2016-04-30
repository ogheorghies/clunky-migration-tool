#!/usr/bin/env bash

set -e

. ../../dependencies/assert.sh
. ../../dependencies/do-test.sh
. ../../../bin/source/filetree/main.sh

export STOP=1

. test-source_get_version.sh
. test-source_get_changes.sh

do_test test_source_get_version_works_with_multiple_versions
do_test test_source_get_version_works_with_no_versions
do_test test_source_get_version_works_with_one_version

do_test test_source_get_changes_works_with_multiple_versions
do_test test_source_get_changes_works_with_no_versions