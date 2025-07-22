# Configuration

Some environments include configuration options that can be set in the
`.environments/environments.toml` file. These options are documented below, with
the default values shown.

## default

```toml
[[environments]]
name = "default"
todo.exclude_paths = [] # paths or globs to ignore in `just todo`
```

## python

```toml
[[environments]]
name = "python"
root = "" # The directory containing `pyproject.toml`
```

## ruby

```toml
[[environments]]
name = "ruby"
root = "" # The directory containing `Gemfile`
```
