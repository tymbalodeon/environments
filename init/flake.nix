{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems
      (system: f {pkgs = import nixpkgs {inherit system;};});

    supportedSystems = [
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    packages = forEachSupportedSystem ({pkgs}: {
      default = let
        environment =
          pkgs.writers.writeNuBin
          "environment" {} (builtins.readFile ../src/generic/scripts/environment.nu);
      in
        pkgs.writers.writeNuBin
        "init" {
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            "${pkgs.lib.makeBinPath [environment]}"
          ];
        } (builtins.readFile ./init.nu);
    });
  };
}
