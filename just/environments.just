set working-directory := "../"

# View help text
@help *recipe:
    ./scripts/environments/help.nu {{ recipe }}

# Update
@readme *args:
    ./scripts/environments/readme.nu {{ args }}
