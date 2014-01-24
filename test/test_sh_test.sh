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

run_test_suite

