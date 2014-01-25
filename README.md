**bash unit testing enterprise edition framework for professionals**

This test enterprise edition framework only works with *bash*.

# Writing unit tests

To write test, write a simple bash script. In this script:

1. source sh_test.sh
2. write test functions. Their name have to be prefixed by *test*
3. call *run_test_suite* function

See test/test_sh_test.sh for an exemple.

# Test functions

See sh_test.sh for a complete and up to date list of assert
functions. But here are some of this functions:

* fail()
* assert()
* assert_fail()
* assert_status_code()
* assert_equals()
