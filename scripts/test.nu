#!/usr/bin/env nu

# Run tests
def main [
  search_term?: string # Run tests matching $search_term only
  --file: string # Run tests in $file only
] {
  let tests = (ls **/tests/**/test_*.nu)

  let tests = if ($file | is-not-empty) {
    $tests
    | filter {|file| ($file.name | path basename) == $file}
  } else if ($search_term | is-not-empty) {
    $tests
    | where name =~ $search_term
  } else {
    $tests
  }

  for test in ($tests | get name) {
    print --no-newline $"($test)..."

    try {
      nu $test

      print $"(ansi green_bold)OK(ansi reset)"
    }
  }
}
