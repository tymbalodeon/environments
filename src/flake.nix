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
                  shell = let
                    path = ./${environment}/shell.nix;
                  in
                    if builtins.pathExists path
                    then import path {inherit pkgs;}
                    else {};

                  toolchain =
                    pkgs.rust-bin.fromRustupToolchainFile
                    ./rust/toolchain.toml;
                in
                  if environment == "rust"
                  then
                    shell
                    // {
                      packages = with pkgs; [
                        rust-analyzer-unwrapped
                        toolchain
                      ];

                      shellHook = ''
                        export RUST_SRC_PATH=${toolchain}/lib/rustlib/src/rust/library
                      '';
                    }
                  else shell
              )
          )
      );
  };
}
