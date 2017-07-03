#!/bin/bash

test_run_all_tests_even_in_case_of_failure() {
  bash_unit_output=$($BASH_UNIT <(cat << EOF
function test_succeed() { assert true ; }
function test_fails()   { assert false ; }
EOF
) | sed -e 's:/dev/fd/[0-9]*:test_file:')

  assert_equals "\
Running tests in test_file
Running test_fails... FAILURE
test_file:2:test_fails()
Running test_succeed... SUCCESS" "$bash_unit_output" 
}

test_exit_code_not_0_in_case_of_failure() {
  assert_fail "$BASH_UNIT <(cat << EOF
function test_succeed() { assert true ; }
function test_fails()   { assert false ; }
EOF
)"
}

test_run_all_file_parameters() {
  bash_unit_output=$($BASH_UNIT \
    <(echo "test_one() { echo -n ; }") \
    <(echo "test_two() { echo -n ; }") \
    | sed -e 's:/dev/fd/[0-9]*:test_file:' \
  )

  assert_equals "\
Running tests in test_file
Running test_one... SUCCESS
Running tests in test_file
Running test_two... SUCCESS" "$bash_unit_output" 
}

test_run_only_tests_that_match_pattern() {
  bash_unit_output=$($BASH_UNIT -p one \
    <(echo "test_one() { echo -n ; }") \
    <(echo "test_two() { echo -n ; }") \
    | sed -e 's:/dev/fd/[0-9]*:test_file:' \
  )

  assert_equals "\
Running tests in test_file
Running test_one... SUCCESS
Running tests in test_file" "$bash_unit_output" 
}

test_do_not_run_pending_tests() {
  assert "$BASH_UNIT \
    <(echo 'pending_should_not_run() { fail ; }
            todo_should_not_run() { fail ; }') \
  "
}

test_pending_tests_appear_in_output() {
  bash_unit_output=$($BASH_UNIT \
    <(echo 'pending_should_not_run() { fail ; }
            todo_should_not_run() { fail ; }') \
    | sed -e 's:/dev/fd/[0-9]*:test_file:' \
  )

  assert_equals "\
Running tests in test_file
Running pending_should_not_run... PENDING
Running todo_should_not_run... PENDING" \
  "$bash_unit_output"
}

test_fails_when_test_file_does_not_exist() {
  assert_fail "$BASH_UNIT /not_exist/not_exist"
}

test_display_usage_when_test_file_does_not_exist() {
  bash_unit_output=$($BASH_UNIT /not_exist/not_exist 2>&1 >/dev/null | line 1)

  assert_equals "file does not exist: /not_exist/not_exist"\
                "$bash_unit_output" 
}

test_bash_unit_succeed_when_no_failure_even_if_no_teardown() {
  #FIX https://github.com/pgrange/bash_unit/issues/8
  assert "$BASH_UNIT <(echo 'test_success() { echo -n ; }')"
}

test_bash_unit_runs_teardown_even_in_case_of_failure() {
  #FIX https://github.com/pgrange/bash_unit/issues/10
  assert_equals "ran teardown" \
    "$($BASH_UNIT <(echo 'test_fail() { fail ; } ; teardown() { echo "ran teardown" >&2 ; }') 2>&1 >/dev/null)"
}

test_one_test_should_stop_after_first_assertion_failure() {
  #FIX https://github.com/pgrange/bash_unit/issues/10
  assert_equals "before failure" \
    "$($BASH_UNIT <(echo 'test_fail() { echo "before failure" >&2 ; fail ; echo "after failure" >&2 ; }') 2>&1 >/dev/null)"
}

test_one_test_should_stop_when_assert_fails() {
  #FIX https://github.com/pgrange/bash_unit/issues/26
  assert_equals "before failure" \
    "$($BASH_UNIT <(echo 'test_fail() { echo "before failure" >&2 ; assert false ; echo "after failure" >&2 ; }') 2>&1 >/dev/null)"
}

line() {
  line_nb=$1
  tail -n +$line_nb | head -1
}

BASH_UNIT="eval FORCE_COLOR=false ../bash_unit"
