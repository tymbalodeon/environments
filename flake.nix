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
          inherit getFilenames;
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
              # TODO: handle aliases
                lib.concatLines (
                  [
                    ''
                      export NUTEST=${nutest}
                      pre-commit install --hook-type commit-msg --overwrite

                      for environment in ${
                        lib.concatStringsSep " " inactiveEnvironments
                      }
                      do
                        justfile=./just/''\${environment}.just
                        [[ -f $justfile ]] && rm --force $justfile

                        scripts_directory=./scripts/''\${environment}

                        [[ -d $scripts_directory ]] &&
                        sudo rm --force --recursive $scripts_directory
                      done

                      cat "${environments}/generic/Justfile" > Justfile

                      for environment in ${
                        lib.concatStringsSep " " activeEnvironments
                      }
                      do
                        [[ ''\${environment} != "generic" ]] && \
                        [[
                          -f \${environments}/''\${environment}/Justfile
                        ]] && \
                        echo \
                          "mod ''\${environment} \"just/''\${environment}.just\"" >> \
                          Justfile
                      done

                      for environment in ${
                        lib.concatStringsSep " "
                        (
                          map
                          (filename:
                            builtins.elemAt
                            (lib.strings.splitString "." filename)
                            0)
                          (getFilenames ./just)
                        )
                      }
                      do
                        echo \
                          "mod ''\${environment} \"just/''\${environment}.just\"" >> \
                          Justfile
                      done
                    ''
                  ]
                  ++ map
                  (environment: let
                    environmentPath = "${environments}/${environment}";
                  in ''
                    justfile=${environmentPath}/Justfile

                    [[ ${environment} != "generic" ]] && \
                    [[ -f $justfile ]] && \
                    cp \
                      --recursive \
                      --update \
                      ${environmentPath}/Justfile \
                      ./just/${environment}.just

                    scripts_directory=${environmentPath}/scripts/${environment}

                    [[ -d $scripts_directory ]] && \
                    cp \
                      --recursive \
                      --update \
                      ${environmentPath}/scripts/${environment} \
                      ./scripts
                  '')
                  activeEnvironments
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
