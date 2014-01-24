#!/bin/bash

install_dir=$(cd $(dirname $0) ; pwd)

source $install_dir/../sh_test.sh

test_fail_fails() {
  (fail >/dev/null) && \
  (
    echo "FAILURE: fail must fail !!!"
    exit 1
  ) || \
  echo "OK" > /dev/null
}

#fail can now be used in the following tests

test_assert_fail_succeeds() {
  (assert_fail false) || fail 'assert_fail should succeed' 
}

test_assert_fail_fails() {
  (assert_fail true >/dev/null) && fail 'assert_fail should fail' || true
}

#assertFail can now be used in tht following tests

test_assert_equals_fails_when_not_equal() {
  (assert_equals "toto" "tutu" >/dev/null) && fail 'assert_equals should fail' || true
}

test_assert_equals_succeed_when_equal() {
  (assert_equals "toto tata" "toto tata" >/dev/null) || fail 'assert_equals should succeed'
}

#assert_equals can now be used in the following tests

test_fail_prints_failure_message() {
  fail 'failure message' \
	| grep --quiet '^FAILURE: failure message$' \
	|| fail 'unexpected error message'
}

test_fail_prints_where_is_error() {
  assert_equals "$0:${FUNCNAME}():${LINENO}" \
	$(fail | tail -n +2 | head -1)
}

run_test_suite

