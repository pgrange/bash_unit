#!/bin/bash

test_fail_fails() {
  with_bash_unit_muted fail && \
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
  with_bash_unit_muted assert_fail true && fail 'assert_fail should fail' || true
}

#assert_fail can now be used in the following tests

test_assert_succeeds() {
  assert true || fail 'assert should succeed'
}

test_assert_fails() {
  assert_fail "with_bash_unit_muted assert false" "assert should fail"
}

#assert can now be used in the following tests

test_assert_equals_fails_when_not_equal() {
  assert_fail \
    "with_bash_unit_muted assert_equals toto tutu" \
    "assert_equals should fail"
}

test_assert_equals_succeed_when_equal() {
  assert \
    "assert_equals 'toto tata' 'toto tata'"\
    'assert_equals should succeed'
}

#assert_equals can now be used in the following tests

test_assert_not_equals_fails_when_equal() {
  assert_fail \
    "with_bash_unit_muted assert_not_equals toto toto" \
    "assert_not_equals should fail"
}

test_assert_not_equals_succeeds_when_not_equal() {
  assert \
    "assert_not_equals 'toto tata' 'toto tutu'"\
    'assert_not_equals should succeed'
}

test_fail_prints_failure_message() {
  message=$(with_bash_unit_log fail 'failure message' | line 2)

  assert_equals 'failure message' "$message" \
    "unexpected error message"
}

test_fail_prints_where_is_error() {
  assert_equals "${BASH_SOURCE}:${LINENO}:${FUNCNAME}()" \
    "$(with_bash_unit_stack fail | last_line)"
}

test_assert_status_code_succeeds() {
  assert "assert_status_code 3 'exit 3'" \
    "assert_status_code should succeed"
}

test_assert_status_code_fails() {
  assert_fail "with_bash_unit_muted assert_status_code 3 true" \
    "assert_status_code should fail"
}

test_assert_shows_stderr_on_failure() {
  message="$(with_bash_unit_err \
    assert 'echo some error message >&2; echo some ok message; echo another ok message; exit 2'
  )"

  assert_equals "\
some error message" \
    "$message"
}

test_assert_shows_stdout_on_failure() {
  message="$(with_bash_unit_out \
    assert 'echo some error message >&2; echo some ok message; echo another ok message; exit 2'
  )"

  assert_equals "\
some ok message
another ok message" \
    "$message"
}

test_fake_actually_fakes_the_command() {
  fake ps echo expected
  assert_equals "expected" $(ps)
}

test_fake_can_fake_inline() {
  assert_equals \
    "expected" \
    $(fake ps echo expected ; ps)
}

test_fake_exports_faked_in_subshells() {
  fake ps echo expected
  assert_equals \
    expected \
    $( bash -c ps )
}

test_fake_transmits_params_to_fake_code() {
  function _ps() {
    assert_equals "aux" "$FAKE_PARAMS"
  }
  export -f _ps
  fake ps _ps

  ps aux
}

test_fake_echo_stdin_when_no_params() {
  fake ps << EOF
  PID TTY          TIME CMD
 7801 pts/9    00:00:00 bash
 7818 pts/9    00:00:00 ps
EOF

  assert_equals 2 $(ps | grep pts | wc -l)
}

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

test_bash_unit_changes_cwd_to_current_test_file_directory() {
  assert "ls ../tests/$(basename "$BASH_SOURCE")" \
    "bash_unit should change current working directory to match the directory of the currenlty running test"
}

line() {
  line_nb=$1
  tail -n +$line_nb | head -1
}

last_line() {
  tail -1
}

with_bash_unit_muted() {
  with_bash_unit_notifications_muted "$@"
}

with_bash_unit_err() {
  with_bash_unit_notifications_muted -e "$@"
}

with_bash_unit_out() {
  with_bash_unit_notifications_muted -o "$@"
}

with_bash_unit_log() {
  with_bash_unit_notifications_muted -l "$@"
}

with_bash_unit_stack() {
  with_bash_unit_notifications_muted -s "$@"
}

with_bash_unit_notifications_muted() {
  (
    mute
    unset OPTIND
    while getopts "lsoe" option
    do
      case "$option" in
        l)
          unmute_logs
          ;;
        s)
          unmute_stack
          ;;
        o)
          unmute_out
          ;;
        e)
          unmute_err
          ;;
      esac
    done
    shift $((OPTIND-1))

    "$@"
  )
}

unmute_logs() {
  notify_suite_starting() { echo "Running tests in $1" ; }
  notify_test_starting () { echo -n "Running $1... " ; }
  notify_test_succeeded() { echo "SUCCESS" ; }
  notify_test_failed   () { echo "FAILURE" ; echo $2 ; }
}

unmute_stack() {
  notify_stack() { cat ; }
}

unmute_out() {
  notify_stdout() { cat ; }
}

unmute_err() {
  notify_stderr() { cat ; }
}

mute() {
  notify_suite_starting() { echo -n ; }
  notify_test_starting () { echo -n ; }
  notify_test_succeeded() { echo -n ; }
  notify_test_failed   () { echo -n ; }
  notify_stack         () { echo -n ; }
  notify_stdout        () { echo -n ; }
  notify_stderr        () { echo -n ; }
}

BASH_UNIT="eval FORCE_COLOR=false ../bash_unit"
