mut merged_gitignore = try {
  open .gitignore
} catch {
  ""
}

let gitignores = (gitignores)
let available_environments = (available-environments)

$merged_gitignore
| split row "# "
| where {
    |gitignore|

    let label = ($gitignore | lines | first)

    not ($label in $available_environments)
  }
| append "\n"
| str trim
| append (
    $gitignores  
    | each {|gitignore| $"# ($gitignore.name)\n(open $gitignore.file)"}
  )
| to text --no-newline
| save --force .gitignore
