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

test_assert_fails_succeeds() {
  (assert_fails false) || fail 'assert_fails should succeed' 
}

test_assert_fails_fails() {
  with_bash_unit_muted assert_fails true && fail 'assert_fails should fail' || true
}

#assert_fails can now be used in the following tests

test_assert_succeeds() {
  assert true || fail 'assert should succeed'
}

test_assert_fails() {
  assert_fails "with_bash_unit_muted assert false" "assert should fail"
}

#assert can now be used in the following tests

test_assert_equals_fails_when_not_equal() {
  assert_fails \
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
  assert_fails \
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
  assert_fails "with_bash_unit_muted assert_status_code 3 true" \
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

if [[ "${STICK_TO_CWD}" != true ]]
then
  # do not test for cwd if STICK_TO_CWD is true
  test_bash_unit_changes_cwd_to_current_test_file_directory() {
    assert "ls ../tests/$(basename "$BASH_SOURCE")" \
      "bash_unit should change current working directory to match the directory of the currenlty running test"
  }

  #the following assertion is out of any test on purpose
  assert "ls ../tests/$(basename "$BASH_SOURCE")" \
  "bash_unit should change current working directory to match the directory of the currenlty running test before sourcing test file"
fi

setup() {
  # enforce bash variable controls during core tests
  # this way we know that people using this enforcement
  # in their own code can still rely on bash_unit
  set -u
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
