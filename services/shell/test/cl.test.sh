#!/usr/bin/env bash
# Tests for the cl() helper in .zshrc. Run: bash services/shell/test/cl.test.sh
# cl() runs against stub claude and tmux binaries first on PATH, so nothing real starts.
set -u
ZSHRC="$(cd "$(dirname "$0")/.." && pwd)/zsh/.zshrc"
TMP=$(realpath "$(mktemp -d)")
trap 'rm -rf "$TMP"' EXIT
fails=0

expect_has() { # expect_has <name> <needle> <haystack>
  case "$3" in *"$2"*) return ;; esac
  fails=$((fails + 1)); printf 'FAIL %s\n  want substring: %s\n  got: %s\n' "$1" "$2" "$3"
}
expect_lacks() { # expect_lacks <name> <needle> <haystack>
  case "$3" in *"$2"*) fails=$((fails + 1)); printf 'FAIL %s\n  unwanted substring: %s\n  got: %s\n' "$1" "$2" "$3" ;; esac
}

mkdir -p "$TMP/bin"
for tool in claude tmux; do
  printf '#!/usr/bin/env bash\necho "%s $*" >>"$TMP/calls.log"\n' "$tool" >"$TMP/bin/$tool"
  chmod +x "$TMP/bin/$tool"
done
sed -n '/^cl() {/,/^}/p' "$ZSHRC" >"$TMP/cl.zsh"
[ -s "$TMP/cl.zsh" ] || { echo "FAIL cl() not found in $ZSHRC"; exit 1; }

run_cl() { # run_cl <TMUX value> [args]: the stubbed calls cl made
  local tmux_env=$1; shift
  : >"$TMP/calls.log"
  PATH="$TMP/bin:$PATH" TMUX=$tmux_env TMP=$TMP zsh -c 'source "$TMP/cl.zsh"; cl "$@"' cl "$@" >/dev/null 2>&1
  cat "$TMP/calls.log"
}

in_tmux=$(run_cl /tmp/tmux-1/default,1,0 --resume)
expect_has "in tmux: claude gets the effort flag" "--effort max" "$in_tmux"
expect_has "in tmux: caller args are passed" "--resume" "$in_tmux"
expect_lacks "in tmux: cl passes no model" "--model" "$in_tmux"

out_tmux=$(run_cl "" --resume)
expect_has "outside tmux: the session command has the effort flag" "--effort 'max'" "$out_tmux"
expect_lacks "outside tmux: cl passes no model" "--model" "$out_tmux"

user_model=$(run_cl /tmp/tmux-1/default,1,0 --model opus)
expect_has "a caller's own --model still goes through" "--model opus" "$user_model"

[ "$fails" -eq 0 ] && echo "all cl tests passed" || { echo "$fails failure(s)"; exit 1; }
