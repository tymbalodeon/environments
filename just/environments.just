set working-directory := ".."

# View help text
@help *args:
    ./scripts/environments/help.nu {{ args }}

# Update init flake and pre-commit hooks
@update *args:
    ./scripts/environments/update.nu {{ args }}

# Update README
@readme *args:
    ./scripts/environments/readme.nu {{ args }}

# Reload environment
@reload *args:
    ./scripts/environments/reload.nu {{ args }}
