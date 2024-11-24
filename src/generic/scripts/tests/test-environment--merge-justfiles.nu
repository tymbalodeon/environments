use std assert

use ../environment.nu merge-justfiles

let generic_justfile = ($env.FILE_PWD | path join mocks/justfile-generic.just)

let environment_justfile = (
    $env.FILE_PWD
    | path join mocks/justfile-environment.just
)

let actual_justfile = (
  merge-justfiles python $generic_justfile $environment_justfile
)

let expected_justfile = (
  $env.FILE_PWD
  | path join mocks/justfile-with-environment.just
)


assert equal $actual_justfile (open $expected_justfile | decode utf-8)
