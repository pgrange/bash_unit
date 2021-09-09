sh entrypoint.sh ubuntu_tty
---------------------------

`./bash_unit "./tests/test_core.sh"`
> ./bash_unit: line 238: LANG: unbound variable

sh entrypoint.sh ubuntu
-----------------------

`./bash_unit "./tests/test_core.sh"`
> ./bash_unit: line 273: FORCE_COLOR: unbound variable

And then stops !

github runner
-------------

`./bash_unit "./tests/test_core.sh"`
> ./bash_unit: line 273: FORCE_COLOR: unbound variable
> /usr/bin/grep: write error: Broken pipe
> ./bash_unit: line 291: echo: write error: Broken pipe

`./bash_unit "./tests/test_doc.sh"`
> 	Running test_block_1 ... FAILURE
> out> --- /tmp/3578/expected_output1	2021-09-12 14:47:07.752527312 +0000
> out> +++ /tmp/3578/test_output1	2021-09-12 14:47:07.748527106 +0000
> out> @@ -1,3 +1,6 @@
> out> +/usr/bin/grep: write error: Broken pipe
> out> +/usr/bin/grep: write error: Broken pipe
> out> +/usr/bin/grep: write error: Broken pipe

---

I am a bit confused, although all unit tests run fine on my machine _(Ubuntu 20.04.3 LTS)_.

They fail in ubuntu docker container :

Running tests in ./tests/test_core.sh
./bash_unit: line 273: FORCE_COLOR: unbound variable

Some unit tests are failling :
> ./bash_unit: line 238: LANG: unbound variable

Caused by `FORCE_COLOR` and `LANG` global variables not existing in the github workflow container for some reason.

./bash_unit: line 273: FORCE_COLOR: unbound variable

But when I try to make them nullable with this syntax `${FORCE_COLOR:-}` `${LANG:-}` then `test_core` and `test_doc` fail with this error :
> /usr/bin/grep: write error: Broken pipe
