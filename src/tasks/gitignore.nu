mut merged_gitignore = try {
  open .gitignore
} catch {
  ""
}

# for environment in (
#   available-environments
#   | where {not-in (gitignores).name}
# ) {
#   # TODO: remove non-active environment gitignore items
# }

for gitignore in (gitignores) {
  let label = $"# ($gitignore.name)"

  if $label not-in $merged_gitignore {
    $merged_gitignore = (
      $merged_gitignore
      | append $label
      | append (open $gitignore.file))
  }
}

$merged_gitignore
| to text --no-newline
| save --force .gitignore
