{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) flatten last length unique;
  inherit (lib.strings) hasInfix hasPrefix splitString;

  activeEnvironments = unique (
    (
      builtins.filter
      (environment: hasInfix "- environments/${environment}" devenvYaml)
      availableEnvironments
    )
    ++ (
      map
      (feature: "${dirOf feature} ${baseNameOf feature}")
      (
        builtins.filter
        (feature: hasInfix "- environments/${feature}" devenvYaml)
        availableFeatures
      )
    )
    ++ defaultEnvironments
  );

  availableFeatures =
    map (
      file: let
        environment = parentDirName file;
        feature = dirName file;
      in "${environment}/${feature}"
    )
    (
      builtins.filter
      (
        file:
          (baseNameOf file)
          == "devenv.nix"
          && length (splitString "/" file) == 7
      )
      environmentFiles
    );

  availableEnvironments = builtins.attrNames (builtins.readDir ./.);

  defaultEnvironments = [
    "default"
    "git"
    "just"
    "markdown"
    "nix"
    "toml"
    "yaml"
  ];

  devenvYaml = builtins.readFile "${inputs.project}/devenv.yaml";
  dirName = file: baseNameOf (dirOf file);

  environmentConfigurations = let
    activeEnvironmentsWithNoBase =
      builtins.filter
      (
        environment: let
          environmentBase = "- environments/${environment}";
        in
          !(builtins.elem environment defaultEnvironments)
          && (hasInfix "${environmentBase}/" devenvYaml)
          && !(hasInfix "${environmentBase} " devenvYaml)
          && !(hasInfix "${environmentBase}\n" devenvYaml)
      )
      activeEnvironments;
  in
    builtins.foldl'
    (a: b: mergeAttrsConcatLists a b)
    {}
    (map
      (environment:
        import
        ./${environment}/devenv.nix {inherit inputs lib pkgs;})
      (activeEnvironmentsWithNoBase ++ defaultEnvironments));

  environmentFiles = listFilesRecursive ./.;

  mergeAttrsConcatLists = a: b:
    a
    // b
    // (
      builtins.mapAttrs
      (
        name: bValue: let
          aValue = a.${name} or null;
        in
          if builtins.isAttrs aValue && builtins.isAttrs bValue
          then mergeAttrsConcatLists aValue bValue
          else if builtins.isList aValue && builtins.isList bValue
          then unique (aValue ++ bValue)
          else bValue
      )
      b
    );

  parentDirName = file: baseNameOf (dirOf (dirOf file));
