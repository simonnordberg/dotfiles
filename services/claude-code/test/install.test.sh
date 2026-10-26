#!/usr/bin/env bash
# Tests for install.sh, run against a scratch HOME. Run: bash services/claude-code/test/install.test.sh
set -u
SRC="$(cd "$(dirname "$0")/.." && pwd)"
TMP=$(realpath "$(mktemp -d)")
trap 'rm -rf "$TMP"' EXIT
fails=0

expect() { # expect <name> <want> <got>
  [ "$2" = "$3" ] && return
  fails=$((fails + 1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$2" "$3"
}

# sudo and claude are stubs; HOME and git's global config live in TMP
mkdir -p "$TMP/bin" "$TMP/home/.claude/bin" "$TMP/home/.claude/hooks" "$TMP/home/.claude/agents"
printf '#!/bin/sh\nexit 0\n' >"$TMP/bin/sudo"; cp "$TMP/bin/sudo" "$TMP/bin/claude"; chmod +x "$TMP/bin/"*
install_tmp() { HOME="$TMP/home" GIT_CONFIG_GLOBAL="$TMP/gitconfig" PATH="$TMP/bin:$PATH" bash "$SRC/install.sh" >/dev/null 2>&1; }

# --- a running build keeps the files it started with: install swaps each file in, never rewrites it ---
files=(settings.json CLAUDE.md bin/wt)
for f in "$SRC"/hooks/*.sh "$SRC"/agents/*.md; do files+=("${f#"$SRC/"}"); done
declare -A fd
for f in "${files[@]}"; do echo old >"$TMP/home/.claude/$f"; exec {n}<"$TMP/home/.claude/$f"; fd[$f]=$n; done
install_tmp
for f in "${files[@]}"; do
  expect "$f is swapped in, so an open copy still reads the old file" old "$(head -n1 <&"${fd[$f]}")"
  expect "$f is installed" same "$(cmp -s "$SRC/$f" "$TMP/home/.claude/$f" && echo same)"
  mode=644; case $f in bin/* | hooks/*) mode=755 ;; esac
  expect "$f mode" "$mode" "$(stat -c %a "$TMP/home/.claude/$f")"
done
expect "no temp files left behind" "" "$(find "$TMP/home/.claude" -name '*.new.*')"

if [ "$fails" -eq 0 ]; then echo "all install tests passed"; else echo "$fails failing"; exit 1; fi
