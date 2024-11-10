use std assert

use ../test.nu get-test

let tests = [
  test_check__get-pre-commit-hook-names.nu
  test_deps__merge-flake-dependencies.nu
  test_domain__parse_git_origin.nu
  test_environment__merge_gitignores.nu
  test_environment__merge_justfiles.nu
  test_environment__merge_pre_commit_configs.nu
  test_find-script__get-script.nu
  test_filename__search_term.nu
  test_history__parse-args.nu
  test_search_term__function-name.nu
  test_test__get-test.nu
]

assert equal (get-test $tests) $tests

let expected_tests = [
  test_filename__search_term.nu
  test_search_term__function-name.nu
]

assert equal (get-test $tests search_term) $expected_tests

let expected_tests = [
  test_environment__merge_gitignores.nu
  test_environment__merge_justfiles.nu
  test_environment__merge_pre_commit_configs.nu
]

assert equal (get-test $tests --file environment) $expected_tests

let expected_tests = [
  test_deps__merge-flake-dependencies.nu
  test_environment__merge_gitignores.nu
  test_environment__merge_justfiles.nu
  test_environment__merge_pre_commit_configs.nu
]

assert equal (get-test $tests --function merge) $expected_tests
