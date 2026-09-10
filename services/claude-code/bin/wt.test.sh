#!/usr/bin/env bash
# Tests for wt. Run: bash services/claude-code/bin/wt.test.sh
set -u
WT="$(cd "$(dirname "$0")" && pwd)/wt"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
unset WT_SLUG WORKSPACE
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
val() { printf '%s\n' "$2" | sed -n "s/^$1=//p"; }
ctx() { (cd "$1" && "$WT" ctx); }

mkrepo() { # mkrepo <path>: repo with one commit, bare origin, origin/HEAD set
  mkdir -p "$1" "$TMP/origins"
  git -C "$1" init -q -b main && echo hi >"$1/README" && git -C "$1" add -A && git -C "$1" commit -qm init
  local origin="$TMP/origins/$(basename "$(dirname "$1")")-$(basename "$1").git"
  git init -q --bare -b main "$origin"
  git -C "$1" remote add origin "$origin"
  git -C "$1" push -q -u origin main 2>/dev/null && git -C "$1" remote set-head origin -a >/dev/null
}
addwt() { git -C "$1" worktree add -q "$2" -b "$3"; } # addwt <repo> <path> <branch>
commit() { (cd "$1" && echo "$2" >>"$3" && git add -A && git commit -qm "$2" && git rev-parse --short HEAD); }

# --- ctx: multi-repo workspace, .claude/worktrees, branch == slug ---
ws=$TMP/a; mkdir -p "$ws/.plans/feat-x/api"; mkrepo "$ws/api"
addwt "$ws/api" "$ws/api/.claude/worktrees/feat-x" feat-x
out=$(ctx "$ws/api/.claude/worktrees/feat-x")
expect "A slug" feat-x "$(val slug "$out")"
expect "A repo" api "$(val repo "$out")"
expect "A workspace" "$ws" "$(val workspace "$out")"
expect "A plans" "$ws/.plans/feat-x" "$(val plans "$out")"
expect "A plandir" "$ws/.plans/feat-x/api" "$(val plandir "$out")"
expect "A main" "$ws/api" "$(val main "$out")"

# --- ctx: claude --worktree naming (branch worktree-<slug>) ---
addwt "$ws/api" "$ws/api/.claude/worktrees/feat-b" worktree-feat-b; mkdir -p "$ws/.plans/feat-b"
expect "B slug from dir" feat-b "$(val slug "$(ctx "$ws/api/.claude/worktrees/feat-b")")"

# --- ctx: cb set layout <ws>/.worktrees/<set>/<repo> ---
mkdir -p "$ws/.plans/feat-c"; addwt "$ws/api" "$ws/.worktrees/feat-c/api" feat-c
out=$(ctx "$ws/.worktrees/feat-c/api")
expect "C slug from parent dir" feat-c "$(val slug "$out")"
expect "C repo" api "$(val repo "$out")"
expect "C workspace" "$ws" "$(val workspace "$out")"

# --- ctx: per-repo .worktrees/<x> with branch feat/<x> ---
mkdir -p "$ws/.plans/feat-d"; addwt "$ws/api" "$ws/api/.worktrees/feat-d" feat/feat-d
expect "D slug from dir" feat-d "$(val slug "$(ctx "$ws/api/.worktrees/feat-d")")"

# --- ctx: sibling worktree with unrelated dir name, branch == slug ---
mkdir -p "$ws/.plans/feat-e"; addwt "$ws/api" "$ws/api-hotfix" feat-e
out=$(ctx "$ws/api-hotfix")
expect "E slug from branch" feat-e "$(val slug "$out")"
expect "E repo" api "$(val repo "$out")"

# --- ctx: main checkout on branch feat/<slug> ---
mkdir -p "$ws/.plans/feat-f"; git -C "$ws/api" switch -q -c feat/feat-f
expect "F slug from branch tail" feat-f "$(val slug "$(ctx "$ws/api")")"
git -C "$ws/api" switch -q main

