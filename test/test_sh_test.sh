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

test_fail_prints_failure_message() {
  fail 'failure message' \
	| grep --quiet '^FAILURE: failure message$' \
	|| fail 'unexpected error message'
}

test_fail_prints_where_is_error() {
  fail | grep --quiet "$0" || fail 'missing source filename' 
  fail | grep --quiet "${FUNCNAME}" || fail 'missing funcname' 
  fail | grep --quiet "${LINENO}" || fail 'missing line number' 
}
run_test_suite

