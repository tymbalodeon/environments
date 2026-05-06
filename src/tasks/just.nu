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

let recipes = (just --allow-missing --summary | split row " ")

let main_recipes = (
  $recipes
  | where {"::" not-in $in}
)

let submodule_recipes = (
  $recipes
  | where {"::" in $in}
  | each {
      |recipe|

      let parts = ($recipe | split row "::")

      {
        environment: ($parts | first)
        recipe: ($parts | last)
      }
    }
)

let main_aliases = (
  $submodule_recipes
  | where {
      |recipe|

      $recipe.recipe not-in $main_recipes and (
        $submodule_recipes.recipe
        | find $recipe.recipe
        | length
      ) == 1
    }

  | each {$"alias ($in.recipe) := ($in.environment)::($in.recipe)"}
  | to text
)

open Justfile
| append $main_aliases
| collect
| save --force Justfile

just --allow-missing --fmt --unstable
