use std assert

use ../environment.nu remove-environment-from-justfile

let source_justfile = (
  $env.FILE_PWD
  | path join mocks/justfile-with-environment.just
)

let actual_justfile = (
  remove-environment-from-justfile python (open $source_justfile)
)

let expected_justfile = (
  $env.FILE_PWD
  | path join mocks/justfile-generic.just
)

assert equal $actual_justfile (open $expected_justfile)
