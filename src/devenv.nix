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
    foldAttrsConcatLists (
      map
      (environment:
        import
        ./${environment}/devenv.nix {inherit inputs lib pkgs;})
      (activeEnvironmentsWithNoBase ++ defaultEnvironments)
    );

  environmentFiles = listFilesRecursive ./.;

  foldAttrs = list:
    builtins.foldl'
    (a: b: a // b)
    {}
    list;

  foldAttrsConcatLists = list:
    builtins.foldl'
    (a: b: mergeAttrsConcatLists a b)
    {}
    list;

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

  projectEnvironments =
    builtins.filter
    (environment: !(builtins.elem environment availableEnvironments))
    (
      map
      (directory: directory.name)
      (builtins.filter
        (file: file.value == "directory")
        (lib.attrsToList
          (builtins.readDir "${inputs.project}/.environments")))
    );
in
  mergeAttrsConcatLists {
    files = let
      activeEnvironmentsAndFeatures = lib.attrsToList (
        foldAttrsConcatLists (
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
        )
      );

      environmentPaths = environment:
        [
          (environment // {path = environment.name;})
        ]
        ++ (
          map
          (feature: environment // {path = "${environment.name}/${feature}";})
          (environment.value.features)
        );

      environmentScripts = environment: let
        scripts =
          map
          (file:
            environment
            // {
              inherit file;
            })
          (
            let
              filesPath =
                if lib.hasAttr "local" environment && environment.local
                then "${inputs.project}/.environments/${environment.path}/scripts"
                else ./${environment.path}/scripts;
            in
              if lib.pathExists filesPath
              then
                (
                  builtins.filter
                  (file:
                    (baseNameOf (dirOf file) == "scripts")
                    && (
                      ((baseNameOf file) != "help.nu")
                      || environment.name == "default"
                    ))
                  (listFilesRecursive filesPath)
                )
              else []
          );
      in
        if environment.name == "default" || length scripts < 1
        then scripts
        else
          scripts
          ++ [
            (environment
              // {
                text =
                  # nushell
                  ''
                    #!/usr/bin/env nu

                    use ../../default/scripts/help.nu display-aliases
                    use ../../default/scripts/help.nu display-just-help

                    # View module aliases
                    def "main aliases" [
                      --color = "auto" # When to use colored output {always|auto|never}
                      --sort-by-environment # Sort aliases by environment name
                      --sort-by-recipe # Sort recipe by original recipe name
                      --no-submodule-aliases # Don't include submodule aliases
                    ] {
                      (
                        display-aliases
                          $no_submodule_aliases
                          $sort_by_environment
                          $sort_by_recipe
                          --color $color
                          --justfile .environments/${environment.name}/Justfile
                      )
                    }

                    # View help text
                    def main [
                      recipe?: string # View help text for recipe
                      ...subcommands: string  # View help for a recipe subcommand
                      --color = "always" # When to use colored output {always|auto|never}
                    ] {
                      (
                        display-just-help
                          ${environment.name}
                          $recipe
                          $subcommands
                          --color $color
                      )
                    }
                  '';
              })
          ];

      environmentAndFeatureScripts = environment:
        flatten (
          map
          (environment: environmentScripts environment)
          (environmentPaths environment)
        );

      justfile = environment: let
        scripts = (
          builtins.foldl'
          (a: b: {
            name = b.name;

            files = let
              attrOrEmpty = x: attr:
                if lib.hasAttr attr x
                then let
                  value = x.${attr};
                in
                  if builtins.isList value
                  then value
                  else [value]
                else [];

              environmentFile = x: attrOrEmpty x "file";
              environmentFiles = x: attrOrEmpty x "files";
            in
              (environmentFile a)
              ++ (environmentFile b)
              ++ (environmentFiles a)
              ++ (environmentFiles b);

            path = a.path;
          })
          {}
          (environmentAndFeatureScripts environment)
        );
      in
        if environment.name == "default" || !(lib.hasAttr "name" scripts)
        then {}
        else {
          ".environments/${scripts.name}/Justfile".text = let
            recipes = (
              map
              (
                file: let
                  helpText = let
                    match =
                      builtins.match
                      ".*(# .*\n)(export )?(def main).*"
                      (builtins.readFile file);
                  in
                    if match != null && length match > 0
                    then builtins.elemAt match 0
                    else "";

                  recipe = last (splitString "/" file);
                in
                  helpText
                  + ''
                    @${lib.removeSuffix ".nu" recipe} *args:
                        .environments/${scripts.name}/scripts/${recipe} {{ args }}
                  ''
              )
              scripts.files
            );
          in
            if environment.name == "default" || length recipes == 0
            then ""
            else
              lib.concatLines
              (
                [
                  ''
                    set working-directory := "../.."

                    [private]
                    @_: help

                    # View help text
                    @help *args:
                        .environments/${environment.name}/scripts/help.nu {{ args }}
                  ''
                ]
                ++ recipes
              );
        };

      scripts = environment:
        foldAttrs (
          map
          (
            environment: let
              filename =
                if lib.hasAttr "file" environment
                then
                  builtins.unsafeDiscardStringContext (
                    last (splitString "${environment.path}/" environment.file)
                  )
                else "scripts/help.nu";
            in {
              ".environments/${environment.name}/${filename}" = {
                executable = hasPrefix "scripts/" filename;

                text =
                  if lib.hasAttr "text" environment
                  then environment.text
                  else builtins.readFile environment.file;
              };
            }
          )
          (environmentAndFeatureScripts environment)
        );
    in
      foldAttrs (
        map
        (environment: (justfile environment) // (scripts environment))
        (activeEnvironmentsAndFeatures
          ++ (
            map
            (environment: {
              local = true;
              name = environment;
              value.features = [];
            })
            projectEnvironments
          ))
      );

    packages = with pkgs; [
      fd
      taplo
    ];

    tasks = let
      defaultTaskSettings = {
        after = ["devenv:enterShell"];
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
            foldAttrsConcatLists (
              (
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
              )
            )
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

      "environments:justfile" = let
        aliasDeclarations = lib.concatStrings (
          map
          (
            environment:
              lib.concatLines (
                map
                (alias: ''
                  [private]
                  @${alias} *args:
                      just ${environment.environment} {{ args }}
                '')
                (
                  builtins.filter
                  (alias: alias != "")
                  (splitString "\n" (builtins.readFile environment.file))
                )
              )
          )
          (
            (activeFiles "aliases")
            ++ (
              map
              (file: {
                inherit file;

                environment = baseNameOf (dirOf file);
              })
              (
                builtins.filter
                (file: baseNameOf file == "aliases")
                (listFilesRecursive "${inputs.project}/.environments")
              )
            )
          )
        );

        activeModules =
          unique
          ((
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

                      numberOfScripts = let
                        path = ./${environment}/scripts;
                      in
                        if lib.pathExists path
                        then
                          (
                            length (
                              builtins.attrNames (
                                builtins.readDir ./${environment}/scripts
                              )
                            )
                          )
                        else 0;
                    in {
                      inherit numberOfScripts;

                      name = environment;
                    }
                  )
                  activeEnvironments
                )
              )
            )
            ++ projectEnvironments);

        moduleDeclarations =
          lib.concatLines
          (map
            (module: ''mod ${module} ".environments/${module}/Justfile"'')
            activeModules);

        justfileText = lib.strings.trim (
          lib.concatLines [
            (builtins.readFile ./default/Justfile)
            moduleDeclarations
            aliasDeclarations
          ]
        );
      in
        {
          exec =
            # nusehll
            ''
              def default-justfile-text [] {
                '${justfileText}'
              }
            ''
            + builtins.readFile ./tasks/just.nu;
        }
        // defaultTaskSettings;
    };
  }
  environmentConfigurations
