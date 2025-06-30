# Environments

_Environments_ is a collection of opinionated development environments for
various project types that can be easily installed, updated, and composed
together.

Available environments:

<!-- environments start -->

- c
- git
- haskell
- java
- javascript
- just
- lilypond
- markdown
- nix
- python
- rust
- toml
- tree-sitter
- typescript
- typst
- yaml
- zola

<!-- environments end -->

## Installation

_On non-NixOS systems:_ Install Nix using the Determinate Systems
[Nix Installer](https://github.com/DeterminateSystems/nix-installer).

Initialize an existing project:

<!-- `init` start -->

```sh
nix run github:tymbalodeon/environments?dir=init# --no-write-lock-file \
  init [ENVIRONMENT]...
```

<!-- `init` end -->

If [`direnv`](https://direnv.net/) is installed, the `devShell` can be activated
by running `just environment activate`.

Once installed, new environments can be added with `just environment add
[ENVIRONMENT]...` (or using the alias `just env ...`) and installed environments
can be upgraded to the lates version by running `just environment update`.
Environments can also be removed with `just environment remove [ENVIRONMENT]...`
(with no environments specified, this will remove all enviornments except the
generic one).
