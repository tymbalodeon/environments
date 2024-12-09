# Environments

_Environments_ is a collection of opinionated development environments for
various project types that can be easily installed, updated, and composed
together.

## Installation

_On non-NixOS systems:_ Install Nix using the Determinate Systems
[Nix Installer](https://github.com/DeterminateSystems/nix-installer).
Create a new project:

<!-- `new` start -->

```sh
nix run github:tymbalodeon/environments/init?dir=init# --no-write-lock-file \
  new PATH [ENVIRONMENT]...
```

<!-- `new` end -->

Initialize an existing project:

<!-- `init` start -->

```sh
nix run github:tymbalodeon/environments/init?dir=init# --no-write-lock-file \
  init PATH [ENVIRONMENT]...
```

<!-- `init` end -->

The generic environment is included by default, and will be the only one
installed if no environments are specified.

If [`direnv`](https://direnv.net/) is installed, the `devShell` can be activated
by running `just environment activate`.

Once installed, new environments can be added with
`just environment add [ENVIRONMENT]...` and installed environments can
be upgraded to the lates version by running `just environment upgrade`.
Environments can also be removed with `just environment remove [ENVIRONMENT]...`
(with no environments specified, this will remove all enviornments except the
generic one).
