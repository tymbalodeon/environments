# Configuration

Some environments include configuration options that can be set in the
`.environments/environments.toml` file. These options are documented below, with
the default values shown.

## `just` output

Running `just` will display a list of available commands. Commands can be hidden by adding the value `hide = true` to the environment configuration. Commands for all the default environments can be hidden by adding the global value `hide_default = true`.

### global

```toml
hide_default = true # Hide commands for default environments in `just` output
```

### default

```toml
[[environments]]
name = "default"
hide = true # Hide commands for environment in `just` output
todo.exclude_paths = [] # Paths or globs to ignore in `just todo`
```

### python

```toml
[[environments]]
name = "python"
hide = true # Hide commands for environment in `just` output
root = "" # The directory containing `pyproject.toml`
```

### ruby

```toml
[[environments]]
name = "ruby"
hide = true # Hide commands for environment in `just` output
root = "" # The directory containing `Gemfile`
```
