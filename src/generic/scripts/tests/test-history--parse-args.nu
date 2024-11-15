use std assert

use ../history.nu parse-args

let args = [
  --option1
  value
  --option2
  ""
  --option3
  "true"
  --option4
  "false"
]

let expected_args = [
  --option1
  value
  --option3
]

assert equal (parse-args ...$args) $expected_args
