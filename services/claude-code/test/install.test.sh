#!/usr/bin/env bash
# Tests for the Claude Code installer. Run: bash services/claude-code/test/install.test.sh
# Every run uses a throwaway HOME, CLAUDE_DIR and PATH so the real ~/.claude is never touched.
set -u
INSTALL="$(cd "$(dirname "$0")/.." && pwd)/install.sh"
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
expect_file() { # expect_file <name> <path>
  [ -e "$2" ] && return
  fails=$((fails + 1)); printf 'FAIL %s\n  missing: %s\n' "$1" "$2"
}
expect_no_file() { # expect_no_file <name> <path>
  [ ! -e "$2" ] && return
  fails=$((fails + 1)); printf 'FAIL %s\n  should not exist: %s\n' "$1" "$2"
}

# Fake external tools: anything the installer must not call in tests logs itself and fails.
FAKEBIN=$TMP/fakebin; mkdir -p "$FAKEBIN"; export TOOL_LOG=$TMP/tools.log; : >"$TOOL_LOG"
for tool in claude npm sudo; do
  printf '#!/usr/bin/env bash\necho "%s $*" >>"$TOOL_LOG"; exit 1\n' "$tool" >"$FAKEBIN/$tool"
  chmod +x "$FAKEBIN/$tool"
done

# A fake agent-config repo with everything the installer copies.
SRC=$TMP/agent-config
mkdir -p "$SRC/hooks" "$SRC/bin" "$SRC/agents" "$SRC/skills/x" "$SRC/skills/y"
echo '{"model":"fable"}' >"$SRC/settings.json"
echo '# global' >"$SRC/CLAUDE.md"
echo 'echo hook' >"$SRC/hooks/a.sh"
echo 'echo wt' >"$SRC/bin/wt"
echo 'reviewer' >"$SRC/agents/r.md"
echo 'x' >"$SRC/skills/x/SKILL.md"
echo 'y' >"$SRC/skills/y/SKILL.md"
git -C "$SRC" init -q -b main && git -C "$SRC" add -A && git -C "$SRC" commit -qm init
SRC_SHA=$(git -C "$SRC" rev-parse --short HEAD)

# A bare knowledge repo that can be cloned.
KSRC=$TMP/knowledge-src; mkdir -p "$KSRC"; echo '# kb' >"$KSRC/CLAUDE.md"
git -C "$KSRC" init -q -b main && git -C "$KSRC" add -A && git -C "$KSRC" commit -qm init
git clone -q --bare "$KSRC" "$TMP/knowledge.git"

fresh_claude_dir() { # fresh_claude_dir <path>: a ~/.claude with pre-existing skills and settings
  rm -rf "$1"; mkdir -p "$1/skills/keep-me" "$1/skills/old" "$1/skills/synced"
  echo 'keep' >"$1/skills/keep-me/SKILL.md"
  echo 'old' >"$1/skills/old/SKILL.md"
  echo 'keep' >"$1/skills/synced/keep.txt"
  echo '{"synced":true}' >"$1/skills/manifest.json"
  echo '{"model":"orig"}' >"$1/settings.json"
}

run_install() { # run_install <claude_dir> <agent_config_dir> <agent_config_url> <knowledge_dir> [extra env...]
  local cdir=$1 adir=$2 aurl=$3 kdir=$4; shift 4
  (
    cd "$TMP" && env -i HOME="$TMP/home" PATH="$FAKEBIN:$PATH" TOOL_LOG="$TOOL_LOG" \
      GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t \
      GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
      CLAUDE_DIR="$cdir" AGENT_CONFIG_DIR="$adir" AGENT_CONFIG_URL="$aurl" \
      KNOWLEDGE_DIR="$kdir" KNOWLEDGE_URL="$TMP/knowledge.git" GITIGNORE_FILE="$TMP/home/.gitignore" \
      INSTALL_SKIP_EXTERNAL=1 "$@" bash "$INSTALL" 2>&1
    echo "rc=$?"
  )
}
mkdir -p "$TMP/home"

# --- 1. a missing agent-config whose clone fails must not touch anything ---
C=$TMP/claude1; fresh_claude_dir "$C"
out=$(run_install "$C" "$TMP/missing" "$TMP/does-not-exist.git" "$KSRC")
expect_has "missing agent-config fails" "rc=1" "$out"
expect_has "missing agent-config says why" "install: cannot clone $TMP/does-not-exist.git into $TMP/missing" "$out"
expect_file "missing agent-config keeps existing skills" "$C/skills/keep-me/SKILL.md"
expect "missing agent-config keeps settings" '{"model":"orig"}' "$(cat "$C/settings.json")"

# --- 2. a missing knowledge repo is cloned, then the install continues ---
C=$TMP/claude2; fresh_claude_dir "$C"
out=$(run_install "$C" "$SRC" "unused" "$TMP/knowledge-clone")
expect_has "missing knowledge is cloned" "rc=0" "$out"
expect_file "knowledge clone exists" "$TMP/knowledge-clone/.git"
expect_file "knowledge clone has content" "$TMP/knowledge-clone/CLAUDE.md"

# --- 3. happy path: skills replaced one by one, stale ones removed, synced kept ---
C=$TMP/claude3; fresh_claude_dir "$C"
out=$(run_install "$C" "$SRC" "unused" "$KSRC")
expect_has "happy path succeeds" "rc=0" "$out"
expect_file "skill x installed" "$C/skills/x/SKILL.md"
expect_file "skill y installed" "$C/skills/y/SKILL.md"
expect_no_file "stale skill removed" "$C/skills/old"
expect_no_file "stale keep-me removed (not in source)" "$C/skills/keep-me"
expect_file "synced skills survive" "$C/skills/synced/keep.txt"
expect_file "top-level manifest survives" "$C/skills/manifest.json"
expect "settings copied" '{"model":"fable"}' "$(cat "$C/settings.json")"
expect "global CLAUDE.md copied" '# global' "$(cat "$C/CLAUDE.md")"
[ -x "$C/hooks/a.sh" ] || { fails=$((fails + 1)); echo "FAIL hook is executable"; }
[ -x "$C/bin/wt" ] || { fails=$((fails + 1)); echo "FAIL wt is executable"; }
expect "agent copied" 'reviewer' "$(cat "$C/agents/r.md")"
expect_has "summary names the source sha" "$SRC_SHA" "$out"
expect_has "summary counts skills" "2 skills installed, 2 removed" "$out"
out=$(run_install "$C" "$SRC" "unused" "$KSRC")
expect_has "second run succeeds" "rc=0" "$out"
expect "gitignore patterns appended once" 1 "$(grep -c '^\.plans/$' "$TMP/home/.gitignore")"
expect "all gitignore patterns present" 4 "$(grep -c . "$TMP/home/.gitignore")"

# --- 4. INSTALL_SKIP_EXTERNAL=1 calls no external tool ---
expect "no external tool called" "" "$(cat "$TOOL_LOG")"

# --- 5. a git worktree checkout of agent-config is a valid source (its .git is a file) ---
git -C "$SRC" worktree add -q "$TMP/agent-config-wt" -b wt
C=$TMP/claude5; fresh_claude_dir "$C"
out=$(run_install "$C" "$TMP/agent-config-wt" "unused" "$KSRC")
expect_has "worktree source accepted" "rc=0" "$out"
expect_file "worktree source installs skills" "$C/skills/x/SKILL.md"

[ "$fails" -eq 0 ] && echo "all install tests passed" || { echo "$fails failure(s)"; exit 1; }
