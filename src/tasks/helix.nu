let configurations = (language-configurations)

if ($configurations | is-empty) {
  return
}

if (".helix" | path type) == file {
  rm .helix
}

if not (".helix" | path exists) {
  ^mkdir --parents .helix
}

$configurations
| save --force .helix/languages.toml

(
  taplo format
    .helix/languages.toml
    out+err> /dev/null
)
