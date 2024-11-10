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
  test_history__parse-args.nu
  test_test__get-test.nu
]
