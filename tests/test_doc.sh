#!/bin/bash

TEST_PATTERN='```test'
OUTPUT_PATTERN='```output'
LANG=C.UTF-8

export FORCE_COLOR=false
export STICK_TO_CWD=true
BASH_UNIT="eval ./bash_unit"
#BASH_UNIT="eval FORCE_COLOR=false ./bash_unit"

prepare_tests() {
  mkdir /tmp/$$
  local block=0
  local remaining=/tmp/$$/remaining
  local swap=/tmp/$$/swap
  local test_output=/tmp/$$/test_output
  local expected_output=/tmp/$$/expected_output
  cat README.adoc > $remaining

  while grep -E '^'"$TEST_PATTERN"'$' $remaining >/dev/null
  do
    block=$(($block+1))
    run_doc_test  $remaining $swap |& sed '$a\' > $test_output$block
    doc_to_output $remaining $swap > $expected_output$block
    eval 'function test_block_'"$block"'() {
        assert "diff -u '"$expected_output$block"' '"$test_output$block"'"
      }'
  done
}

function run_doc_test() {
  local remaining="$1"
  local swap="$2"
  $BASH_UNIT <(
    cat "$remaining" | _next_code "$swap"
  ) | tail -n +2 | sed -e 's:/dev/fd/[0-9]*:doc:g' 
  cat "$swap" > "$remaining"
}

function doc_to_output() {
  local remaining="$1"
  local swap="$2"
  cat "$remaining" | _next_output "$swap"
  cat "$swap" > "$remaining"
 }

function _next_code() {
  local remaining="$1"
  _next_quote_section "$TEST_PATTERN" "$remaining"
}

function _next_output() {
  local remaining="$1"
  _next_quote_section "$OUTPUT_PATTERN" "$remaining"
}

function _next_quote_section() {
  local quote_pattern=$1
  local remaining=$2
  sed -E '1 , /^'"$quote_pattern"'$/ d' |\
  sed -E '
  /^```$/ , $ w/'"$remaining"'
  1,/^```$/ !d;//d
  '
}

# change to bash_unit source directory since we should be in
# test subdirectory
cd ..
prepare_tests
