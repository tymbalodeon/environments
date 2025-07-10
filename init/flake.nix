{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
        default =
          pkgs.writers.writeNuBin
          "init" {
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${pkgs.lib.makeBinPath [
                (pkgs.writers.writeNuBin
                  "environment"
                  {}
                  (builtins.readFile ../src/default/scripts/environment.nu))
              ]}"
            ];
          } (builtins.readFile ./init.nu);
      }
    );
  };
}
