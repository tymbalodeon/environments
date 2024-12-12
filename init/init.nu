use ../scripts/environment.nu "main add"

def get_environments [environments: list<string>] {
  [generic]
  | append $environments
  | str downcase
  | uniq
}

export def "main init" [
  ...environments: string
] {
  let environments = (get_environments $environments)

  main add --activate ...$environments
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
