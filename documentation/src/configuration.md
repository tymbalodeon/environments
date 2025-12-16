# Configuration

Some environments include configuration options that can be set in the `.environments/environments.toml` file. These options are documented below, with the default values shown.

## `just` output

Running `just` will display a list of available commands. Commands can be hidden (but will still be callable) by adding the setting `hide = true` to an environment configuration. Commands for the default environments can be hidden by adding the global setting `hide_default = true`.

Every environment comes with its own `help` recipe. These can all be hidden from the output of `just` by adding the global setting `hide_help = true`.

To view hidden help text without updating the `.environments/environments.toml` file, run `just help --all`.

## Global options

```toml
hide_default = true # Hide commands for default environments in `just` output
hide_help = true # Hide help recipes in `just`output
```

## Environment options

### default

```toml
[[environments]]
name = "default"
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
