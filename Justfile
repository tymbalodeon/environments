[private]
@default:
    just help

# View full help text, or for a specific recipe
@help *args:
    ./scripts/help.nu {{ args }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# Manage environments
@environment *args:
    ./scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-exit-message]
@find-recipe *args:
    ./scripts/find-recipe.nu {{ args }}

alias find := find-recipe

# View project history
@history *args:
    ./scripts/history.nu {{ args }}

# View issues
@issue *args:
    ./scripts/issue.nu {{ args }}

# View remote repository
@remote *args:
    ./scripts/remote.nu  {{ args }}

# Find/replace
@replace *args:
    ./scripts/replace.nu  {{ args }}

# View repository analytics
@stats *args:
    ./scripts/stats.nu {{ args }}

# List TODO-style comments
@todo *args:
    ./scripts/todo.nu {{ args }}

alias todos := todo

# Set helix theme
@theme *args:
    ./scripts/theme.nu {{ args }}

# View the source code for a recipe
@view-source *args:
    ./scripts/view-source.nu {{ args }}

alias src := view-source

# Create a new release
@release *args:
    ./scripts/release.nu  {{ args }}

mod environments "just/environments.just"
mod python "just/python.just"

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
alias shell := python::shell
alias sort-gitignores := environments::sort-gitignores
alias test := python::test
