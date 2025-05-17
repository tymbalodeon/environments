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
          activeEnvironments =
            [
              "generic"
              "nix"
              "yaml"
            ]
            ++ (
              if builtins.pathExists ./.environments.toml
              then
                (
                  builtins.fromTOML (builtins.readFile ./.environments.toml)
                ).environments
              else []
            );

          getFilenames = dir: (
            if builtins.pathExists dir
            then builtins.attrNames (builtins.readDir dir)
            else []
          );

          inactiveEnvironments = (
            builtins.filter
            (environment: !(builtins.elem environment activeEnvironments))
            (
              let
                srcDirectory = builtins.readDir environments;
                srcDirectoryItems = builtins.attrNames srcDirectory;
              in
                builtins.filter
                (item: srcDirectory.${item} == "directory")
                srcDirectoryItems
            )
          );

          mergeModuleAttrs = {
            attr,
            nullValue,
          }:
            pkgs.lib.lists.flatten
            (map (module: module.${attr} or nullValue) modules);

          modules =
            map
            (module: (import ./nix/${module} {inherit pkgs;}))
            (getFilenames ./nix);

          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system;
          };
        in {
          default = pkgs.mkShellNoCC ({
              inputsFrom =
                builtins.map
                (environment: environments.devShells.${system}.${environment})
                activeEnvironments;

              packages = mergeModuleAttrs {
                attr = "packages";
                nullValue = [];
              };

              shellHook = with pkgs;
                lib.concatLines (
                  # TODO: handle .gitignore, .pre-commit, copying files
                  [
                    ''
                      export NUTEST=${nutest}
                      pre-commit install --hook-type commit-msg --overwrite

                      ${pkgs.nushell}/bin/nu ${environments}/shell-hook.nu \
                        --active-environments "${
                        lib.concatStringsSep " " activeEnvironments
                      }" \
                        --environments-directory "${environments}" \
                        --inactive-environments "${
                        lib.concatStringsSep " " inactiveEnvironments
                      }" \
                        --local-justfiles "${
                        lib.concatStringsSep " "
                        (
                          map
                          (filename:
                            builtins.elemAt
                            (lib.strings.splitString "." filename)
                            0)
                          (getFilenames ./just)
                        )
                      }"
                    ''
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
