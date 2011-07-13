#!/bin/bash
# test utility function
# to write tests :
# 1. source this file
# 2. call run_test_suite when all your test* functions have been defined

run() {
    TEST=$1
    echo -n "Running test $TEST... "
    $TEST
    echo "SUCCESS"
}

fail() {
    MESSAGE=$1
    echo FAILURE: $MESSAGE
    exit 1
}

assert() {
    ASSERTION=$1
    MESSAGE=$2
    eval "$ASSERTION" >/dev/null 2>&1 || fail "$MESSAGE"
}

assertFail() {
    ASSERTION=$1
    MESSAGE=$2
    eval "$ASSERTION" >/dev/null 2>&1 && fail "$MESSAGE"
    return $?
}

assertFailWithStatus() {
    EXPECTED_STATUS=$1
    ASSERTION=$2
    MESSAGE=$3
    assertFail "$ASSERTION" "$MESSAGE"
    STATUS=$?
    [ $EXPECTED_STATUS = "$STATUS" ] || fail "$MESSAGE"
}

assertEquals() {
    EXPECTED=$1
    ACTUAL=$2
    [ "$EXPECTED" = "$ACTUAL" ] || fail "expected $EXPECTED but was $ACTUAL"
}

run_test_suite() {
  set -e
  for test in $(set | grep '^test' | sed -e 's: .*::')
  do
    declare -F | grep ' setup$' >/dev/null && setup
    run $test
  done
}
