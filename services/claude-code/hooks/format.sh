#!/usr/bin/env bash
f=$(jq -r '.tool_input.file_path // empty'); [ -z "$f" ] && exit 0
case "$f" in
  *.go) gofmt -w "$f" ;;
  *.ts|*.tsx|*.js) npx --no-install prettier --write "$f" 2>/dev/null ;;
  *.py) ruff format "$f" 2>/dev/null ;;
  *.rs) rustfmt "$f" 2>/dev/null ;;
esac
exit 0
