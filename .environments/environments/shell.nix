{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: double check this is necessary
    clang
  ];
}
