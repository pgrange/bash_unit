**bash unit testing enterprise edition framework for professionals**

This test enterprise edition framework only works with *bash*.

It allows you to write unit tests (functions starting with *test*),
run them and, in case of failre, displays the stack trace
with source file and line number indications to locate the problem.

# Writing unit tests

To write test, write a simple bash script. In this script:

1. source sh_test.sh
2. write test functions. Their name have to be prefixed by *test*
3. call *run_test_suite* function

See [test/test_sh_test.sh](test/test_sh_test.sh) for an exemple.

# Test functions

See sh_test.sh for a complete and up to date list of assert
functions. But here are some of this functions:

    fail [message]

Fails the test and display an optional message.

    assert <command> [message]
    
*eval* the command and asserts it does not fail. If the
the command returns a status code different from 0, the
test fails and the optional message is diplayed.
    
    assert_fail <command> [message]

*eval* the command and asserts it does fail. If the
the command returns a status code different equal to 0,
the test fails and the optional message is diplayed.

    assert_status_code <expected status> <command> [message]

*eval* the command and asserts its status code is the
*expected status code*. If the the command returns a 
status code different from the expected status code,
the test fails and the optional message is diplayed.

    assert_equals <expected> <actual> [message]
    
Compare *expected* with *actual*. If they are not equal,
the test fails and the optional message is diplayed.

# example

Let suppose you write in a file called *sample_test.sh*
in *sh_test* directory :

    #!/bin/bash

    pwd=$(cd $(dirname $0); pwd)
    source $pwd/sh_test.sh

    test_obvious_equality_with_assert_equals(){
      assert_equals a b "a should equal b"
    }

    test_check_root_in_passwd() {
      assert "grep root /etc/passwd" "root should be in passwd file"
    }

    test_check_zorglub_is_not_in_passwd() {
      assert_fail "grep zorglub /etc/passwd"
    }

    run_test_suite

Running this script will show you something like:    
It should display something like:

    # bash test_sample.sh 
    Running test test_check_root_in_passwd... SUCCESS
    Running test test_check_zorglub_is_not_in_passwd... SUCCESS
    Running test test_obvious_equality_with_assert_equals... FAILURE: a should equal b expected a but was b
    test_sample.sh:test_obvious_equality_with_assert_equals():7
    test_sample.sh:main():18
