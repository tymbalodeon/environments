export def get-paths [
  paths: list<string>
  --extension: string
] {
  if ($paths | is-empty) {
    if ($extension | is-not-empty) {
      ["."]
    } else {
      ls ($"**/*.($extension)" | into glob)
      | get name
    }
  } else {
    $paths
  }
}
