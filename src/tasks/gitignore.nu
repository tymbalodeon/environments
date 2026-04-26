mut merged_gitignore = try {
  open .gitignore
} catch {
  ""
}

for gitignore in (gitignores) {
  let label = $"# ($gitignore.environment)"

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
