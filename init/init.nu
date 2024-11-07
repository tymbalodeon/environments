def get_environments [environments: list<string>] {
  if ($environments | is-empty) {
    [generic]
  } else {
    $environments
  }
}

def "main init" [
  ...environments: string
] {
  let environments = (get_environments $environments)

  environment add ...$environments
}

def "main new" [
  path: string
  ...environments: string
] {
  let environments = (get_environments $environments)

  mkdir $path
  cd $path

  main init ...$environments
}

def main [] {}
