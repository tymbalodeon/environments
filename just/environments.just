# View help text
@_help *recipe:
    ../scripts/environments/help.nu {{ recipe }}

# Build dev environments
@build *args:
    ../scripts/environments/build.nu {{ args }}

# Preview dev environments
@preview *args:
    ../scripts/environments/preview.nu {{ args }}
