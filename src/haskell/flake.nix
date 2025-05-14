{pkgs}: {
  packages = with pkgs; [
    fourmolu
    ghc
    haskell-language-server
  ];
}
