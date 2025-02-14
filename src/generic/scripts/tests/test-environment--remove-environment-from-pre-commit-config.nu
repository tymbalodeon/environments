use std assert

use ../environment.nu remove-environment-from-pre-commit-config

let source_pre_commit_config = (
  $env.FILE_PWD
  | path join mocks/.pre-commit-config-with-environment.yaml
)

let actual_pre_commit_config = (
  remove-environment-from-pre-commit-config python (open --raw $source_pre_commit_config)
)

let expected_pre_commit_config = (
  $env.FILE_PWD
  | path join mocks/.pre-commit-config-generic.yaml
)

assert equal $actual_pre_commit_config (open --raw $expected_pre_commit_config)