# --- ctx: subdirectory of a worktree ---
mkdir -p "$ws/api/.claude/worktrees/feat-x/src/deep"
expect "sub slug" feat-x "$(val slug "$(ctx "$ws/api/.claude/worktrees/feat-x/src/deep")")"

# --- ctx: no matching plan dir ---
addwt "$ws/api" "$ws/api/.claude/worktrees/nothing" nothing
out=$(ctx "$ws/api/.claude/worktrees/nothing")
expect "H slug empty" "" "$(val slug "$out")"
expect_has "H tried lists candidates" "nothing" "$(val tried "$out")"

# --- ctx: WT_SLUG override wins ---
expect "I WT_SLUG" zzz "$(cd "$ws/api" && WT_SLUG=zzz "$WT" ctx | sed -n 's/^slug=//p')"

# --- ctx: single repo with repo-local .plans ---
ws2=$TMP/g; mkrepo "$ws2/solo"; mkdir -p "$ws2/solo/.plans/feat-g/solo"
addwt "$ws2/solo" "$ws2/solo/.claude/worktrees/feat-g" feat-g
out=$(ctx "$ws2/solo/.claude/worktrees/feat-g")
expect "G plans repo-local" "$ws2/solo/.plans/feat-g" "$(val plans "$out")"
expect "G plandir" "$ws2/solo/.plans/feat-g/solo" "$(val plandir "$out")"
expect "G workspace" "$ws2" "$(val workspace "$out")"

# --- ctx: WORKSPACE override ---
mkdir -p "$TMP/elsewhere/.plans/feat-g"
expect "K WORKSPACE" "$TMP/elsewhere/.plans/feat-g" \
  "$(cd "$ws2/solo/.claude/worktrees/feat-g" && WORKSPACE=$TMP/elsewhere "$WT" ctx | sed -n 's/^plans=//p')"

# --- ctx: bare repo + sibling worktree dir ---
ws3=$TMP/j; mkdir -p "$ws3/.plans/feat-j"; git clone -q --bare "$TMP/origins/a-api.git" "$ws3/foo.git"
git -C "$ws3/foo.git" worktree add -q "$ws3/foo-wt/feat-j" -b feat-j 2>/dev/null
out=$(ctx "$ws3/foo-wt/feat-j")
expect "J repo from bare" foo "$(val repo "$out")"
expect "J workspace from bare" "$ws3" "$(val workspace "$out")"
expect "J slug" feat-j "$(val slug "$out")"

# --- ctx: outside git ---
out=$(cd "$TMP" && "$WT" ctx; echo "rc=$?")
expect_has "outside git exits 0" "rc=0" "$out"

# --- here ---
out=$(cd "$ws" && "$WT" here)
expect_has "here lists repos" "api" "$out"
expect_has "here at workspace" "workspace" "$out"
expect_has "here in repo" "repo=api" "$(cd "$ws/api" && "$WT" here)"
expect "here excludes sibling worktrees" "api" "$(val repos "$(cd "$ws" && "$WT" here)")"
expect "here root at workspace" "$ws" "$(val root "$(cd "$ws" && "$WT" here)")"
expect "here root from repo subdir" "$ws/api" "$(mkdir -p "$ws/api/sub" && cd "$ws/api/sub" && "$WT" here | sed -n 's/^root=//p')"

