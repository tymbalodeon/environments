# TODO: handle non-languages table (language-servers)

# TODO: only create if there are languages files to add!
if (".helix" | path type) == file {
  rm .helix
}

if not (".helix" | path exists) {
  ^mkdir --parents .helix
}

# TODO: is this necessary in the new system?
chmod --recursive +w .helix

let language_configurations = (
  language-configurations
  | each {open $in.file}
)

let languages = if (".helix/languages.toml" | path exists) {
  let languages = (
    open .helix/languages.toml
    | get language
    | append $language_configurations.language
    | uniq
  )

  mut merged_languages = []

  for language in $languages {
    if $language.name in $merged_languages.name {
      $merged_languages = (
        $merged_languages
        | where name != $language.name
        | append (
            $merged_languages
            | where name == $language.name
            | first
            | merge deep $language
          )
      )
    } else {
      $merged_languages = ($merged_languages | append $language)
    }
  }

  $language_configurations
  | update language ($merged_languages | uniq | sort-by name)
} else {
  $language_configurations
  | update language ($language_configurations.language | uniq | sort-by name)
}

$languages
| into record
| to toml
| save --force .helix/languages.toml

(
  taplo format
    .helix/languages.toml
    out+err> /dev/null
)
