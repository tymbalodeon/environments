def main [...environments: string] {
  let environments = if ($environments | is-empty) {
    [generic]
  } else {
    $environments
  }

  environment add --help

  print $environments
}
