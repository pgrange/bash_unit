#!/bin/bash

OUTPUT="UNICODE"

test_can_fail() {
  fail "this test failed on purpose"
}

test_is_correct() {
   assert true
}
