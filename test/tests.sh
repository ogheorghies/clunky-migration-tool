#!/usr/bin/env bash

set -e

echo "Running tests, fear not."

function run_suite {
    echo -e "\x1B[0;32mTest suite: $1\x1B[0m"
    pushd $1 >/dev/null
    ./tests.sh
    popd >/dev/null
}

function finish {
    if [ "$?" == "0" ]; then
        echo -e "\nAll tests have passed. Boring."
    else
        echo -e "\nThe tests have failed. Let that sink in for a moment."
    fi
}

trap finish EXIT

cat <<-EOF | while read d; do run_suite ${d}; done
    ./source/filetree
    ./target/debug
    ./target/psql
    ./main
EOF

