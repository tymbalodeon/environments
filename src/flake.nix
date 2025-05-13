{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: {
    devShells =
      nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "x86_64-linux"
      ] (
        system: let
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system;
          };
        in
          nixpkgs.lib.genAttrs
          (builtins.attrNames (builtins.readDir ./.))
          (
            environment:
              pkgs.mkShellNoCC (
                import ./${environment}/nix/${environment}.nix {inherit pkgs;}
              )
          )
      );
  };
}
