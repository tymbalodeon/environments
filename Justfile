[private]
@default:
    just help

# View full help text, or for a specific recipe
@help *args:
    .environments/default/scripts/help.nu {{ args }}

# Check flake and run pre-commit hooks
@check *args:
    .environments/default/scripts/check.nu {{ args }}

# Manage environments
@environment *args:
    .environments/default/scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-exit-message]
@find-recipe *args:
    .environments/default/scripts/find-recipe.nu {{ args }}

alias find := find-recipe

# View project history
@history *args:
    .environments/default/scripts/history.nu {{ args }}

# View issues
@issue *args:
    .environments/default/scripts/issue.nu {{ args }}

# View remote repository
@remote *args:
    .environments/default/scripts/remote.nu  {{ args }}

# Find/replace
@replace *args:
    .environments/default/scripts/replace.nu  {{ args }}

# View repository analytics
@stats *args:
    .environments/default/scripts/stats.nu {{ args }}

# List TODO-style comments
@todo *args:
    .environments/default/scripts/todo.nu {{ args }}

alias todos := todo

# Set helix theme
@theme *args:
    .environments/default/scripts/theme.nu {{ args }}

# View the source code for a recipe
@source *args:
    .environments/default/scripts/source.nu {{ args }}

alias src := source

# Create a new release
@release *args:
    .environments/git/scripts/release.nu  {{ args }}

[private]
@py *args:
    just python {{ args }}

mod environments ".environments/environments/Justfile"
mod nix ".environments/nix/Justfile"
mod python ".environments/python/Justfile"

alias add := python::add
alias deps := python::dependencies
alias dependencies := python::dependencies
alias pin := python::pin
alias profile := python::profile
alias readme := environments::readme
alias reload := environments::reload
alias remove := python::remove
alias run := python::run
alias set-executable := environments::set-executable
alias sort-gitignores := environments::sort-gitignores
alias test := python::test
