use std assert

use ../test.nu get-tests

let tests = [
  scripts/environments/tests/test-build--get-outdated-files.nu
  src/generic/scripts/tests/test-check--get-pre-commit-hook-names.nu
  src/generic/scripts/tests/test-dependencies--merge-flake-dependencies.nu
  src/generic/scripts/tests/test-domain--parse-git-origin.nu
  src/generic/scripts/tests/test-environment--merge-gitignores.nu
  src/generic/scripts/tests/test-environment--merge-justfiles.nu
  src/generic/scripts/tests/test-environment--merge-pre-commit-configs.nu
  src/generic/scripts/tests/test-find-script--get-script.nu
  src/generic/scripts/tests/test-history--parse-args.nu
  src/generic/scripts/tests/test-test--get-test.nu
]

let filters = {
  file: null
  function: null
  module: null
}

assert equal (get-tests $tests $filters) $tests

let expected_tests = [
  src/generic/scripts/tests/test-dependencies--merge-flake-dependencies.nu
  src/generic/scripts/tests/test-environment--merge-gitignores.nu
  src/generic/scripts/tests/test-environment--merge-justfiles.nu
  src/generic/scripts/tests/test-environment--merge-pre-commit-configs.nu
]

assert equal (get-tests $tests $filters merge) $expected_tests

let filters = {
  file: environment
  function: null
  module: null
}

let expected_tests = [
  src/generic/scripts/tests/test-environment--merge-gitignores.nu
  src/generic/scripts/tests/test-environment--merge-justfiles.nu
  src/generic/scripts/tests/test-environment--merge-pre-commit-configs.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: null
  function: merge
  module: null
}

let expected_tests = [
  src/generic/scripts/tests/test-dependencies--merge-flake-dependencies.nu
  src/generic/scripts/tests/test-environment--merge-gitignores.nu
  src/generic/scripts/tests/test-environment--merge-justfiles.nu
  src/generic/scripts/tests/test-environment--merge-pre-commit-configs.nu
]

assert equal (get-tests $tests $filters) $expected_tests


let filters = {
  file: null
  function: null
  module: environments
}

let expected_tests = [
  scripts/environments/tests/test-build--get-outdated-files.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: history
  function: null
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test-history--parse-args.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: null
  function: parse-git-origin
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test-domain--parse-git-origin.nu
]

assert equal (get-tests $tests $filters) $expected_tests

let filters = {
  file: dependencies
  function: merge
  module: generic
}

let expected_tests = [
  src/generic/scripts/tests/test-dependencies--merge-flake-dependencies.nu
]

assert equal (get-tests $tests $filters) $expected_tests
