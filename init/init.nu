def get_environments [environments: list<string>] {
  [generic]
  | append $environments
  | str downcase
  | uniq
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
  mkdir $path
  cd $path

  main init ...$environments
}

def main [] {}
