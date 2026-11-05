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

last_model() { # last_model <calls>: the value of the last --model argument, quotes stripped
  grep -o -- "--model [^ ]*" <<<"$1" | tail -1 | sed "s/^--model //; s/'//g"
}
expect() { # expect <name> <want> <got>
  [ "$2" = "$3" ] && return
  fails=$((fails + 1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$2" "$3"
}
DEFAULT_MODEL='claude-opus-4-6[1m]'
TMUX_ON=/tmp/tmux-1/default,1,0

for mode in "in tmux:$TMUX_ON" "outside tmux:"; do
  label=${mode%%:*}; tmux_env=${mode#*:}
  calls=$(run_cl "$tmux_env" --resume); calls=${calls//\'/}
  expect "$label: default model" "$DEFAULT_MODEL" "$(last_model "$calls")"
  expect_has "$label: effort flag" "--effort max" "$calls"
  expect_has "$label: caller args are passed" "--resume" "$calls"
  calls=$(run_cl "$tmux_env" --model 'claude-fable-5-1[1m]' --resume)
  expect "$label: the caller's model is the last --model" "claude-fable-5-1[1m]" "$(last_model "$calls")"
  expect_has "$label: caller args still pass with an override" "--resume" "$calls"
done

[ "$fails" -eq 0 ] && echo "all cl tests passed" || { echo "$fails failure(s)"; exit 1; }
