try { uv init --bare err> /dev/null }
uv add --dev bpython pytest out+err> /dev/null
taplo format pyproject.toml out+err> /dev/null

try {
  uv python pin out+err> /dev/null
} catch {
  uv python pin 3.13
}
