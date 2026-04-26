# TODO: add space between modules and aliases

if not ("Justfile" | path exists) {
  # TODO: add the default Justfile if not exists instead of returning
  return
}

# TODO: only include aliases for environments that have module content
let aliases = (
  aliases
  | each {
      |alias|

      let environment = $alias.environment

      $alias.aliases
      | each {
        |alias|

          $"[private]
@($alias) *args:
  just ($environment) {{ args }}
"
        }
    }
  | flatten
)

let modules = (
  modules 
  | each {
      $"mod ($in) \".environments/($in)/Justfile\""
  }
)

default-justfile
| append $modules
| append $aliases
| save --force Justfile
