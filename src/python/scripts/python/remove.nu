#!/usr/bin/env nu

# Remove dependencies
def main [
  ...dependencies: string # Dependencies to remove
] {
  let pyproject_data = (open pyproject.toml)
  let dependencies = ($pyproject_data | get project.dependencies)
  let dev_dependencies = ($pyproject_data | get dependency-groups.dev)

  for $dependency in $dependencies {
    if $dependency in $dev_dependencies {
      uv remove --dev $dependency
    } else if $dependency in $dependencies {
      uv remove $dependency
    }
  }
}
