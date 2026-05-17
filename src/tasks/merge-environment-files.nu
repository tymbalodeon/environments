mut merged_file = try {
  open --raw (filename)
} catch {
  ""
}

let available_environments = (available-environments)

$merged_file
| split row "# "
| where {
    not (($in | lines | first) in $available_environments)
  }
| append "\n"
| str trim
| append (
    (files)  
    | each {|environment| $"# ($environment.name)\n(open --raw $environment.file)"}
  )
| to text --no-newline
| str trim --left
| save --force (filename)
