use std assert

use ../test.nu get-tests

let tests = [
  scripts/environments/tests/test_build__get-outdated-files.nu
  src/generic/scripts/tests/test_check__get-pre-commit-hook-names.nu
  src/generic/scripts/tests/test_dependencies__merge-flake-dependencies.nu
  src/generic/scripts/tests/test_domain__parse_git_origin.nu
  src/generic/scripts/tests/test_environment__merge_gitignores.nu
  src/generic/scripts/tests/test_environment__merge_justfiles.nu
  src/generic/scripts/tests/test_environment__merge_pre_commit_configs.nu
  src/generic/scripts/tests/test_find-script__get-script.nu
  src/generic/scripts/tests/test_history__parse-args.nu
  src/generic/scripts/tests/test_test__get-test.nu
]

let filters = {
  file: null
  function: null
  module: null
}

assert equal (get-tests $tests $filters) $tests

let expected_tests = [
  src/generic/scripts/tests/test_dependencies__merge-flake-dependencies.nu
  src/generic/scripts/tests/test_environment__merge_gitignores.nu
  src/generic/scripts/tests/test_environment__merge_justfiles.nu
  src/generic/scripts/tests/test_environment__merge_pre_commit_configs.nu
]

assert equal (get-tests $tests $filters merge) $expected_tests

let filters = {
  file: environment
  function: null
  module: null
}

let expected_tests = [
  src/generic/scripts/tests/test_environment__merge_gitignores.nu
  src/generic/scripts/tests/test_environment__merge_justfiles.nu
  src/generic/scripts/tests/test_environment__merge_pre_commit_configs.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: null
  function: merge
  module: null
}

let expected_tests = [
  src/generic/scripts/tests/test_dependencies__merge-flake-dependencies.nu
  src/generic/scripts/tests/test_environment__merge_gitignores.nu
  src/generic/scripts/tests/test_environment__merge_justfiles.nu
  src/generic/scripts/tests/test_environment__merge_pre_commit_configs.nu
]

assert equal (get-tests $tests $filters) $expected_tests


let filters = {
  file: null
  function: null
  module: environments
}

let expected_tests = [
  scripts/environments/tests/test_build__get-outdated-files.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: history
  function: null
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test_history__parse-args.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: null
  function: parse_git_origin
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test_domain__parse_git_origin.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: dependencies
  function: merge
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test_dependencies__merge-flake-dependencies.nu
]

assert equal (get-tests $tests $filters) $expected_tests
