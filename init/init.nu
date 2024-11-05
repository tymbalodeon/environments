def main [param?: string] {
  let asked_for = if ($param | is-empty) {
    "the default"
  } else {
    $param
  }

  print $"You asked for ($asked_for)"
}
