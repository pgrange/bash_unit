**bash unit testing enterprise edition framework for professionals**

It allows you to write unit tests (functions starting with *test*),
run them and, in case of failure, displays the stack trace
with source file and line number indications to locate the problem.

# How to run tests

To run tests, simply call bash_unit with all your tests files as parameter. For instance to run bash_unit tests, from bash_unit directory:

```test
./bash_unit test/test_bash_unit.sh
```

```output
Running tests in test/test_bash_unit.sh
Running test_assert_equals_fails_when_not_equal... SUCCESS
Running test_assert_equals_succeed_when_equal... SUCCESS
Running test_assert_fail_fails... SUCCESS
Running test_assert_fail_succeeds... SUCCESS
Running test_assert_fails... SUCCESS
Running test_assert_show_stderr_when_failure... SUCCESS
Running test_assert_status_code_fails... SUCCESS
Running test_assert_status_code_succeeds... SUCCESS
Running test_assert_succeeds... SUCCESS
Running test_exit_code_not_0_in_case_of_failure... SUCCESS
Running test_fail_fails... SUCCESS
Running test_fail_prints_failure_message... SUCCESS
Running test_fail_prints_where_is_error... SUCCESS
Running test_fake_actually_fakes_the_command... SUCCESS
Running test_fake_can_fake_inline... SUCCESS
Running test_fake_echo_stdin_when_no_params... SUCCESS
Running test_fake_exports_faked_in_subshells... SUCCESS
Running test_fake_transmits_params_to_fake_code... SUCCESS
Running test_run_all_tests_even_in_case_of_failure... SUCCESS
```

# How to write tests

Write your test functions in a file. The name of a test function has to start with *test*. Only functions starting with *test* will be tested.

Use the bash_unit assertion functions in your test functions, see below.

You may write a *setup* function that will be exectuted before each test is run. If you need to set someting up only once for all tests, simply write your code outside any test function, this is a bash script.

You may need to change the behavior of some commands to create conditions for your code under test to behave as expected. The *fake* function may help you to do that, see bellow.

# Test functions

bash_unit supports several shell oriented assertion functions.

## *fail*

    fail [message]

Fails the test and displays an optional message.

```bash
test_can_fail() {
  fail "this test failed on purpose"
}
```

```output
Running test_can_fail... FAILURE
this test failed on purpose
doc:test_can_fail():2
```

## *assert*

    assert <assertion> [message]

Evaluate *assertion* and fails if *assertion* fails.

*assertion* fails if its evaluation returns a status code different from 0.

In case of failure, the standard error of the evaluated *assertion* is displayed. The optional message is also displayed.

```bash
test_assert_fails() {
  assert false "this test failed, obvioulsy"
}
test_assert_succeed() {
  assert true
}
```

```output
Running test_assert_fails... FAILURE
this test failed, obvioulsy
doc:test_assert_fails():2
Running test_assert_succeed... SUCCESS
```

But you probably want to assert less obvious facts.

```bash
code() {
  touch /tmp/the_file
}

test_code_creates_the_file() {
  code

  assert "test -e /tmp/the_file"
}

test_code_makes_the_file_executable() {
  code

  assert "test -x /tmp/the_file" "/tmp/the_file should be executable"
}
```

```output
Running test_code_creates_the_file... SUCCESS
Running test_code_makes_the_file_executable... FAILURE
/tmp/the_file should be executable
doc:test_code_makes_the_file_executable():14
```

It may also be fun to use assert to check for the expected content of a file.

```bash
code() {
  echo 'not so cool' > /tmp/the_file
}

test_code_write_appropriate_content_in_the_file() {
  code

  assert "diff <(echo 'this is cool') /tmp/the_file >&2"
}
```

```output
Running test_code_write_appropriate_content_in_the_file... FAILURE
1c1
< this is cool
---
> not so cool
doc:test_code_write_appropriate_content_in_the_file():8
```

Note how we redirect standard output of *diff* to *stderr*. This is because *assert*
will only display *stderr* in case of failure but *diff* displays differences on *stdout*.

## *assert_fail*

    assert_fail <assertion> [message]

Asserts that *assertion* fails. This is the opposite of *assert*.

*assertion* fails if its evaluation returns a status code different from 0.

If the evaluated expression does not fail, then *assert_fail* will fail and display an optional message.

```bash
code() {
  echo 'not so cool' > /tmp/the_file
}

test_code_does_not_write_cool_in_the_file() {
  code

  assert_fail "grep cool /tmp/the_file" "should not write 'cool' in /tmp/the_file"
}

test_code_does_not_write_this_in_the_file() {
  code

  assert_fail "grep this /tmp/the_file"
}
```

```output
Running test_code_does_not_write_cool_in_the_file... FAILURE
should not write 'cool' in /tmp/the_file
doc:test_code_does_not_write_cool_in_the_file():8
Running test_code_does_not_write_this_in_the_file... SUCCESS
```

## *assert_status_code*

    assert_status_code <expected_status_code> <assertion> [message]

Checks for a precise status code of the evaluation of *assertion*.

It may be usefull if you want to distinguish between several error conditions in your code.

```bash
code() {
  exit 23
}

test_code_should_fail_with_code_25() {
  assert_status_code 25 code
}
```

```output
Running test_code_should_fail_with_code_25... FAILURE
 expected [25] but was [23]
doc:test_code_should_fail_with_code_25():6
```

## *assert_equals*

    assert_equals <expected> <actual> [message]

Asserts for equality of the two strings *expected* and *actual*.

```bash
test_obvious_inequality_with_assert_equals(){
  assert_equals "a string" "another string" "a string should be another string"
}
test_obvious_equality_with_assert_equals(){
  assert_equals a a
}

```

```output
Running test_obvious_equality_with_assert_equals... SUCCESS
Running test_obvious_inequality_with_assert_equals... FAILURE
a string should be another string
 expected [a string] but was [another string]
doc:test_obvious_inequality_with_assert_equals():2
```

#*fake* function

    fake <command> [replacement code]

Fakes *command* and replaces it with replacement code (if code is specified) for the rest of the execution of your test. If no replacement code is specified, then it replaces command by one that echo stdin of fake. This may be usefull if you need to simulate an environment for you code under test.

For instance:

```bash
fake ps echo hello world
ps
```

will output:

```output
hello world
```

We can do the same using *stdin* of fake:

```bash
fake ps << EOF
hello world
EOF
ps
```

```output
hello world
```

## Using stdin

Here is an exemple, parameterizing fake with its *stdin* to test that code fails when some process does not run and succeeds otherwise:

```bash
code() {
  ps | grep apache
}

test_code_succeeds_if_apache_runs() {
  fake ps <<EOF
  PID TTY          TIME CMD
13525 pts/7    00:00:01 bash
24162 pts/7    00:00:00 ps
 8387 ?            0:00 /usr/sbin/apache2 -k start
EOF

  assert code "code should succeed when apache is running"
}

test_code_fails_if_apache_does_not_run() {
  fake ps <<EOF
  PID TTY          TIME CMD
13525 pts/7    00:00:01 bash
24162 pts/7    00:00:00 ps
EOF

  assert_fail code "code should fail when apache is not running"
}

```

```output
Running test_code_fails_if_apache_does_not_run... SUCCESS
Running test_code_succeeds_if_apache_runs... SUCCESS
```

## Checking parameters

*fake* stores parameters given to the fake in the global variable *FAKE_PARAMS* so that you can check or use them if you wish.

