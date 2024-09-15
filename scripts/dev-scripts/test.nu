#!/usr/bin/env nu

# Run tests
def main [
  environment?: string # Run $environment tests only
  file?: string # Run only $file test for $environment
] {
  let tests = try {
    let files = if ($environment | is-empty) {
      "src/**/tests/test_*.nu"
    } else if ($file | is-empty) {
      $"src/($environment)/**/tests/test_*.nu"
    } else {
      let file = if ($file | path parse | get extension) == "nu" {
        $file
      } else {
        $"($file).nu"
      }

      let file = if (($file | path basename) | str starts-with "test_") {
        $file
      } else {
        $"test_($file)"
      }

      $"src/($environment)/**/tests/($file)"
    }

    ls ($files | into glob)
    | get name
  } catch {
    return
  }

  for test in $tests {
    print $"(ansi magenta)($test)(ansi reset)"

    nu $test

    print ""
  }
}
