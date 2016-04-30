#!/usr/bin/env bash

function do_test {
    echo -n "    $1"
    $*
    echo " ✓"
}