{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    nixpkgs,
    rust-overlay,
    ...
  }: {
    devShells =
      nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "x86_64-linux"
      ] (
        system:
          nixpkgs.lib.genAttrs
          (builtins.attrNames (
            builtins.listToAttrs (
              builtins.filter
              (item: item.value == "directory")
              (nixpkgs.lib.attrsToList (builtins.readDir ./.))
            )
          ))
          (
            environment: let
              mergePackages = a: b: (a // {packages = a.packages ++ b.packages;});

              pkgs = import nixpkgs {
                config.allowUnfree = true;

                overlays =
                  if environment == "rust"
                  then [rust-overlay.overlays.default]
                  else [];

                inherit system;
              };
            in
              pkgs.mkShellNoCC (
                let
                  # TODO: can only the features that are active be included?
                  featureShells = let
                    featuresPath = ./${environment}/features;
                  in
                    if builtins.pathExists featuresPath
                    then
                      builtins.foldl'
                      mergePackages
                      {packages = [];}
                      (nixpkgs.lib.lists.flatten (
                        builtins.map
                        (
                          feature: (
                            builtins.map
                            (file: import ./${environment}/features/${feature}/${file} {inherit pkgs;})
                            (builtins.filter
                              (file: nixpkgs.lib.hasSuffix "nix" file)
                              (builtins.attrNames
                                (builtins.readDir ./${environment}/features/${feature})))
                          )
                        )
                        (builtins.attrNames (builtins.readDir ./${environment}/features))
                      ))
                    else {packages = [];};

                  mainShell = let
                    path = ./${environment}/shell.nix;
                  in
                    if builtins.pathExists path
                    then import path {inherit pkgs;}
                    else {packages = [];};

                  shell = mergePackages mainShell featureShells;

                  toolchain =
                    pkgs.rust-bin.fromRustupToolchainFile
                    ./rust/toolchain.toml;
                in
                  if environment == "rust"
                  then
                    mergePackages shell {
                      packages = with pkgs; [
                        rust-analyzer-unwrapped
                        toolchain
                      ];
                    }
                    // {
                      shellHook = let
                        rust_src_path = "lib/rustlib/src/rust/library";
                      in
                        builtins.concatStringsSep
                        "\n"
                        [
                          shell.shellHook
                          "export RUST_SRC_PATH=${toolchain}/${rust_src_path}"
                        ];
                    }
                  else shell
              )
          )
      );
  };
}
