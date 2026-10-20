#!/usr/bin/env bash
# PostToolUse(Edit|Write): format the file with the repo's own formatter, the one CI checks.
f=$(jq -r '.tool_input.file_path // empty'); [ -n "$f" ] && [ -f "$f" ] || exit 0

node_tool() { # node_tool <name>: nearest node_modules/.bin/<name> above the file; prints its project dir
  local d
  d=$(dirname "$f")
  while :; do
    [ -x "$d/node_modules/.bin/$1" ] && { printf '%s\n' "$d"; return 0; }
    [ "$d" = / ] && return 1
    d=$(dirname "$d")
  done
}

case "$f" in
  *.go) gofmt -w "$f" ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.jsonc|*.css|*.astro|*.vue|*.svelte|*.graphql)
    if root=$(node_tool biome); then
      (cd "$root" && node_modules/.bin/biome check --write --no-errors-on-unmatched --files-ignore-unknown=true "$f") >/dev/null 2>&1
    elif root=$(node_tool prettier); then
      (cd "$root" && node_modules/.bin/prettier --write "$f") >/dev/null 2>&1
    fi ;;
  *.py) ruff format "$f" 2>/dev/null ;;
  *.rs) rustfmt "$f" 2>/dev/null ;;
esac
exit 0