in
  mergeAttrsConcatLists {
    files = let
      activeEnvironmentsAndFeatures =
        builtins.foldl'
        (a: b: mergeAttrsConcatLists a b)
        {}
        (
          map
          (
            environment: let
              feature = last parts;
              name = builtins.elemAt parts 0;
              parts = splitString " " environment;
            in {
              ${name}.features =
                if feature != environment
                then [feature]
                else [];
            }
          )
          activeEnvironments
        );

      environments = environment: let
        name = builtins.elemAt (builtins.attrNames environment) 0;
      in
        [name]
        ++ (
          map
          (feature: "${name}/${feature}")
          (environment.${name}.features)
        );

      environmentScripts = environment:
        builtins.filter
        (file: baseNameOf (dirOf file) == "scripts")
        (listFilesRecursive ./${environment}/scripts);

      justfile = environments:
        mergeAttrsConcatLists (
          map
          (
            environment: {
              ".environments/${environment.baseEnvironment}/Justfile" = let
                recipes = (
                  map
                  (
                    filename: let
                      helpText = let
                        match =
                          builtins.match
                          ".*(# .*\n)(export )?(def main).*"
                          (builtins.readFile filename);
                      in
                        if match != null && length match > 0
                        then builtins.elemAt match 0
                        else "";

                      recipe = last (splitString "/" filename);
                    in
                      helpText
                      + ''
                        @${lib.removeSuffix ".nu" recipe} *args:
                            .environments/${environment.baseEnvironment}/scripts/${recipe} {{ args }}
                      ''
                  )
                  (
                    flatten (
                      map
                      (environment: environmentScripts environment)
                      (environments environment)
                    )
                  )
                );
              in [
                (
                  if environment.name == "default" || length recipes == 0
                  then ""
                  else
                    lib.concatStringsSep "\n"
                    (
                      [
                        ''
                          set working-directory := "../.."

                          [private]
                          @_: help
                        ''
                      ]
                      ++ recipes
                    )
                )
              ];
            }
          )
          environments
        );

      scripts = environment:
        builtins.foldl'
        (a: b: a // b)
        {}
        (
          map
          (
            file: let
              filename = builtins.unsafeDiscardStringContext (
                last (splitString "${environment.path}/" file)
              );
            in {
              ".environments/${environment.baseEnvironment}/${filename}" = {
                executable = hasPrefix "scripts/" filename;
                text = builtins.readFile file;
              };
            }
          )
          (flatten (
            map
            (environment: environmentScripts environment)
            (environments environment)
          ))
        );
    in
      builtins.foldl'
      (a: b: a // b)
      {}
      (
        # TODO: mapattrs?
        map
        (
          environment: let
            baseEnvironment = builtins.elemAt parts 0;

            path = let
              feature = last parts;
            in
              if baseEnvironment != feature
              then "${baseEnvironment}/${feature}"
              else baseEnvironment;

            parts = splitString " " environment.name;
          in let
            parsedEnvironment = {
              inherit baseEnvironment path;

              features = environment.features;
              name = environment.name;
            };
          in
            # (justfile parsedEnvironment) //
            (scripts parsedEnvironment)
        )
        activeEnvironmentsAndFeatures
      );

    packages = with pkgs; [
      fd
      taplo
    ];

    tasks = let
      activeFiles = baseName: (
        map
        (file: let
          environment =
            if builtins.elem feature activeEnvironments
            then feature
            else last;

          feature = "${first} ${last}";
          first = parentDirName file;
          last = dirName file;
        in {
          inherit environment file;

          name =
            if builtins.elem last availableEnvironments
            then last
            else "${first} ${last}";
        })
        (
          builtins.filter
          (file: let
            environment =
              if builtins.elem feature activeEnvironments
              then feature
              else if builtins.elem dir activeEnvironments
              then dir
              else "";

            feature = "${parent} ${dir}";
            parent = parentDirName file;
            dir = dirName file;
          in
            baseNameOf
            file
            == baseName
            && environment != "")
          environmentFiles
        )
      );

      activeJustModuleNames = builtins.toJSON (
        unique
        (
          map
          (environment: environment.name)
          (
            builtins.filter
            (environment:
              environment.name != "default" && environment.numberOfScripts > 0)
            (
              map
              (
                environmentOrFeature: let
                  environment =
                    if hasInfix " " environmentOrFeature
                    then let
                      parts = splitString " " environmentOrFeature;
                    in "${builtins.elemAt parts 0} ${builtins.elemAt parts 1}"
                    else environmentOrFeature;

                  numberOfScripts = length (
                    builtins.attrNames (
                      builtins.readDir ./${environment}/scripts
                    )
                  );
                in {
                  inherit numberOfScripts;

                  name = environment;
                }
              )
              activeEnvironments
            )
          )
        )
      );

      defaultTaskSettings = {
        before = ["devenv:enterShell"];
        package = pkgs.nushell;
      };
    in {
      "environments:gitignore" =
        {
          exec =
            # nusehll
            ''
              def available-environments [] {
                '${
                builtins.toJSON (availableEnvironments ++ availableFeatures)
              }'
                | from json
              }

              def gitignores [] {
                '${builtins.toJSON (activeFiles ".gitignore")}'
                | from json
              }
            ''
            + builtins.readFile ./tasks/gitignore.nu;
        }
        // defaultTaskSettings;

      "environments:helix" = let
        configurations = let
          readFromTOML = file: fromTOML (builtins.readFile file);
        in
          builtins.toJSON (
            builtins.foldl'
            (a: b: mergeAttrsConcatLists a b)
            {}
            ((
                map
                (file: readFromTOML file)
                (map (file: file.file) (activeFiles "languages.toml"))
              )
              ++ (
                let
                  file = "${inputs.project}/.helix/languages.toml";
                in
                  if builtins.pathExists file
                  then [(readFromTOML file)]
                  else []
              ))
          );
      in
        {
          exec =
            # nushell
            ''
              def language-configurations [] {
                "${configurations}"
                | from json
              }
            ''
            + builtins.readFile ./tasks/helix.nu;
        }
        // defaultTaskSettings;

      "environments:just" =
        {
          exec =
            # nushell
            ''
              def default-justfile [] {
                "${./default/Justfile}"
              }

              def modules [] {
                "${activeJustModuleNames}"
                | from json
              }

              def aliases [] {
                "${builtins.toJSON (activeFiles "aliases")}"
                | from json
                | append (
                    fd aliases .environments
                    | lines
                    | each {
                        {
                          environment: ($in | path dirname | path basename)
                          file: $in
                        }
                      }
                )
              }
            ''
            + builtins.readFile ./tasks/just.nu;
        }
        // defaultTaskSettings;
    };
  }
  environmentConfigurations
