{pkgs, ...}: {
  packages = with pkgs; [
    rubocop
    ruby
    ruby-lsp
    rubyPackages.solargraph
  ];

  shellHook = "
    gem_bin_paths=$(
      ${pkgs.nushell}/bin/nu -c '
        ls ~/.local/share/gem/ruby
        | get name
        | each {ls $in | where name =~ /bin$}
        | flatten
        | get name
        | str join :
      '
    )

    export PATH=$PATH:$gem_bin_paths
  ";
}
