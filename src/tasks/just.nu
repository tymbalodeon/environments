let module_declarations = (
  modules 
  | each {$"mod ($in) \".environments/($in)/Justfile\""}
  | to text
)

let alias_recipes = (
  aliases
  | where {$in.environment in (modules)}
  | each {
      |alias|

      let environment = $alias.environment

      open $alias.file
      | lines
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

open (default-justfile)
| append $module_declarations
| append $alias_recipes
| save --force Justfile

just --fmt --unstable
