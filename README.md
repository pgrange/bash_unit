**bash unit testing enterprise edition framework for professionals**

It allows you to write unit tests (functions starting with *test*),
run them and, in case of failure, displays the stack trace
with source file and line number indications to locate the problem.

You might want to take a look at [how to get started](getting_started)
before continuing reading this documentation.

*(by the way, the documentation you are reading is itself tested with bash-unit)*

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Contents**

- [How to install bash_unit](#how-to-install-bash_unit)
- [How to run tests](#how-to-run-tests)
- [How to write tests](#how-to-write-tests)
- [Test functions](#test-functions)
  - [*fail*](#fail)
  - [*assert*](#assert)
  - [*assert_fail*](#assert_fail)
  - [*assert_status_code*](#assert_status_code)
  - [*assert_equals*](#assert_equals)
  - [*assert_not_equals*](#assert_not_equals)
- [*fake* function](#fake-function)
  - [Using stdin](#using-stdin)
  - [Using a function](#using-a-function)
  - [*fake* parameters](#fake-parameters)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# How to install bash_unit

This will install bash_unit in your current working directory:

    bash <(curl -s https://raw.githubusercontent.com/pgrange/bash_unit/master/install.sh)

You can also download it from the [release page](https://github.com/pgrange/bash_unit/releases).

## installing on Archlinux

bash_unit package is available on Archlinux through AUR. In order to install, issue the following command :

    yaourt -Sys bash_unit

# How to run tests

To run tests, simply call bash_unit with all your tests files as parameter. For instance to run bash_unit tests, from bash_unit directory:

```test
./bash_unit tests/test_bash_unit.sh
```

```output
Running tests in tests/test_bash_unit.sh
Running test_assert_equals_fails_when_not_equal... SUCCESS
Running test_assert_equals_succeed_when_equal... SUCCESS
Running test_assert_fail_fails... SUCCESS
Running test_assert_fail_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_fail_succeeds... SUCCESS
Running test_assert_fails... SUCCESS
Running test_assert_not_equals_fails_when_equal... SUCCESS
Running test_assert_not_equals_succeeds_when_not_equal... SUCCESS
Running test_assert_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_status_code_fails... SUCCESS
Running test_assert_status_code_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_status_code_succeeds... SUCCESS
Running test_assert_succeeds... SUCCESS
Running test_bash_unit_changes_cwd_to_current_test_file_directory... SUCCESS
Running test_bash_unit_runs_teardown_even_in_case_of_failure... SUCCESS
Running test_bash_unit_succeed_when_no_failure_even_if_no_teardown... SUCCESS
Running test_display_usage_when_test_file_does_not_exist... SUCCESS
Running test_exit_code_not_0_in_case_of_failure... SUCCESS
Running test_fail_fails... SUCCESS
Running test_fail_prints_failure_message... SUCCESS
Running test_fail_prints_where_is_error... SUCCESS
Running test_fails_when_test_file_does_not_exist... SUCCESS
Running test_fake_actually_fakes_the_command... SUCCESS
Running test_fake_can_fake_inline... SUCCESS
Running test_fake_echo_stdin_when_no_params... SUCCESS
Running test_fake_exports_faked_in_subshells... SUCCESS
Running test_fake_transmits_params_to_fake_code... SUCCESS
Running test_one_test_should_stop_after_first_assertion_failure... SUCCESS
Running test_run_all_file_parameters... SUCCESS
Running test_run_all_tests_even_in_case_of_failure... SUCCESS
Running test_run_only_tests_that_match_pattern... SUCCESS
```

You might also want to run only specific tests, you may do so with the
*-p* option. This option accepts a pattern as parameter and filters test
functions against this pattern.

```test
./bash_unit -p fail_fails -p assert tests/test_bash_unit.sh
```

```output
Running tests in tests/test_bash_unit.sh
Running test_assert_equals_fails_when_not_equal... SUCCESS
Running test_assert_equals_succeed_when_equal... SUCCESS
Running test_assert_fail_fails... SUCCESS
Running test_assert_fail_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_fail_succeeds... SUCCESS
Running test_assert_fails... SUCCESS
Running test_assert_not_equals_fails_when_equal... SUCCESS
Running test_assert_not_equals_succeeds_when_not_equal... SUCCESS
Running test_assert_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_status_code_fails... SUCCESS
Running test_assert_status_code_shows_stdout_stderr_on_failure... SUCCESS
Running test_assert_status_code_succeeds... SUCCESS
Running test_assert_succeeds... SUCCESS
Running test_fail_fails... SUCCESS
Running test_one_test_should_stop_after_first_assertion_failure... SUCCESS
```

# How to write tests

Write your test functions in a file. The name of a test function has to start with *test*. Only functions starting with *test* will be tested.

Use the bash_unit assertion functions in your test functions, see below.

You may write a *setup* function that will be exectuted before each test is run.

You may write a *teardown* function that will be exectuted after each test is run.

If you need to set someting up only once for all tests, simply write your code outside any test function, this is a bash script.

bash_unit changes the current working directory to the one of the running test file. If you need to access files from your test code, for instance the script under test, use path relative to the test file.

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
doc:2:test_can_fail()
```

## *assert*

    assert <assertion> [message]

Evaluate *assertion* and fails if *assertion* fails.

*assertion* fails if its evaluation returns a status code different from 0.

In case of failure, the standard output and error of the evaluated *assertion* is displayed. The optional message is also displayed.

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
doc:2:test_assert_fails()
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
doc:14:test_code_makes_the_file_executable()
```

It may also be fun to use assert to check for the expected content of a file.

```bash
code() {
  echo 'not so cool' > /tmp/the_file
}

test_code_write_appropriate_content_in_the_file() {
  code

  assert "diff <(echo 'this is cool') /tmp/the_file"
}
```

```output
Running test_code_write_appropriate_content_in_the_file... FAILURE
out> 1c1
out> < this is cool
out> ---
out> > not so cool
doc:8:test_code_write_appropriate_content_in_the_file()
```

## *assert_fail*

    assert_fail <assertion> [message]

Asserts that *assertion* fails. This is the opposite of *assert*.

*assertion* fails if its evaluation returns a status code different from 0.

If the evaluated expression does not fail, then *assert_fail* will fail and display the standard output and error of the evaluated *assertion*. The optional message is also displayed.

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

  assert_fail "grep this /tmp/the_file" "should not write 'this' in /tmp/the_file"
}
```

```output
Running test_code_does_not_write_cool_in_the_file... FAILURE
should not write 'cool' in /tmp/the_file
out> not so cool
doc:8:test_code_does_not_write_cool_in_the_file()
Running test_code_does_not_write_this_in_the_file... SUCCESS
```

## *assert_status_code*

    assert_status_code <expected_status_code> <assertion> [message]

Checks for a precise status code of the evaluation of *assertion*.

It may be usefull if you want to distinguish between several error conditions in your code.

In case of failure, the standard output and error of the evaluated *assertion* is displayed. The optional message is also displayed.

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
 expected status code 25 but was 23
doc:6:test_code_should_fail_with_code_25()
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
doc:2:test_obvious_inequality_with_assert_equals()
```

## *assert_not_equals*

    assert_not_equals <unexpected> <actual> [message]

Asserts for inequality of the two strings *unexpected* and *actual*.

```bash
test_obvious_equality_with_assert_not_equals(){
  assert_not_equals "a string" "a string" "a string should be different from another string"
}
test_obvious_inequality_with_assert_not_equals(){
  assert_not_equals a b
}

```

```output
Running test_obvious_equality_with_assert_not_equals... FAILURE
a string should be different from another string
 expected different value than [a string] but was the same
doc:2:test_obvious_equality_with_assert_not_equals()
Running test_obvious_inequality_with_assert_not_equals... SUCCESS
```

#*fake* function

    fake <command> [replacement code]

Fakes *command* and replaces it with *replacement code* (if code is specified) for the rest of the execution of your test. If no replacement code is specified, then it replaces command by one that echoes stdin of fake. This may be usefull if you need to simulate an environment for you code under test.

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

It has been asked wether using *fake* results in creating actual fakes or stubs or mocks? or may be spies? or may be they are dummies?
The first answer to this question is: it depends. The second is: read this
[great and detailed literature](https://www.google.fr/search?q=fake%20mock%20stub&tbm=isch) on this subjet.

## Using stdin

Here is an exemple, parameterizing fake with its *stdin* to test that code fails when some process does not run and succeeds otherwise:

```bash
code() {
  ps a | grep apache
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

## Using a function

In a previous exemple, we faked *ps* by specifiyng code inline:

```bash
fake ps echo hello world
ps
```

```output
hello world
```

If you need to write more complex code to fake your command, you may abstract this code in a function:

```bash
_ps() {
  echo hello world
}
fake ps _ps
ps
```

```output
hello world
```

Be carefull however that your *_ps* function is not exported to sub-processes. It means that, depending on how your code under test works, *_ps* may not be defined in the context where *ps* will be called. For instance:

```bash
_ps() {
  echo hello world
}
fake ps _ps

bash -c ps
```

```output
bash: line 1: _ps: command not found
```

It depends on your code under test but it is safer to just export functions needed by your fake so that they are available in sub-processes:

```bash
_ps() {
  echo hello world
}
export -f _ps
fake ps _ps

bash -c ps
```

```output
hello world
```

*fake* is also limited by the fact that it defines a *bash* function to
override the actual command. In some context the command can not be
overriden by a function. For instance if your code under test relies on *exec* to launch *ps*, *fake* will have no effect.

## *fake* parameters

*fake* stores parameters given to the fake in the global variable *FAKE_PARAMS* so that you can use them inside your fake.

It may be usefull if you need to adapt the behavior on the given parameters.

It can also help in asserting the values of these parameters... but this may be quite tricky.

For instance, in our previous code that checks apache is running, we have an issue since our code does not use *ps* with the appropriate parameters. So we will try to check that parameters given to ps are *ax*.

To do that, the first naive approch would be:

```bash
code() {
  ps a | grep apache
}

test_code_gives_ps_appropriate_parameters() {
  _ps() {
    cat <<EOF
  PID TTY          TIME CMD
13525 pts/7    00:00:01 bash
24162 pts/7    00:00:00 ps
 8387 ?            0:00 /usr/sbin/apache2 -k start
EOF
    assert_equals ax "$FAKE_PARAMS"
  }
  export -f _ps
  fake ps _ps

  code >/dev/null
}
```

This test calls *code*, which calls *ps*, which is actually implemented by *_ps*. Since *code* does not use *ax* but only *a* as parameters, this test should fail. But...

```output
Running test_code_gives_ps_appropriate_parameters... SUCCESS
```

The problem here is that *ps* fail (because of the failed *assert_equals* assertion). But *ps* is piped with *grep*:

```shell
code() {
  ps a | grep apache
}
```

With bash, the result code of a pipeline equals the result code of the last command of the pipeline. The last command is *grep* and since grep succeeds, the failure of *_ps* is lost and our test succeeds.

An alternative may be to activate bash *pipefail* option but this may introduce unwanted side effects. We can also simply not output anything in *_ps* so that *grep* fails:

```bash
code() {
  ps a | grep apache
}

test_code_gives_ps_appropriate_parameters() {
  _ps() {
    assert_equals ax "$FAKE_PARAMS"
  }
  export -f _ps
  fake ps _ps

  code >/dev/null
}
```

The problem here is that we use a trick to make the code under test fail but the
failure has nothing to do with the actual *assert_equals* failure. This is really
bad, don't do that.

Moreover, *assert_equals* output is captured by *ps* and this just messes with the display of our test results:

```output
Running test_code_gives_ps_appropriate_parameters... 
```

The only correct alternative is for the fake *ps* to write *FAKE_PARAMS* in a file descriptor
so that your test can grab them after code execution and assert their value. For instance
by writing to a file:

```bash
code() {
  ps a | grep apache
}

test_code_gives_ps_appropriate_parameters() {
  _ps() {
    echo $FAKE_PARAMS > /tmp/fake_params
  }
  export -f _ps
  fake ps _ps

  code || true

  assert_equals ax "$(head -n1 /tmp/fake_params)"
}

setup() {
  rm -f /tmp/fake_params
}
```

Here our fake writes to */tmp/fake*. We delete this file in *setup* to be
sure that we do not get inapropriate data from a previous test. We assert
that the first line of */tmp/fake* equals *ax*. Also, note that we know
that *code* will fail and write this to ignore the error: `code || true`.


```output
Running test_code_gives_ps_appropriate_parameters... FAILURE
 expected [ax] but was [a]
doc:14:test_code_gives_ps_appropriate_parameters()
```

We can also compact the fake definition:

```bash
code() {
  ps a | grep apache
}

test_code_gives_ps_appropriate_parameters() {
  fake ps 'echo $FAKE_PARAMS >/tmp/fake_params'

  code || true

  assert_equals ax "$(head -n1 /tmp/fake_params)"
}

setup() {
  rm -f /tmp/fake_params
}
```

```output
Running test_code_gives_ps_appropriate_parameters... FAILURE
 expected [ax] but was [a]
doc:10:test_code_gives_ps_appropriate_parameters()
```

Finally, we can avoid the */tmp/fake_params* temporary file by using *coproc*:

```bash
code() {
  ps a | grep apache
}

test_get_data_from_fake() {
  #Fasten you seat belt...
  coproc cat
  exec {test_channel}>&${COPROC[1]}
  fake ps 'echo $FAKE_PARAMS >&$test_channel'

  code || true

  assert_equals ax "$(head -n1 <&${COPROC[0]})"
}

```

```output
Running test_get_data_from_fake... FAILURE
 expected [ax] but was [a]
doc:13:test_get_data_from_fake()
```

