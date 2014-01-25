**bash unit testing enterprise edition framework for professionals**

This test enterprise edition framework only works with *bash*.

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
