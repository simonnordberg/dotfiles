#!/usr/bin/env bash
# Tests for the hooks. Run: bash services/claude-code/test/hooks.test.sh
set -u
HOOKS="$(cd "$(dirname "$0")/../hooks" && pwd)"
export WT_BIN="$(cd "$(dirname "$0")/../bin" && pwd)/wt"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
TMP=$(realpath "$(mktemp -d)")
trap 'rm -rf "$TMP"' EXIT
fails=0

expect() { # expect <name> <want> <got>
  [ "$2" = "$3" ] && return
  fails=$((fails + 1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$2" "$3"
}
expect_has() { # expect_has <name> <needle> <haystack>
  case "$3" in *"$2"*) return ;; esac
  fails=$((fails + 1)); printf 'FAIL %s\n  want substring: %s\n  got: %s\n' "$1" "$2" "$3"
}
expect_lacks() { # expect_lacks <name> <needle> <haystack>
  case "$3" in *"$2"*) fails=$((fails + 1)); printf 'FAIL %s\n  unwanted substring: %s\n  got: %s\n' "$1" "$2" "$3" ;; esac
}
hook() { # hook <script> <cwd> <command>: the hook's output, then rc=<exit code>
  jq -n --arg c "$3" --arg d "$2" '{tool_name: "Bash", tool_input: {command: $c}, cwd: $d}' |
    bash "$HOOKS/$1" 2>&1
  echo "rc=$?"
}
ran() { grep -c ran "$CHECK_LOG"; }

# --- check-push.sh: a push needs a clean tree and a green wt check ---
repo=$TMP/repo; mkdir -p "$repo/.claude" "$TMP/notgit"
git -C "$repo" init -q -b main
cat >"$repo/.claude/check" <<'EOF'
#!/usr/bin/env bash
echo "ran ${1:-full}" >>"$CHECK_LOG"
echo "check output line"
[ ! -f "$CHECK_FAIL" ]
EOF
chmod +x "$repo/.claude/check"
git -C "$repo" add -A && git -C "$repo" commit -qm init
export CHECK_LOG=$TMP/check.log CHECK_FAIL=$TMP/check.fail; : >"$CHECK_LOG"

expect "non-push passes silently" "rc=0" "$(hook check-push.sh "$repo" "ls -la")"
expect "non-push runs no check" 0 "$(ran)"
expect "a commit message about pushing is not a push" "rc=0" \
  "$(hook check-push.sh "$repo" 'git commit -m "feat: run the check before git push"')"
expect_has "green push passes" "rc=0" "$(hook check-push.sh "$repo" "git push -u origin feat")"
expect "green push ran the full check" "ran full" "$(tail -1 "$CHECK_LOG")"

touch "$CHECK_FAIL"; echo change >>"$repo/README"; git -C "$repo" add -A && git -C "$repo" commit -qm change
out=$(hook check-push.sh "$repo" "git push")
expect_has "red push blocked" "rc=2" "$out"
expect_has "red push says why" "Push blocked: wt check failed" "$out"
expect_has "red push shows the check output" "check output line" "$out"
expect_has "git -C dir push checks that dir" "rc=2" "$(hook check-push.sh "$TMP/notgit" "git -C $repo push origin feat")"
expect_has "cd dir && git push checks that dir" "rc=2" "$(hook check-push.sh "$TMP/notgit" "cd $repo && git push")"
expect_has "a push behind timeout is a push" "rc=2" "$(hook check-push.sh "$repo" "git fetch && timeout 60 git push")"
expect "dry-run push is not checked" "rc=0" "$(hook check-push.sh "$repo" "git push --dry-run")"
expect "deleting a remote branch is not checked" "rc=0" "$(hook check-push.sh "$repo" "git push origin --delete old")"
expect "push outside git passes" "rc=0" "$(hook check-push.sh "$TMP/notgit" "git push")"
rm "$CHECK_FAIL"

echo x >"$repo/new.txt"
out=$(hook check-push.sh "$repo" "git push")
expect_has "dirty push blocked" "rc=2" "$out"
expect_has "dirty push says why" "uncommitted or untracked" "$out"
expect_has "dirty push lists the files" "new.txt" "$out"
rm "$repo/new.txt"

# --- format.sh: the repo's own Biome, else its Prettier, else leave it ---
export FMT_LOG=$TMP/fmt.log; : >"$FMT_LOG"
fmt() { jq -n --arg f "$1" '{tool_input: {file_path: $f}}' | bash "$HOOKS/format.sh"; echo "rc=$?"; }
fake() { # fake <dir> <tool>: a node_modules/.bin tool that logs its args and cwd
  mkdir -p "$1/node_modules/.bin"
  printf '#!/usr/bin/env bash\necho "%s $* in $PWD" >>"$FMT_LOG"\n' "$2" >"$1/node_modules/.bin/$2"
  chmod +x "$1/node_modules/.bin/$2"
}
web=$TMP/web; mkdir -p "$web/src/deep"; fake "$web" biome; fake "$web" prettier; echo '{}' >"$web/biome.json"
echo 'const a=1' >"$web/src/deep/a.ts"
expect "format rc" "rc=0" "$(fmt "$web/src/deep/a.ts")"
expect_has "format runs the repo's biome check --write" "biome check --write" "$(cat "$FMT_LOG")"
expect_has "format passes the file" "$web/src/deep/a.ts in $web" "$(cat "$FMT_LOG")"
expect_lacks "format prefers biome over prettier" "prettier" "$(cat "$FMT_LOG")"
: >"$FMT_LOG"; echo '{"a":1}' >"$web/src/x.json"; fmt "$web/src/x.json" >/dev/null
expect_has "format covers json" "biome check --write" "$(cat "$FMT_LOG")"
old=$TMP/old; mkdir -p "$old"; fake "$old" prettier; echo 'x' >"$old/a.tsx"
: >"$FMT_LOG"; fmt "$old/a.tsx" >/dev/null
expect_has "format falls back to the repo's prettier" "prettier --write $old/a.tsx" "$(cat "$FMT_LOG")"
mkdir -p "$TMP/plain"; echo 'x' >"$TMP/plain/a.ts"
: >"$FMT_LOG"; expect "format without a formatter passes" "rc=0" "$(fmt "$TMP/plain/a.ts")"
expect "format without a formatter runs nothing" "" "$(cat "$FMT_LOG")"
printf 'package x\nfunc  A() {}\n' >"$TMP/plain/a.go"; fmt "$TMP/plain/a.go" >/dev/null
expect "format gofmts go" 1 "$(grep -c '^func A() {}$' "$TMP/plain/a.go")"

if [ "$fails" -eq 0 ]; then echo "all hook tests passed"; else echo "$fails failing"; exit 1; fi
