{pkgs, ...}: {
  env.ENVIRONMENTS_DOCUMENTATION_ZELLIJ_LAYOUT = ./layout.kdl;

  packages = with pkgs; [
    mdbook
    yamlfmt
  ];

  tasks."environments:documentation" = {
    before = ["devenv:enterShell"];
    exec = builtins.readFile ./task.nu;
    package = pkgs.nushell;
  };
}
