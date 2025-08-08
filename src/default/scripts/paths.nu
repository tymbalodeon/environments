export def get-paths [
  paths: list<string>
  --extension: string
] {
  if ($paths | is-empty) {
    if ($extension | is-not-empty) {
      ls ($"**/*.($extension)" | into glob)
      | get name
    } else {
      ["."]
    }
  } else {
    $paths
  }
}
