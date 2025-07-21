{pkgs, ...}: {
  packages = with pkgs; [
    ruby
  ];

  shellHook = "export PATH=$PATH:$GEM_PATH";
}
