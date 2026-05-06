{pkgs, ...}: {
  packages = with pkgs; [
    cocogitto
    delta
    gh
    git
    gitleaks
    glab
    jujutsu
    nb
    serie
    tokei
  ];
}
