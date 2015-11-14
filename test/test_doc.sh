#!/bin/bash

cd $(dirname $0)

doc_2_bash() {
  local doc_file=$1
  sed -e '/```bash/,/```/{//!b};d' $doc_file
}

doc_2_output() {
  local doc_file=$1
  sed -e '/```shell/,/```/{//!b};d' $doc_file
}

run_doc_tests() {
  local doc_file=$1
  $0 <(doc_2_bash $doc_file) | sed -e 's:/dev/fd/[0-9]*:doc:g'
}

test_running_doc_output_as_expected() {
  assert "diff -u <(run_doc_tests doc.md) <(doc_2_output doc.md) >&2"
}
