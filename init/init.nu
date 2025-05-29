use ../scripts/environment.nu "main add"

def "main init" [...environments: string] {
  main add ...$environments
}

def main [] {}
