use std assert

use ../environment.nu find-environment-file-url

let environment_files = (
  open ($env.FILE_PWD | path join mocks/environment-files.nuon)
)

let actual_url = (
  find-environment-file-url
    python
    .gitignore
    $environment_files
)

let expected_url = "https://raw.githubusercontent.com/tymbalodeon/environments/trunk/src/python/.gitignore"

 assert equal $actual_url $expected_url
