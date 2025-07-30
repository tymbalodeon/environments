{pkgs, ...}: {
  packages = with pkgs; [
    ruby
    ruby-lsp
    rubyPackages.rubocop
    rubyPackages.solargraph
  ];

  shellHook = "
    gem_bin_paths=$(
      ${pkgs.nushell}/bin/nu -c '
        let bin_path = (
          $env.HOME
          | path join .local/share/gem/ruby
        )

        if ($bin_path | path exists) {
          ls $bin_path
          | get name
          | each {ls $in | where name =~ /bin$}
          | flatten
          | get name
          | str join :
        }
      '
    )

    export PATH=$PATH:$gem_bin_paths
  ";
}
