@default:
    just help --default

# View help text
@help *args:
    ./scripts/help.nu {{ args }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# List dependencies
@dependencies *args:
    ./scripts/dependencies.nu {{ args }}

alias deps := dependencies

# Manage environments
@environment *args:
    ./scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-cd]
[no-exit-message]
@find-recipe *search_term:
    ./scripts/find-recipe.nu {{ search_term }}

alias find := find-recipe

# View project history
[no-cd]
@history *args:
    ./scripts/history.nu {{ args }}

# View issues
@issue *args:
    ./scripts/issue.nu {{ args }}

# Create a new release
@release *preview:
    ./scripts/release.nu  {{ preview }}

# View remote repository
@remote *web:
    ./scripts/remote.nu  {{ web }}

# View repository analytics
@stats *help:
    ./scripts/stats.nu {{ help }}

# Run tests
@test *args:
    ./scripts/test.nu {{ args }}

# View the source code for a recipe
[no-cd]
@view-source *recipe:
    ./scripts/view-source.nu {{ recipe }}

alias src := view-source

mod python "just/python.just"

# alias for `python add`
[group("aliases")]
@add *args:
    just python add {{ args }}

# alias for `python build`
[group("aliases")]
@build *args:
    just python build {{ args }}

# alias for `python clean`
[group("aliases")]
@clean *args:
    just python clean {{ args }}

# alias for `python coverage`
[group("aliases")]
@coverage *args:
    just python coverage {{ args }}

# alias for `python install`
[group("aliases")]
@install *args:
    just python install {{ args }}

# alias for `python profile`
[group("aliases")]
@profile *args:
    just python profile {{ args }}

# alias for `python remove`
[group("aliases")]
@remove *args:
    just python remove {{ args }}

# alias for `python run`
[group("aliases")]
@run *args:
    just python run {{ args }}

# alias for `python shell`
[group("aliases")]
@shell *args:
    just python shell {{ args }}

# alias for `python update`
[group("aliases")]
@update *args:
    just python update {{ args }}
