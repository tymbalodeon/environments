{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    nixpkgs,
    systems,
    ...
  }: {
    packages = nixpkgs.lib.genAttrs (import systems) (
      system: let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };
      in {
        default = with pkgs;
          writers.writeNuBin
          "init" {
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [jujutsu]}"
            ];
          } (builtins.readFile ./init.nu);
      }
    );
  };
}
