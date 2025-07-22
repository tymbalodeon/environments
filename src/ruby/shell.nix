{pkgs, ...}: {
  packages = with pkgs; [
    ruby
  ];

  shellHook = "
    gem_bin_paths=$(
      nu -c '
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
