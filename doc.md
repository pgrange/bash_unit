```bash
test_can_fail() {
  fail "this test failed on purpose"
}
```

```shell
Running tests in doc
Running test_can_fail... FAILURE
this test failed on purpose
doc:test_can_fail():2
```

```bash
test_obvious_equality_with_assert_equals(){
  assert_equals a b "a should equal b"
}

test_check_root_in_passwd() {
  assert "grep root /etc/passwd" "root should be in passwd file"
}

test_check_zorglub_is_not_in_passwd() {
  assert_fail "grep zorglub /etc/passwd"
}
```

```shell
Running test_check_root_in_passwd... SUCCESS
Running test_check_zorglub_is_not_in_passwd... SUCCESS
Running test_obvious_equality_with_assert_equals... FAILURE
a should equal b
 expected [a] but was [b]
doc:test_obvious_equality_with_assert_equals():5
```
