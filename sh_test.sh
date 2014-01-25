#!/bin/bash
# test utility function
# to write tests :
# 1. source this file
# 2. call run_test_suite when all your test* functions have been defined

function print_stack() {
  local i=1
  while ! [ -z ${BASH_SOURCE[$i]} ]
  do
    echo ${BASH_SOURCE[$i]}:${FUNCNAME[$i]}\(\):${BASH_LINENO[$((i-1))]}
    i=$(($i + 1))
  done
}

run() {
    TEST=$1
    echo -n "Running test $TEST... "
    $TEST
    echo "SUCCESS"
}

fail() {
    local MESSAGE=$1
    printf "FAILURE: $MESSAGE\n"
    print_stack | grep -v ^$BASH_SOURCE
    exit 1
}

assert() {
    local assertion=$1
    local message=$2
    eval "$assertion" >/dev/null 2>&1 || fail "$message"
}

assertFail() {
    local assertion=$1
    local message=$2
    eval "$assertion" >/dev/null 2>&1 && fail "$message" || true
}

assert_fail() {
  assertFail "$@"
}

assertFailWithStatus() {
    EXPECTED_STATUS=$1
    ASSERTION=$2
    MESSAGE=$3
    STATUS=$(assertFail "$ASSERTION" "$MESSAGE")
    assertEquals "$EXPECTED_STATUS" "$STATUS" "$MESSAGE"
}

assertEquals() {
  assert_equals "$@"
}

function assert_equals() {
  local expected=$1
  local actual=$2
  local message=$3
  
  [ "$expected" = "$actual" ] || fail "$message\nexpected $expected but was $actual"
}

run_test_suite() {
  set -e
  for test in $(set | grep '^test' | sed -e 's: .*::')
  do
    declare -F | grep ' setup$' >/dev/null && setup
    (run $test)
  done
}
