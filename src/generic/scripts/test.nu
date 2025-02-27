#!/usr/bin/env nu

def filter-file [test: string file: string] {
  try {
    let name = (
      $test
      | split row "test-"
      | last
      | split row "--"
      | first
    )

    $name =~ $file
  } catch {
    false
  }
}

def filter-function [test: string function: string] {
  try {
    let name = (
      $test
      | split row "--"
      | last
    )

    $name =~ $function
  } catch {
    false
  }
}

def filter-module [test: string module: string] {
  let parent = (
    $test
    | path parse
    | get parent
  )

  $"src/($module)" in $parent or (
    $"scripts/($module)" in $parent
  )
}

export def get-tests [
  tests: list<string>
  filters: record<
    file: any,
    function: any,
    module: any,
  >
  search_term?: string
] {
  let module = $filters.module
  let file = $filters.file
  let function = $filters.function

  let tests = match $module {
    null => $tests
    _ => ($tests | filter {filter-module $in $module})
  }

  let $tests = match $file {
    null => $tests
    _ => ($tests | filter {filter-file $in $file})
  }

  let $tests = match $function {
    null => $tests
    _ => ($tests | filter {filter-function $in $function})
  }

  match $search_term {
    null => $tests
    _ => ($tests | filter {$in =~ $search_term})
  }
}

# Run tests
def main [
  search_term?: string # Run tests matching $search_term only
  --file: string  # Run tests for $file only
  --function: string # Run tests for $function only
  --module: string # Run tests for $module only
] {
  (
    nu
      --commands "use nutest; nutest run-tests"
      --include-path $env.NUTEST
  )
}
