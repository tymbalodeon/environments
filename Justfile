[private]
@default:
    just help

# View full help text, or for a specific recipe
@help *args:
    .environments/default/scripts/help.nu {{ args }}

# Check flake
@check *args:
    .environments/default/scripts/check.nu {{ args }}

# Manage environments
@environment *args:
    .environments/default/scripts/environment.nu {{ args }}

alias env := environment

# View project history
@history *args:
    .environments/default/scripts/history.nu {{ args }}

# View issues
@issue *args:
    .environments/default/scripts/issue.nu {{ args }}

# View README file
@readme *args:
    .environments/default/scripts/readme.nu  {{ args }}

# View or open recipes
@recipe *args:
    .environments/default/scripts/recipe.nu  {{ args }}

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

# Create a new release
@release *args:
    .environments/git/scripts/release.nu  {{ args }}

[private]
@doc *args:
    just documentation {{ args }}

[private]
@docs *args:
    just documentation {{ args }}

mod documentation ".environments/documentation/Justfile"
mod environments ".environments/environments/Justfile"
mod nix ".environments/nix/Justfile"

alias dev := documentation::develop
alias develop := documentation::develop
alias generate-text := environments::generate-text
alias reload := environments::reload
alias serve := documentation::serve
alias set-executable := environments::set-executable
alias sh := nix::shell
alias shell := nix::shell
alias sort-gitignores := environments::sort-gitignores
alias up := environments::update
alias update := environments::update
