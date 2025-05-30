set working-directory := ".."

# View help text
@help *recipe:
    ./scripts/environments/help.nu {{ recipe }}

# Update init flake and pre-commit hooks
@update *verbose:
    ./scripts/environments/update.nu {{ verbose }}

# Update README
@readme *help:
    ./scripts/environments/readme.nu {{ help }}

# Reload environment
@reload *help:
    ./scripts/environments/reload.nu {{ help }}