# --- create: default is <ws>/.worktrees/<slug>/<repo>; existing worktrees are reused ---
out=$(cd "$ws" && "$WT" create feat-y api)
expect "create path" "$ws/.worktrees/feat-y/api" "$out"
expect "create branch" feat-y "$(git -C "$ws/.worktrees/feat-y/api" branch --show-current)"
expect "create base" "$(git -C "$ws/api" rev-parse origin/main)" "$(git -C "$ws/.worktrees/feat-y/api" rev-parse HEAD)"
expect "create plandir" yes "$([ -d "$ws/.plans/feat-y/api" ] && echo yes)"
expect "create idempotent" "$ws/.worktrees/feat-y/api" "$(cd "$ws" && "$WT" create feat-y api)"
expect "create reuses .claude/worktrees" "$ws/api/.claude/worktrees/feat-x" "$(cd "$ws" && "$WT" create feat-x api)"
expect "create reuses per-repo .worktrees" "$ws/api/.worktrees/feat-d" "$(cd "$ws" && "$WT" create feat-d api)"
expect "create from inside repo, repo optional" "$ws/.worktrees/feat-y/api" "$(cd "$ws/api" && "$WT" create feat-y)"
git -C "$ws/api" remote set-head origin -d
expect "create with origin/HEAD unset" "$ws/.worktrees/feat-w/api" "$(cd "$ws" && "$WT" create feat-w api)"
out=$(cd "$ws" && "$WT" create feat-y nope 2>&1; echo "rc=$?")
expect_has "create unknown repo fails" "rc=1" "$out"
mkdir -p "$ws/dangling"; git -C "$ws/dangling" init -q -b main && echo x >"$ws/dangling/f" && git -C "$ws/dangling" add -A && git -C "$ws/dangling" commit -qm init
git init -q --bare "$TMP/origins/dangling.git"; git -C "$ws/dangling" remote add origin "$TMP/origins/dangling.git"; git -C "$ws/dangling" push -q -u origin main 2>/dev/null
expect "create with undeterminable remote HEAD falls back to main" "$ws/.worktrees/feat-v/dangling" "$(cd "$ws" && "$WT" create feat-v dangling 2>/dev/null)"
expect "create repo-local plans -> repo-local worktree" "$ws2/solo/.worktrees/feat-h" "$(cd "$ws2/solo" && mkdir -p .plans/feat-h && "$WT" create feat-h)"

# --- remove ---
out=$(cd "$ws" && "$WT" remove feat-w 2>&1; echo "rc=$?")
expect_has "remove clean rc" "rc=0" "$out"
expect_lacks "remove visits each worktree once" "fatal" "$out"
expect "remove clean gone" no "$([ -e "$ws/.worktrees/feat-w" ] && echo yes || echo no)"
expect "remove clean branch gone" "" "$(git -C "$ws/api" branch --list feat-w)"
echo dirty >"$ws/.worktrees/feat-y/api/dirty"
out=$(cd "$ws" && "$WT" remove feat-y 2>&1; echo "rc=$?")
expect_has "remove dirty refuses" "rc=1" "$out"
expect_has "remove dirty says why" "uncommitted" "$out"
expect "remove dirty kept" yes "$([ -d "$ws/.worktrees/feat-y/api" ] && echo yes)"
rm "$ws/.worktrees/feat-y/api/dirty"; commit "$ws/.worktrees/feat-y/api" "feat: unmerged" f >/dev/null
out=$(cd "$ws" && "$WT" remove feat-y 2>&1; echo "rc=$?")
expect_has "remove unmerged refuses" "unmerged" "$out"

# --- tdd / ship context never fail ---
out=$(cd "$ws/api/.claude/worktrees/nothing" && "$WT" tdd; echo "rc=$?")
expect_has "tdd no plan" "NO PLAN FOUND" "$out"
expect_has "tdd rc 0" "rc=0" "$out"
out=$(cd "$ws/api/.claude/worktrees/nothing" && "$WT" ship; echo "rc=$?")
expect_has "ship no spec" "NO SPEC" "$out"
expect_has "ship rc 0" "rc=0" "$out"
out=$(cd "$TMP" && "$WT" tdd; echo "rc=$?")
expect_has "tdd outside git rc 0" "rc=0" "$out"

wt=$ws/api/.claude/worktrees/feat-x; pd=$ws/.plans/feat-x/api
printf 'spec body\n' >"$ws/.plans/feat-x/spec.md"
printf 'Merge order: api\n' >"$ws/.plans/feat-x/order.md"
printf -- '- [ ] first thing. Test: it works\n- [ ] second thing. Test: it also works\n' >"$pd/plan.md"
out=$(cd "$wt" && "$WT" tdd)
expect_has "tdd shows slug" "Slug: feat-x" "$out"
expect_has "tdd shows repo" "Repo: api" "$out"
expect_has "tdd shows plan" "first thing" "$out"
expect_has "tdd shows plan path" "$pd/plan.md" "$out"
out=$(cd "$wt" && "$WT" ship)
expect_has "ship shows spec" "spec body" "$out"
expect_has "ship shows unchecked" "Unchecked steps (this repo): 2" "$out"
expect_has "ship shows base" "origin/main" "$out"
expect_has "ship shows remote" "origins/a-api.git" "$out"

