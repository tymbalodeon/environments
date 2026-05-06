{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files =
    import "${inputs.environments}/files.nix" {
      inherit lib;

      environment = "sql";
      files = ./files;
    }
    # // {
    #   ".environments/sql/Justfile".text =
    #     lib.mkForce
    #     (builtins.readFile
    #       ../files/Justfile
    #       + "\n"
    #       + builtins.readFile ./Justfile);
    # };
    ;

  packages = with pkgs; [
    atlas
    colima
    docker
    pgformatter
    postgres-language-server
    postgresql
  ];
}
