# View help text
@_help *recipe:
    ../scripts/environments/help.nu {{ recipe }}

# Build dev environments
[no-cd]
@build *args:
    ./scripts/environments/build.nu {{ args }}
