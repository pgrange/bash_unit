#!/usr/bin/env bash

TEST_PATTERN='```test'
OUTPUT_PATTERN='```output'
LANG=C.UTF-8

export STICK_TO_CWD=true
BASH_UNIT="eval FORCE_COLOR=false ./bash_unit"

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
    ((++block))
    run_doc_test  $remaining $swap |& sed '$a\' | work_around_github_action_problem > $test_output$block
    doc_to_output $remaining $swap > $expected_output$block
    eval 'function test_block_'"$(printf %02d $block)"'() {
        assert "diff -u '"$expected_output$block"' '"$test_output$block"'"
      }'
  done
}

work_around_github_action_problem() {
  # I have no idea what is happening with these broken pipes on github actions
  grep -v '^/usr/bin/grep: write error: Broken pipe$'
}

function run_doc_test() {
  local remaining="$1"
  local swap="$2"
  $BASH_UNIT <(cat "$remaining" | _next_code "$swap") \
  | clean_bash_unit_running_header \
  | clean_bash_pseudo_files_name \
  | clean_bash_unit_overall_result
  cat "$swap" > "$remaining"
}

function clean_bash_unit_running_header() {
  tail -n +2
}

function clean_bash_pseudo_files_name() {
  sed -e 's:/dev/fd/[0-9]*:doc:g'
}

function clean_bash_unit_overall_result() {
  sed '$d'
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
