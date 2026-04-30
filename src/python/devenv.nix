# use ENVIRONMENT_PTYHON=enable devenv shell --impure --refresh-eval-cache
{
  inputs,
  lib,
  pkgs,
  ...
}:
if (builtins.getEnv "ENVIRONMENTS_PYTHON") != ""
then {
  files = import "${inputs.files}/files.nix" {
    inherit lib;
    environment = "python";
    files = ./files;
  };

  # TODO: can these along with files be automated? Where you pass in the current
  # directory and it automatically generates the right outputs, like if it
  # detects a files dir, then adds files, or if it detects a gitignore, adds
  # that, and you can pass in the aliases?
  outputs.python = {
    aliases = ["py"];
    helixConfiguration = builtins.readFile ./languages.toml;
  };

  languages.python = {
    enable = true;

    # TODO: this only works if there is already a pyproject.toml file, but there
    # doesn't seem to be a way to create one if it doesn't exist. "files" and
    # "tasks" both run after this check. So the options are either to remove
    # this option and handle the sync separately, or else turn this on via
    # an environment variable that can checkt o see whether or not there is a
    # pyproject.toml, which is stupid, but maybe it will work
    # uv = {
    #   enable = true;
    #   sync.enable = true;
    # };

    venv.enable = true;
  };

  packages = with pkgs; [
    python314Packages.jedi-language-server
    python314Packages.pipx
    python314Packages.python-lsp-server
    python314Packages.vulture
    ruff
    taplo
    ty
    uv
  ];

  tasks."environments:python" = {
    before = ["devenv:enterShell"];
    exec = builtins.readFile ./task.nu;
    package = pkgs.nushell;
  };
}
else {}
