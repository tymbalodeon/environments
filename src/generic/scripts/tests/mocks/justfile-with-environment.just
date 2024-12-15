# View help text
@help *recipe:
    ./scripts/help.nu {{ recipe }}

# View file annotated with version control information
[no-cd]
@annotate *filename:
    ./scripts/annotate.nu {{ filename }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# List dependencies
@deps *args:
    ./scripts/deps.nu {{ args }}

# View the diff between environments
@diff-env *args:
    ./scripts/diff-env.nu {{ args }}

# Search available `just` recipes
[no-cd]
[no-exit-message]
@find-recipe *search_term:
    ./scripts/find-recipe.nu {{ search_term }}

# View project history
[no-cd]
@history *args:
    ./scripts/history.nu {{ args }}

# Initialize direnv environment
@init *help:
    ./scripts/init.nu {{ help }}

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

# Update dependencies
@update *help:
    ./scripts/update.nu {{ help }}

# View the source code for a recipe
[no-cd]
@view-source *recipe:
    ./scripts/view-source.nu {{ recipe }}

mod python "just/python.just"

# alias for `python add`
@add *args:
    just python add {{ args }}

# alias for `python build`
@build *args:
    just python build {{ args }}

# alias for `python clean`
@clean *args:
    just python clean {{ args }}

# alias for `python coverage`
@coverage *args:
    just python coverage {{ args }}

# alias for `python install`
@install *args:
    just python install {{ args }}

# alias for `python profile`
@profile *args:
    just python profile {{ args }}

# alias for `python remove`
@remove *args:
    just python remove {{ args }}

# alias for `python run`
@run *args:
    just python run {{ args }}

# alias for `python shell`
@shell *args:
    just python shell {{ args }}

# alias for `python test`
@test *args:
    just python test {{ args }}
