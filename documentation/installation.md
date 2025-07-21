# Installation

<!-- Add note about installing direnv -->

To get started, make sure you have [Nix](https://nixos.org/) installed, for example, using the Determinate Systems Nix installer:

```shell
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Optionally, install [direnv](https://direnv.net/), which will allow the development environment(s) to activate automatically when `cd`-ing into the project directory.

Once installed, you can initialize and activate a repository by `cd`-ing into it and running the following, specifying the name(s) of any environments you want to activate, or leaving them blank to activate the default environment only:

```shell
nix run github.com:tymbalodeon/environments?dir=init# [ENVIRONMENT]...
```

Once activated, environments can be managed via [just](https://just.systems/man/en/) and the included [nushell](https://www.nushell.sh/) scripts. Run `just environment` (or the alias `just env`) to see all available commands.
