{pkgs, ...}: {
  packages = with pkgs; [
    ruby
  ];

  shellHook = "export PATH=$PATH:$HOME/.local/share/gem/bin";
}
