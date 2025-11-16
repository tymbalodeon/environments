set shell := ["nu", "-c"]

# Create database
[confirm("WARNING: are you sure you want to completely remove the database?")]
drop *args:
    #!/usr/bin/env nu
    ./environments/sql/scripts/drop.nu {{ args }}

# Migrate the database
@migrate *args: 
    ./environments/sql/scripts/migrate.nu {{ args }}

# Inspect the database
[no-cd]
@inspect: create
    atlas schema inspect --url {{ url }}

# Seed the database
@seed: flush
    psql mishpocha --file database/queries/seed.sql

# Flush the database
[confirm("WARNING: are you sure you want to flush all data from the database?")]
[private]
@flush: migrate
    print (pwd)
    psql mishpocha --file database/queries/flush.sql

# List table names
tables: start-postgresql
    #!/usr/bin/env nu

    psql mishpocha --command '\dt' --csv
    | from csv
    | get Name
    | to text

# Select items from the database
select table limit="10": start-postgresql
    #!/usr/bin/env nu
    # TODO add option for --csv

    psql mishpocha --command $"SELECT * FROM {{ table }} LIMIT {{ limit }};"

# Query the database
@query query csv="": start-postgresql
    psql mishpocha --command "{{ query }}" ...["{{ csv }}"]

# Stop docker daemon and postgresql server
@stop: stop-docker stop-postgresql
