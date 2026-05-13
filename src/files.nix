{
  environment,
  files,
  lib,
  ...
}: let
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) last;
  inherit (lib.strings) splitString;
in
  builtins.foldl'
  (a: b: a // b)
  {}
  (
    map
    (
      file: let
        filename = builtins.unsafeDiscardStringContext (
          last (splitString "scripts/" file)
        );
      in {
        ".environments/${environment}/${filename}" = {
          executable = lib.strings.hasPrefix "scripts/" filename;
          text = builtins.readFile "${files}/${filename}";
        };
      }
    )
    (listFilesRecursive files)
  )
