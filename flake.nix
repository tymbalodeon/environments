{
  inputs = {
    devenv = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/devenv";
    };

    environments = {
      flake = false;
      url = ./src;
    };

    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";

    project = {
      flake = false;
      url = ./.;
    };

    systems.url = "github:nix-systems/default";
  };

  nixConfig = {
    extra-substituters = "https://devenv.cachix.org";
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  };

  outputs = {
    devenv,
    nixpkgs,
    systems,
    ...
  } @ inputs: {
    devShells =
      nixpkgs.lib.genAttrs (import systems)
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [./src/devenv.nix];
        };
      });
  };
}
