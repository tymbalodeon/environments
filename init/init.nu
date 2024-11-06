def main [
  ...environments: string
  --path: string
] {
  let environments = if ($environments | is-empty) {
    [generic]
  } else {
    $environments
  }

  if ($path | is-empty) {
    print (pwd)
  } else {
    print $path
  }
}
