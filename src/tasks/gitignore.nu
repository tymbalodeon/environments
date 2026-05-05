mut merged_gitignore = try {
  open .gitignore
} catch {
  ""
}

let gitignores = (gitignores)

let available_environments = (available-environments)

$merged_gitignore = (
  $merged_gitignore
  | split row "# "
  | where {
      |gitignore|

      let label = ($gitignore | lines | first)

      not ($label in $available_environments) or $label in $gitignores.name
    }
  | str join "# "
)

for gitignore in $gitignores {
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
