use std assert

use ../environment.nu merge-justfiles

let generic_justfile = ($env.FILE_PWD | path join mocks/generic-justfile.just)
let expected_justfile = ($env.FILE_PWD | path join mocks/expected-justfile.just)

let environment_justfile = (
    $env.FILE_PWD
    | path join mocks/environment-justfile.just
)

let actual_justfile = (
  merge-justfiles python $generic_justfile $environment_justfile
)

assert equal $actual_justfile (open $expected_justfile | decode utf-8)
