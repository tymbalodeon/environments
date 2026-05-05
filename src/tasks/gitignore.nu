mut merged_gitignore = try {
  open .gitignore
} catch {
  ""
}

let gitignores = (gitignores)

$merged_gitignore = (
  $merged_gitignore
  | split row "\n\n"
  | where {
      |gitignore|

      let label = ($gitignore | lines | first)

      not ($label | str starts-with "# ") or (
        $label
        | str replace "# " ""
      ) in $gitignores.name
    }
  | str join "\n\n"
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
