{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: should postgres be a feature/option of sql, with other options like mysql?
    pgformatter
    postgres-postgres-language-server
    postgresql
    # TODO: make this a feature?
    postgrest
    # TODO: should this be the default over pgformatter, with the latter as a feature?
    sqlfluff
  ];
}
