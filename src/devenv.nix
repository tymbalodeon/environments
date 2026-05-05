{
  inputs,
  lib,
  pkgs,
  ...
}: let
  activeEnvironments = lib.lists.unique (
    (
      builtins.filter
      (
        environment:
          lib.strings.hasInfix "- environments/${environment}" devenvYaml
      )
      availableEnvironments
    )
    ++ (
      map
      (feature: "${dirOf feature} ${baseNameOf feature}")
      (
        builtins.filter
        (
          feature:
            lib.strings.hasInfix "- environments/${feature}" devenvYaml
        )
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
          && builtins.length (lib.strings.splitString "/" file) == 7
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
          && (lib.strings.hasInfix "${environmentBase}/" devenvYaml)
          && !(lib.strings.hasInfix "${environmentBase} " devenvYaml)
          && !(lib.strings.hasInfix "${environmentBase}\n" devenvYaml)
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

  environmentFiles = lib.filesystem.listFilesRecursive ./.;

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
          then lib.lists.unique (aValue ++ bValue)
          else bValue
      )
      b
    );

  parentDirName = file: baseNameOf (dirOf (dirOf file));
in
  mergeAttrsConcatLists {
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
        lib.lists.unique (
          builtins.filter
          (environment: builtins.elem environment activeEnvironments)
          (
            map (file: parentDirName file)
            (builtins.filter
              (file: baseNameOf file == "Justfile")
              environmentFiles)
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
                '${builtins.toJSON (availableEnvironments ++ availableFeatures)}'
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
