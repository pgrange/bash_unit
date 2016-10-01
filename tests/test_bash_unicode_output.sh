#!/bin/bash

test_can_fail() {
  fail "this test failed on purpose"
}

test_is_correct() {
   assert true
}

code() {
  touch /tmp/the_file
}

test_code_creates_the_file() {
  code
  assert "test -e /tmp/the_file"
}

code2() {
  exit 25
}

test_code_with_code_25() {
  assert_status_code 25 code2
}
