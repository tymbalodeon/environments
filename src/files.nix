{
  environment,
  # features,
  files,
  lib,
  ...
}: let
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) last;
  inherit (lib.strings) splitString;
in let
  justfile = let
    recipes = (
      map
      (
        filename: ''
          # help text
          @${lib.removeSuffix ".nu" filename} *args:
              .environments/${environment}/scripts/${filename} {{ args }}
        ''
      )
      (builtins.attrNames (builtins.readDir "${files}/scripts"))
    );
  in
    if environment == "default" || lib.lists.length recipes == 0
    then null
    else
      lib.concatStringsSep "\n"
      (
        [''set working-directory := "../.."'']
        ++ recipes
      );
in
  (
    if justfile == null
    then {}
    else {
      ".environments/${environment}/Justfile" = {
        text = justfile;
      };
    }
  )
  // builtins.foldl'
  (a: b: a // b)
  {}
  (
    map
    (
      file: let
        filename = builtins.unsafeDiscardStringContext (
          last (splitString "files/" file)
        );
      in {
        ".environments/${environment}/${filename}" = {
          executable = lib.strings.hasPrefix "scripts/" filename;
          text = builtins.readFile "${files}/${filename}";
        };
      }
    )
    # TODO: filter out tests
    (listFilesRecursive files)
  )
