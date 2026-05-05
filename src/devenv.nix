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
    ++ defaultEnvironments
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

  devenvYaml = builtins.readFile "${inputs.project}/devenv.yaml";

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
          then aValue ++ bValue
          else bValue
      )
      b
    );
in
  mergeAttrsConcatLists {
    packages = with pkgs; [
      fd
      taplo
    ];

    tasks = let
      activeFiles = let
        environmentName = first: last:
          if builtins.elem last availableEnvironments
          then last
          else first;
      in
        baseName:
          builtins.toJSON (map (file: let
              environment = environmentName first last;
              first = parentDir file;
              last = baseNameOf (dirOf file);
            in {
              inherit environment file;

              name =
                if builtins.elem last availableEnvironments
                then last
                else "${first} ${last}";
            })
            (builtins.filter
              (file: let
                environment = environmentName first last;
                first = parentDir file;
                last = baseNameOf (dirOf file);
              in
                baseNameOf
                file
                == baseName
                && builtins.elem environment activeEnvironments)
              environmentFiles));

      activeJustModuleNames = builtins.toJSON (
        lib.lists.unique (
          builtins.filter
          (environment: builtins.elem environment activeEnvironments)
          (
            map (file: parentDir file)
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

      environmentFiles = lib.filesystem.listFilesRecursive ./.;
      parentDir = file: baseNameOf (dirOf (dirOf file));
    in {
      "environments:gitignore" =
        {
          exec =
            # nusehll
            ''
              def gitignores [] {
                '${activeFiles ".gitignore"}'
                | from json
              }
            ''
            + builtins.readFile ./tasks/gitignore.nu;
        }
        // defaultTaskSettings;

      "environments:helix" =
        {
          exec =
            # nushell
            ''
              def language-configurations [] {
                "${activeFiles "languages.toml"}"
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
                "${activeFiles "aliases"}"
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
