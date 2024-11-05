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
      default = pkgs.writeShellApplication {
        name = "init";
        runtimeInputs = [pkgs.nushell];
        text = "nu <(cat ${./init.nu}) \"$@\"";
      };
    });
  };
}
