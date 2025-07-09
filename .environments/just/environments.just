set working-directory := "../.."

# View help text
@help *args:
    .environments/scripts/environments/help.nu {{ args }}

# Update init flake and pre-commit hooks
@update *args:
    .environments/scripts/environments/update.nu {{ args }}

# Update README
@readme *args:
    .environments/scripts/environments/readme.nu {{ args }}

# Reload environment
@reload *args:
    .environments/scripts/environments/reload.nu {{ args }}

# Set all environment nushell files as executable
@set-executable *args:
    .environments/scripts/environments/set-executable.nu {{ args }}

# Sort environment .gitignore files
@sort-gitignores *args:
    .environments/scripts/environments/sort-gitignores.nu {{ args }}
