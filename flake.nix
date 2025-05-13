{
  inputs = {
    environments = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+file:./.?dir=src";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nutest = {
      flake = false;
      url = "github:vyadh/nutest";
    };
  };

  outputs = {
    environments,
    nixpkgs,
    nutest,
    ...
  }: {
    devShells =
      nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "x86_64-linux"
      ] (
        system: let
          mergeModuleAttrs = {
            attr,
            nullValue,
          }:
            pkgs.lib.lists.flatten
            (map (module: module.${attr} or nullValue) modules);

          modules =
            map (module: (import ./nix/${module} {inherit pkgs;}))
            (
              if (builtins.pathExists ./nix)
              then (builtins.attrNames (builtins.readDir ./nix))
              else []
            );

          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system;
          };
        in {
          default = pkgs.mkShellNoCC ({
              inputsFrom =
                builtins.map
                (environment: environments.devShells.${system}.${environment})
                # TODO: read this from a local dotfile so that the file can easily be updated via a script
                ["lilypond"];

              packages = with pkgs;
                [
                  alejandra
                  ansible-language-server
                  bash
                  bat
                  cocogitto
                  deadnix
                  delta
                  eza
                  fd
                  flake-checker
                  fzf
                  gh
                  git
                  glab
                  jujutsu
                  just
                  lychee
                  markdown-oxide
                  marksman
                  nb
                  nil
                  nodePackages.prettier
                  nushell
                  pre-commit
                  python312Packages.pre-commit-hooks
                  ripgrep
                  serie
                  statix
                  stylelint
                  taplo
                  tokei
                  vscode-langservers-extracted
                  yaml-language-server
                  yamlfmt
                ]
                ++ mergeModuleAttrs {
                  attr = "packages";
                  nullValue = [];
                };

              shellHook = with pkgs;
                lib.concatLines (
                  [
                    "pre-commit install --hook-type commit-msg"
                    "export NUTEST=${nutest}"
                  ]
                  ++ mergeModuleAttrs {
                    attr = "shellHook";
                    nullValue = "";
                  }
                );
            }
            // builtins.foldl'
            (a: b: a // b)
            {}
            (map
              (module: builtins.removeAttrs module ["packages" "shellHook"])
              modules));
        }
      );
  };
}
