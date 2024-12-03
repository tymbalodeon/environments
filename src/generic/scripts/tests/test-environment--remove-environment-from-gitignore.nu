use std assert

use ../environment.nu remove-environment-from-gitignore

let source_gitignore = (
  $env.FILE_PWD
  | path join mocks/.gitignore-with-environment
)

let actual_gitignore = (
  remove-environment-from-gitignore python (open $source_gitignore)
)

let expected_gitignore = (
  $env.FILE_PWD
  | path join mocks/.gitignore-generic
)

assert equal $actual_gitignore (open $expected_gitignore)