# --- audit ---
s1=$(commit "$wt" "test: first" a_test.go); s2=$(commit "$wt" "feat: first" a.go)
printf -- '- [x] first thing. Test: it works (commits: %s %s)\n- [ ] second thing. Test: x\n' "$s1" "$s2" >"$pd/plan.md"
expect_has "audit ok" "Methodology audit: OK (1 steps)" "$(cd "$wt" && "$WT" audit)"
printf -- '- [x] first thing (commits: %s %s)\n' "$s2" "$s1" >"$pd/plan.md"
expect_has "audit first not test" "step 1: first commit is not a test: commit" "$(cd "$wt" && "$WT" audit)"
printf -- '- [x] first thing (commits: %s)\n' "$s1" >"$pd/plan.md"
expect_has "audit too few" "step 1: needs a test commit and a green commit" "$(cd "$wt" && "$WT" audit)"
printf -- '- [x] first thing (commits: %s deadbeef)\n' "$s1" >"$pd/plan.md"
expect_has "audit unknown sha" "step 1: commit deadbeef is not on this branch" "$(cd "$wt" && "$WT" audit)"
printf -- '- [x] first thing\n' >"$pd/plan.md"
expect_has "audit no shas" "step 1: no commits recorded" "$(cd "$wt" && "$WT" audit)"
printf -- '- [x] theme it. Check: grep -q x file (commits: %s)\n' "$s2" >"$pd/plan.md"
expect_has "audit check step" "Methodology audit: OK (1 steps)" "$(cd "$wt" && "$WT" audit)"
printf -- '- [ ] first thing\n  BLOCKED: which color?\n' >"$pd/plan.md"
expect_has "ship shows blocked" "BLOCKED: which color?" "$(cd "$wt" && "$WT" ship)"

# --- run, with a fake claude on PATH ---
mkdir -p "$TMP/bin"
cat >"$TMP/bin/claude" <<'EOF'
#!/usr/bin/env bash
prompt=; add=
while [ $# -gt 0 ]; do case $1 in -p) prompt=$2; shift;; --add-dir) add=$2; shift;; esac; shift; done
repo=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")")
plan="$add/$repo/plan.md"
echo "fake claude: $prompt in $PWD"
case $prompt in
  /steps) printf -- '- [ ] one. Test: t1\n- [ ] two%s. Test: t2\n' "$FAKE_BLOCK" >"$plan" ;;
  /tdd)
    line=$(grep -n '^- \[ \]' "$plan" | head -1); n=${line%%:*}; text=${line#*:}
    if [[ $text == *BLOCKME* ]]; then sed -i "${n}a\\  BLOCKED: what now?" "$plan"; exit 0; fi
    echo t >>"t_test.go"; git add -A; git commit -qm "test: $n"; a=$(git rev-parse --short HEAD)
    echo c >>"c.go"; git add -A; git commit -qm "feat: $n"; b=$(git rev-parse --short HEAD)
    sed -i "${n}s/^- \[ \] \(.*\)$/- [x] \1 (commits: $a $b)/" "$plan" ;;
  /ship) echo "$repo https://example/pr/1 open" >>"$add/state.md" ;;
