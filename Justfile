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

# Manage environment
@environment *args:
    ./scripts/environment.nu {{ args }}

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

# Run tests
@test *args:
    ./scripts/test.nu {{ args }}

# Update dependencies
@update-deps *help:
    ./scripts/update-deps.nu {{ help }}

# View the source code for a recipe
[no-cd]
@view-source *recipe:
    ./scripts/view-source.nu {{ recipe }}

mod environments "just/environments.just"

# Alias for `environments build`
@build *args:
    just environments build {{ args }}

# Alias for `environments justfile`
@justfile *args:
    just environments justfile {{ args }}

# Alias for `environments pre-commit-update`
@pre-commit-update *help:
    just environments pre-commit-update {{ help }}
