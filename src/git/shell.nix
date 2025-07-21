{pkgs, ...}: {
  packages = with pkgs; [
    cocogitto
    delta
    gh
    git
    glab
    jujutsu
    nb
    pre-commit
    python312Packages.pre-commit-hooks
    serie
    tokei
  ];
}