esac
EOF
chmod +x "$TMP/bin/claude"
wsr=$TMP/r; mkdir -p "$wsr/.plans/feat-r"; mkrepo "$wsr/api"; mkrepo "$wsr/web"
printf 'Merge order: api, web\n' >"$wsr/.plans/feat-r/order.md"
out=$(cd "$wsr" && PATH="$TMP/bin:$PATH" "$WT" run feat-r; echo "rc=$?")
expect_has "run rc" "rc=0" "$out"
expect "run api plan ticked" 2 "$(grep -c '^- \[x\]' "$wsr/.plans/feat-r/api/plan.md")"
expect "run web plan ticked" 2 "$(grep -c '^- \[x\]' "$wsr/.plans/feat-r/web/plan.md")"
expect "run logs" yes "$([ -f "$wsr/.plans/feat-r/api/log/plan.log" ] && [ -f "$wsr/.plans/feat-r/api/log/step-02.log" ] && [ -f "$wsr/.plans/feat-r/api/log/ship.log" ] && echo yes)"
expect "run state" 2 "$(grep -c open "$wsr/.plans/feat-r/state.md")"
expect_has "run summary api" "api: 2/2 steps done, PR https://example/pr/1" "$out"
expect_has "run summary web" "web: 2/2 steps done, PR https://example/pr/1" "$out"
expect "run branch" feat-r "$(git -C "$wsr/.worktrees/feat-r/api" branch --show-current)"
expect "run commits" 4 "$(git -C "$wsr/.worktrees/feat-r/api" rev-list --count origin/main..HEAD)"

wsb=$TMP/b; mkdir -p "$wsb/.plans/feat-b"; mkrepo "$wsb/api"
printf 'Merge order: api\n' >"$wsb/.plans/feat-b/order.md"
out=$(cd "$wsb" && FAKE_BLOCK=BLOCKME PATH="$TMP/bin:$PATH" "$WT" run feat-b; echo "rc=$?")
expect_has "run blocked rc" "rc=1" "$out"
expect_has "run blocked summary" "api: 1/2 steps done, BLOCKED: what now?" "$out"
expect "run blocked no ship" "" "$(cat "$wsb/.plans/feat-b/state.md" 2>/dev/null)"

wsp=$TMP/p; mkdir -p "$wsp/.plans/feat-p"; mkrepo "$wsp/api"
printf 'Merge order: api\n' >"$wsp/.plans/feat-p/order.md"
out=$(cd "$wsp" && PATH="$TMP/bin:$PATH" "$WT" run feat-p plan; echo "rc=$?")
expect "run plan only" 0 "$(grep -c '^- \[x\]' "$wsp/.plans/feat-p/api/plan.md")"
expect_has "run plan summary" "api: 0/2 steps done" "$out"
out=$(cd "$wsp" && PATH="$TMP/bin:$PATH" "$WT" run feat-p tdd api; echo "rc=$?")
expect "run tdd repo" 2 "$(grep -c '^- \[x\]' "$wsp/.plans/feat-p/api/plan.md")"
expect "run tdd keeps plan" 1 "$(ls "$wsp/.plans/feat-p/api/log/plan.log" | wc -l)"
out=$(cd "$wsp" && PATH="$TMP/bin:$PATH" "$WT" run feat-p nope 2>&1; echo "rc=$?")
expect_has "run bad phase" "rc=1" "$out"
out=$(cd "$wsp" && PATH="$TMP/bin:$PATH" "$WT" run feat-none 2>&1; echo "rc=$?")
expect_has "run unknown slug" "no .plans/feat-none" "$out"

# single repo, repo-local plans, run from inside the repo
wss=$TMP/s; mkrepo "$wss/solo"; mkdir -p "$wss/solo/.plans/feat-s"
printf 'Merge order: solo\n' >"$wss/solo/.plans/feat-s/order.md"
out=$(cd "$wss/solo" && PATH="$TMP/bin:$PATH" "$WT" run feat-s; echo "rc=$?")
expect_has "run single rc" "rc=0" "$out"
expect "run single ticked" 2 "$(grep -c '^- \[x\]' "$wss/solo/.plans/feat-s/solo/plan.md")"
expect "run single worktree" feat-s "$(git -C "$wss/solo/.worktrees/feat-s" branch --show-current)"

if [ "$fails" -eq 0 ]; then echo "all wt tests passed"; else echo "$fails failing"; exit 1; fi
