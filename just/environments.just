set working-directory := ".."

# View help text
@help *recipe:
    ./scripts/environments/help.nu {{ recipe }}

# Update pre-commit hooks
@pre-commit-update *verbose:
    ./scripts/environments/pre-commit-update.nu {{ verbose }}

# Update
@readme *help:
    ./scripts/environments/readme.nu {{ help }}
