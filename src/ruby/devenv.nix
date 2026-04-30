{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "ruby";
    files = ./files;
  };

  languages.ruby.enable = true;

  packages = with pkgs; [
    ruby
    ruby-lsp
    rubyPackages.rubocop
    rubyPackages.solargraph
  ];

  # TODO: can this be automatically generated based on discovering a task.nu file?
  tasks."environments:ruby" = {
    before = ["devenv:enterShell"];
    exec = builtins.readFile ./task.nu;
    package = pkgs.nushell;
  };

  # TODO: see if this is still necessary with devenv
  # FIXME: this should be in the env section!
  # tasks."environments:ruby" = {
  #   exec =
  #     # ruby
  #     ''        gem_bin_paths=$(
  #         ${pkgs.nushell}/bin/nu -c '
  #           let bin_path = (
  #             $env.HOME
  #             | path join .local/share/gem/ruby
  #           )

  #           if ($bin_path | path exists) {
  #             ls $bin_path
  #             | get name
  #             | each {ls $in | where name =~ /bin$}
  #             | flatten
  #             | get name
  #             | str join :
  #           }
  #         '
  #       )

  #       export PATH=$PATH:$gem_bin_paths
  #     '';
  # };
}
