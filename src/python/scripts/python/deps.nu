#!/usr/bin/env nu

export def get-dependencies [
  --dev
  --prod
] {
  let pyproject_data = (open pyproject.toml)

  mut dependencies = {
    dev: []
    prod: [] 
  }

  if $dev or not $prod {
    $dependencies = (
      $dependencies 
      | update dev (
          ($pyproject_data | get dependency-groups.dev)
        )
    )
  }

  if $prod or not $dev {
    $dependencies = (
      $dependencies 
      | update prod (
          ($pyproject_data | get project.dependencies)
        )
    )
  }

  $dependencies
}

# Show application dependencies
def show-dependencies [
  --dev # Show only development dependencies
  --prod # Show only production dependencies
  --installed # Show installed dependencies (python dependencies only)
  --tree # Show installed dependencies as a tree (python dependencies only)
] {
  if $tree {
    return (uv tree)
  }
  if $installed {
    return (uv pip list)
  }

  let dependencies = (get-dependencies)

  let dependencies = if $dev {
    $dependencies.dev
  } else if $prod {
    $dependencies.prod
  } else {
    $dependencies
  }

  bat --language env ($dependencies | to text)
}
