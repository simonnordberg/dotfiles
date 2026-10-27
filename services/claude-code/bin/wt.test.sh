#!/usr/bin/env bash
# Tests for wt. Run: bash services/claude-code/bin/wt.test.sh
set -u
WT="$(cd "$(dirname "$0")" && pwd)/wt"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
unset WT_SLUG WORKSPACE RUN_SLUG RUN_PLANS RUN_PLANSROOT RUN_ROOT RUN_WS # a build's sessions run this suite
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
mkdir -p "$ws/.plans/api"
expect "C a plan dir named like the repo never wins" feat-c "$(val slug "$(ctx "$ws/.worktrees/feat-c/api")")"
rmdir "$ws/.plans/api"

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

# --- records layout: a .claude/records marker makes a repo the workspace's plans root ---
mark() { mkdir -p "$1/.claude" && touch "$1/.claude/records"; } # mark <repodir>
wsm=$TMP/m; mkrepo "$wsm/records"; mkrepo "$wsm/svc"; mark "$wsm/records"
out=$(cd "$wsm" && "$WT" here)
expect "marked here root from workspace dir" "$wsm/records" "$(val root "$out")"
expect_has "marked here mode from workspace dir" "mode=workspace" "$out"
out=$(cd "$wsm/svc" && "$WT" here)
expect "marked here root from child repo" "$wsm/records" "$(val root "$out")"
expect_has "marked here mode from child repo" "mode=workspace" "$out"

wsm2=$TMP/n; mkrepo "$wsm2/r1"; mkrepo "$wsm2/r2"; mark "$wsm2/r1"; mark "$wsm2/r2"
out=$(cd "$wsm2" && "$WT" here 2>&1; echo "rc=$?")
expect_has "two markers die rc" "rc=1" "$out"
expect_has "two markers name r1" "r1" "$out"
expect_has "two markers name r2" "r2" "$out"

# --- records layout: resolve and plans_for_slug find <records>/.plans/<slug> from a child repo ---
wsrm=$TMP/rm; mkrepo "$wsrm/records"; mkrepo "$wsrm/svc"; mark "$wsrm/records"
mkdir -p "$wsrm/records/.plans/feat-rm/svc"
addwt "$wsrm/svc" "$wsrm/.worktrees/feat-rm/svc" feat-rm
out=$(ctx "$wsrm/.worktrees/feat-rm/svc")
expect "marked resolve finds plans in the records repo" "$wsrm/records/.plans/feat-rm" "$(val plans "$out")"
expect "marked resolve plandir is in the child repo" "$wsrm/records/.plans/feat-rm/svc" "$(val plandir "$out")"

out=$(cd "$wsrm/.worktrees/feat-rm/svc" && "$WT" status feat-rm)
expect_has "marked plans_for_slug finds the records plans dir" "$wsrm/records/.plans/feat-rm" "$out"

# a slug that exists only at an old guess dies, naming where it should move
mkdir -p "$wsrm/svc/.plans/feat-old"
out=$(cd "$wsrm/svc" && WT_SLUG=feat-old "$WT" ctx 2>&1; echo "rc=$?")
expect_has "legacy slug (repo-local) in a marked workspace dies rc" "rc=1" "$out"
expect_has "legacy slug (repo-local) names the old path" "feat-old is in $wsrm/svc/.plans/feat-old" "$out"
expect_has "legacy slug (repo-local) names the new path" "move it to $wsrm/records/.plans/feat-old" "$out"

mkdir -p "$wsrm/.plans/feat-old2"
out=$(cd "$wsrm/svc" && WT_SLUG=feat-old2 "$WT" ctx 2>&1; echo "rc=$?")
expect_has "legacy slug (workspace-flat) in a marked workspace dies rc" "rc=1" "$out"
expect_has "legacy slug (workspace-flat) names the old path" "feat-old2 is in $wsrm/.plans/feat-old2" "$out"
expect_has "legacy slug (workspace-flat) names the new path" "move it to $wsrm/records/.plans/feat-old2" "$out"

# locate (wt create) also puts the new slug's plans under the records repo
out=$(cd "$wsrm" && "$WT" create feat-cm svc)
expect "marked create path" "$wsrm/.worktrees/feat-cm/svc" "$out"
expect "marked create plandir in the records repo" yes "$([ -d "$wsrm/records/.plans/feat-cm/svc" ] && echo yes)"

# the records repo itself gets a worktree at <ws>/.worktrees/<slug>/<repo> too, not <repo>/.worktrees/<slug>
out=$(cd "$wsrm" && "$WT" create feat-cm2 records)
expect "marked create path for the records repo itself" "$wsrm/.worktrees/feat-cm2/records" "$out"
expect "marked create plandir for the records repo itself" yes "$([ -d "$wsrm/records/.plans/feat-cm2/records" ] && echo yes)"

# --- records layout: a marker added mid-session doesn't override an explicit WORKSPACE ---
wsam=$TMP/am; mkrepo "$wsam/records"; mkrepo "$wsam/svc"
mkdir -p "$wsam/.plans/feat-am/svc"
addwt "$wsam/svc" "$wsam/.worktrees/feat-am/svc" feat-am
expect "explicit WORKSPACE before marker" "$wsam/.plans/feat-am" \
  "$(cd "$wsam/.worktrees/feat-am/svc" && WORKSPACE=$wsam "$WT" ctx | sed -n 's/^plans=//p')"
mark "$wsam/records"
expect "explicit WORKSPACE still wins after marker added" "$wsam/.plans/feat-am" \
  "$(cd "$wsam/.worktrees/feat-am/svc" && WORKSPACE=$wsam "$WT" ctx | sed -n 's/^plans=//p')"

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
# WORKSPACE set (as in wt run sessions) must not relocate an unmarked repo's worktree
expect "create repo-local + WORKSPACE -> repo-local worktree" "$ws2/solo/.worktrees/feat-hw" \
  "$(cd "$ws2/solo" && mkdir -p .plans/feat-hw && WORKSPACE=$ws2/solo "$WT" create feat-hw)"

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

# --- tdd / fix context never fail ---
out=$(cd "$ws/api/.claude/worktrees/nothing" && "$WT" tdd; echo "rc=$?")
expect_has "tdd no plan" "NO PLAN FOUND" "$out"
expect_has "tdd rc 0" "rc=0" "$out"
out=$(cd "$ws/api/.claude/worktrees/nothing" && "$WT" fix-ctx review; echo "rc=$?")
expect_has "fix-ctx no plan" "NO PLAN FOUND" "$out"
expect_has "fix-ctx rc 0" "rc=0" "$out"
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
printf 'ok  pkg/a\n--- FAIL: TestX\nboom\nFAIL pkg/b\n' >"$pd/check.log"
out=$(cd "$wt" && "$WT" fix-ctx check)
expect_has "fix-ctx check shows the failure" "--- FAIL: TestX" "$out"
expect_has "fix-ctx shows the spec path" "$ws/.plans/feat-x/spec.md" "$out"
printf '## Findings\n- MAJOR LOGIC a.go:3: nil map write\n' >"$pd/review.md"
out=$(cd "$wt" && "$WT" fix-ctx review)
expect_has "fix-ctx review shows the findings" "MAJOR LOGIC a.go:3: nil map write" "$out"
expect_has "fix-ctx review names the file to annotate" "$pd/review.md" "$out"
printf 'Run 12 failed\nerror: lint\n' >"$pd/ci.log"
expect_has "fix-ctx ci shows the run" "error: lint" "$(cd "$wt" && "$WT" fix-ctx ci)"
expect_has "fix-ctx unknown kind" "unknown kind" "$(cd "$wt" && "$WT" fix-ctx bogus)"

# --- plan-ctx: feature drafts ---
out=$(cd "$wt" && "$WT" plan-ctx)
expect_has "plan-ctx no drafts" "Feature drafts: none" "$out"
mkdir -p "$ws/.plans/feat-x/features/web"
printf 'wrong repo draft\n' >"$ws/.plans/feat-x/features/web/wrong.feature"
out=$(cd "$wt" && "$WT" plan-ctx)
expect_has "plan-ctx still none for api with only web drafts" "Feature drafts: none" "$out"
expect_lacks "plan-ctx filters out other repo's drafts" "wrong repo draft" "$out"
mkdir -p "$ws/.plans/feat-x/features/api/sub"
printf 'top draft body\n' >"$ws/.plans/feat-x/features/api/top.feature"
printf 'nested draft body\n' >"$ws/.plans/feat-x/features/api/sub/nested.feature"
out=$(cd "$wt" && "$WT" plan-ctx)
expect_has "plan-ctx shows top-level draft header" "Feature draft: top.feature" "$out"
expect_has "plan-ctx shows top-level draft body" "top draft body" "$out"
expect_has "plan-ctx shows nested draft header with subdir" "Feature draft: sub/nested.feature" "$out"
expect_has "plan-ctx shows nested draft body" "nested draft body" "$out"
expect_lacks "plan-ctx still filters web drafts once api drafts exist" "wrong repo draft" "$out"
expect "plan-ctx orders drafts alphabetically by relative path" yes \
  "$(printf '%s' "$out" | awk '/Feature draft: top\.feature/{t=NR} /Feature draft: sub\/nested\.feature/{n=NR} END{print (t && n && n<t)?"yes":"no"}')"
expect "plan-ctx spec block precedes feature drafts" yes \
  "$(printf '%s' "$out" | awk '/^Spec:/{s=NR} /^Feature draft/{if (s && NR>s) f=1} END{print (f?"yes":"no")}')"

# --- check: the repo's .claude/check, run from its root; local go.mod replaces refused ---
wsc=$TMP/c; mkrepo "$wsc/api"; mkrepo "$wsc/web"; mkdir -p "$wsc/api/.claude" "$wsc/api/sub/deep"
cat >"$wsc/api/.claude/check" <<'EOF'
#!/usr/bin/env bash
[ -n "${CHECK_SLEEP:-}" ] && sleep "$CHECK_SLEEP"
echo "ran ${1:-full} in $PWD" >>"$CHECK_LOG"
echo "check output line"
[ ! -f "$CHECK_FAIL" ]
EOF
chmod +x "$wsc/api/.claude/check"; commit "$wsc/api" "chore: check" .claude/keep >/dev/null
export CHECK_LOG=$TMP/check.log CHECK_FAIL=$TMP/check.fail
out=$(cd "$wsc/api/sub/deep" && "$WT" check; echo "rc=$?")
expect_has "check green rc" "rc=0" "$out"
expect "check runs from the repo root" "ran full in $wsc/api" "$(tail -1 "$CHECK_LOG")"
out=$(cd "$wsc/api" && "$WT" check; echo "rc=$?")
expect_has "check trusts a tree already green" "already green" "$out"
expect "check did not rerun for the same tree" 1 "$(grep -c 'ran full' "$CHECK_LOG")"
# full green covers --quick: no rerun needed
(cd "$wsc/api" && "$WT" check --quick >/dev/null)
expect "a full green covers --quick" 1 "$(grep -c ran "$CHECK_LOG")"
touch "$CHECK_FAIL"; commit "$wsc/api" "feat: change" f >/dev/null
out=$(cd "$wsc/api" && "$WT" check 2>&1; echo "rc=$?")
expect_has "check red rc" "rc=1" "$out"
expect_has "check red shows the output" "check output line" "$out"
expect_has "check red points at the full output" "full output: " "$out"
expect "check reran after a commit" 2 "$(grep -c 'ran full' "$CHECK_LOG")"
rm "$CHECK_FAIL"; echo x >"$wsc/api/untracked"
(cd "$wsc/api" && "$WT" check >/dev/null; "$WT" check >/dev/null)
expect "check never trusts a dirty tree" 4 "$(grep -c 'ran full' "$CHECK_LOG")"
rm "$wsc/api/untracked"
out=$(cd "$wsc/api" && CHECK_SLEEP=3 WT_CHECK_TIMEOUT=1 "$WT" check --quick 2>&1; echo "rc=$?")
expect_has "check timeout rc" "rc=1" "$out"
expect_has "check timeout says so" "timed out after 1s" "$out"
# --quick has its own stamp: two quick runs rerun only once
: >"$CHECK_LOG"; rm "$CHECK_FAIL"; commit "$wsc/api" "feat: more" f >/dev/null
(cd "$wsc/api" && "$WT" check --quick >/dev/null; "$WT" check --quick >/dev/null)
expect "check --quick trusts a quick-green tree" 1 "$(grep -c 'ran --quick' "$CHECK_LOG")"
# but a full check reruns even after a quick stamp
(cd "$wsc/api" && "$WT" check >/dev/null)
expect "a quick stamp does not cover a full check" 1 "$(grep -c 'ran full' "$CHECK_LOG")"
out=$(cd "$wsc/web" && "$WT" check; echo "rc=$?")
expect_has "check without a script passes" "rc=0" "$out"
expect_has "check without a script says so" "no .claude/check" "$out"
out=$(cd "$TMP" && "$WT" check 2>&1; echo "rc=$?")
expect_has "check outside git fails" "rc=1" "$out"
mkdir -p "$wsc/web/tools"
printf 'module x\n\ngo 1.22\n\nreplace example.com/a => ./internal/a\n\nreplace example.com/b v1.0.0 => example.com/c v1.1.0\n' >"$wsc/web/go.mod"
printf 'module x/tools\n\ngo 1.22\n\nreplace x => ../\n' >"$wsc/web/tools/go.mod"
commit "$wsc/web" "chore: modules" f >/dev/null
expect_has "check allows replaces inside the repo" "rc=0" "$(cd "$wsc/web" && "$WT" check; echo "rc=$?")"
printf 'replace (\n\texample.com/d => ../sibling\n\texample.com/e v1.2.0 => /abs/path\n)\n' >>"$wsc/web/go.mod"
commit "$wsc/web" "chore: local replace" f >/dev/null
out=$(cd "$wsc/web" && "$WT" check 2>&1; echo "rc=$?")
expect_has "check refuses a sibling replace rc" "rc=1" "$out"
expect_has "check names the sibling replace" "go.mod: example.com/d => ../sibling" "$out"
expect_has "check names the absolute replace" "go.mod: example.com/e => /abs/path" "$out"

# --- acceptance: scaffold and guards ---
wsa=$TMP/acc; mkrepo "$wsa/api"
out=$(cd "$wsa/api" && "$WT" acceptance 2>&1; echo "rc=$?")
expect_has "acceptance without a runner rc" "rc=3" "$out"
expect_has "acceptance without a runner says so" "wt acceptance: no .claude/acceptance in $wsa/api" "$out"
# a usage error proves nothing, so it is rc 2, never the "a scenario failed" rc 1
for a in "--run" "--bogus" "--run x extra" "--paths extra"; do
  out=$(cd "$wsa/api" && "$WT" acceptance $a 2>&1; echo "rc=$?")
  expect_has "acceptance $a rc" "rc=2" "$out"
  expect_has "acceptance $a shows usage" "usage: wt acceptance [--run <regex> | --paths]" "$out"
done
out=$(cd "$TMP" && "$WT" acceptance 2>&1; echo "rc=$?")
expect_has "acceptance outside git rc" "rc=2" "$out"
expect_has "acceptance outside git says so" "wt acceptance: not in a git repository" "$out"
mkdir -p "$wsa/api/.claude"
cat >"$wsa/api/.claude/acceptance" <<'EOF'
#!/usr/bin/env bash
echo "$*" >>"$ACCEPTANCE_ARGS_LOG"
echo "runner output" >&2
while [ $# -gt 0 ]; do
  case $1 in
    --report) [ -z "${ACCEPTANCE_JSON:-}" ] || printf '%s' "$ACCEPTANCE_JSON" >"$2"; shift 2 ;;
    *) shift ;;
  esac
done
exit "${ACCEPTANCE_EXIT:-0}"
EOF
chmod +x "$wsa/api/.claude/acceptance"
commit "$wsa/api" "chore: acceptance runner" .claude/keep >/dev/null
export ACCEPTANCE_ARGS_LOG=$TMP/acc-args.log
cuke() { # cuke <name> [step status]...: a Cucumber JSON scenario as godog writes it; no statuses, no steps
  local name=$1 s steps=; shift
  for s in "$@"; do steps="$steps${steps:+,}{\"keyword\":\"Then \",\"name\":\"a step\",\"result\":{\"status\":\"$s\"}}"; done
  printf '{"type":"scenario","name":"%s"%s}' "$name" "${steps:+,\"steps\":[$steps]}"
}
report() { # report <scenario>...: a Cucumber JSON report of one feature file
  local IFS=,; printf '[{"uri":"features/login.feature","name":"Login","elements":[%s]}]' "$*"
}
acc() { # acc <runner exit> <report, empty for none> [arg]...: wt acceptance on the fake runner; sets out, err, rc
  out=$(cd "$wsa/api" && ACCEPTANCE_EXIT=$1 ACCEPTANCE_JSON=$2 "$WT" acceptance "${@:3}" 2>"$TMP/acc.err"); rc=$?
  err=$(cat "$TMP/acc.err")
}

# --- acceptance: one line per scenario from the runner's Cucumber JSON, and --run forwarding ---
: >"$ACCEPTANCE_ARGS_LOG"
acc 0 "$(report "$(cuke 'logs in' passed passed)" "$(cuke 'logs out' passed)")"
expect "acceptance all passed rc" 0 "$rc"
expect_has "acceptance prints a passed scenario" "$(printf 'passed\tfeatures/login.feature\tlogs in')" "$out"
expect_has "acceptance prints every scenario" "$(printf 'passed\tfeatures/login.feature\tlogs out')" "$out"
expect_has "acceptance prints a summary" "wt acceptance: 2 passed, 0 not passed" "$err"
expect_has "acceptance asks the runner for a report" "--report $wsa/api/.git/wt-acceptance.json" "$(cat "$ACCEPTANCE_ARGS_LOG")"
: >"$ACCEPTANCE_ARGS_LOG"
acc 0 "$(report "$(cuke 'logs in')" "$(cuke 'logs out' passed)")" --run 'logs out'
expect "acceptance --run rc" 0 "$rc"
expect_has "acceptance forwards --run to the runner" "--run logs out" "$(cat "$ACCEPTANCE_ARGS_LOG")"
expect_lacks "acceptance leaves out a scenario that did not run" "logs in" "$out"
expect_has "acceptance counts only scenarios that ran" "wt acceptance: 1 passed, 0 not passed" "$err"

# --- acceptance: a scenario passes only if every step passed ---
acc 1 "$(report "$(cuke 'logs in' passed)" "$(cuke fails passed failed skipped)")"
expect "acceptance failed scenario rc" 1 "$rc"
expect_has "acceptance names the failed scenario" "$(printf 'failed\tfeatures/login.feature\tfails')" "$out"
expect_has "acceptance failed summary" "wt acceptance: 1 passed, 1 not passed" "$err"
for s in skipped pending undefined ambiguous; do
  acc 1 "$(report "$(cuke 'logs in' passed)" "$(cuke odd passed "$s")")"
  expect "acceptance $s step rc" 1 "$rc"
  expect_has "acceptance reports a $s step" "$(printf '%s\tfeatures/login.feature\todd' "$s")" "$out"
done
acc 0 "$(report "$(cuke skips skipped)")" # godog exits 0 when a step skips
expect "acceptance skipped step under a runner exit 0 rc" 1 "$rc"
acc 1 "$(report '{"type":"scenario","name":"cleans up","steps":[{"result":{"status":"passed"}}],"after":[{"result":{"status":"failed"}}]}')"
expect_has "acceptance counts a failed hook" "$(printf 'failed\tfeatures/login.feature\tcleans up')" "$out"
acc 1 "$(report '{"type":"scenario","name":"blank","steps":[{"result":{}}]}')"
expect_has "acceptance never passes a step without a status" "$(printf 'unknown\tfeatures/login.feature\tblank')" "$out"

# --- acceptance: a run that proves nothing is rc 2 ---
acc 1 "$(report "$(cuke 'logs in' passed)")"
expect "acceptance runner exit 1 with every scenario passed rc" 2 "$rc"
expect_has "acceptance says the runner and report disagree" "wt acceptance: runner exited 1 but" "$err"
acc 0 ""
expect "acceptance missing report rc" 2 "$rc"
expect_has "acceptance missing report gives a reason" "wt acceptance: could not read" "$err"
acc 0 "not json"
expect "acceptance unparsable report rc" 2 "$rc"
expect_has "acceptance unparsable report gives a reason" "wt acceptance: could not read" "$err"
acc 0 "[]"
expect "acceptance empty report rc" 2 "$rc"
expect_has "acceptance empty report gives a reason" "wt acceptance: no scenarios ran" "$err"
acc 0 "$(report "$(cuke 'logs in')" "$(cuke 'logs out')")" --run nothing
expect "acceptance --run matching nothing rc" 2 "$rc"
acc 2 "$(report "$(cuke 'logs in' passed)")"
expect "acceptance runner exit 2 rc" 2 "$rc"
expect_has "acceptance forwards the runner's output" "runner output" "$out"
expect_has "acceptance gives a reason for runner exit 2" "wt acceptance: runner exited 2" "$err"

# --- acceptance: timeout and unexpected exit codes ---
cat >"$wsa/api/.claude/acceptance" <<'EOF'
#!/usr/bin/env bash
sleep "${ACCEPTANCE_SLEEP:-0}"
exit "${ACCEPTANCE_EXIT:-0}"
EOF
chmod +x "$wsa/api/.claude/acceptance"
commit "$wsa/api" "chore: acceptance runner for timeout and odd exit codes" .claude/keep >/dev/null

out=$(cd "$wsa/api" && ACCEPTANCE_EXIT=5 "$WT" acceptance 2>"$TMP/acc.err"); rc=$?
expect "acceptance unexpected exit code rc" 2 "$rc"
expect_has "acceptance unexpected exit code gives a reason" "wt acceptance: runner exited 5" "$(cat "$TMP/acc.err")"

out=$(cd "$wsa/api" && ACCEPTANCE_SLEEP=3 WT_ACCEPTANCE_TIMEOUT=1 "$WT" acceptance 2>"$TMP/acc.err"); rc=$?
expect "acceptance timeout rc" 2 "$rc"
expect_has "acceptance timeout gives a reason" "timed out after" "$(cat "$TMP/acc.err")"

# --- acceptance: --paths subcommand ---
cat >"$wsa/api/.claude/acceptance" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = --paths ]; then
  printf '%s\n' "${ACCEPTANCE_PATHS:-features/login.feature}"
  exit "${ACCEPTANCE_PATHS_EXIT:-0}"
fi
exit 0
EOF
chmod +x "$wsa/api/.claude/acceptance"
mkdir -p "$wsa/api/features"
commit "$wsa/api" "chore: acceptance runner supports --paths" features/login.feature >/dev/null

out=$(cd "$wsa/api" && "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths rc" 0 "$rc"
expect "acceptance --paths prints the runner's lines" "features/login.feature" "$out"

out=$(cd "$wsa/api" && ACCEPTANCE_PATHS=/etc/passwd "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths rejects absolute paths" 2 "$rc"
expect_has "acceptance --paths absolute path reason" "absolute path" "$(cat "$TMP/acc.err")"

out=$(cd "$wsa/api" && ACCEPTANCE_PATHS='../outside' "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths rejects .. components" 2 "$rc"
expect_has "acceptance --paths dotdot reason" '.. component' "$(cat "$TMP/acc.err")"

out=$(cd "$wsa/api" && ACCEPTANCE_PATHS='features/missing.feature' "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths rejects missing files" 2 "$rc"
expect_has "acceptance --paths missing file reason" "does not exist" "$(cat "$TMP/acc.err")"

out=$(cd "$wsa/api" && ACCEPTANCE_PATHS_EXIT=5 "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths nonzero runner exit" 2 "$rc"
expect_has "acceptance --paths names the runner's exit code" "runner exited 5 for --paths" "$(cat "$TMP/acc.err")"

out=$(cd "$wsa/api" && ACCEPTANCE_PATHS=$'features/login.feature\n\n.claude/acceptance' "$WT" acceptance --paths 2>"$TMP/acc.err"); rc=$?
expect "acceptance --paths with a blank line rc" 0 "$rc"
expect "acceptance --paths prints only the paths" $'features/login.feature\n.claude/acceptance' "$out"

rm "$wsa/api/.claude/acceptance"
commit "$wsa/api" "chore: remove acceptance runner" .claude/keep >/dev/null
out=$(cd "$wsa/api" && "$WT" acceptance --paths 2>&1; echo "rc=$?")
expect_has "acceptance --paths without a runner rc" "rc=3" "$out"

# --- run, with fake claude, gh, codebahn, notify-send, systemd-run and systemctl on PATH ---
export WT_UNDER_TEST=$WT NOTIFY_LOG=$TMP/notify.log SYSTEMD_LOG=$TMP/systemd.log XDG_STATE_HOME=$TMP/state PR_LOG=$TMP/pr.log
mkdir -p "$TMP/bin"
cat >"$TMP/bin/claude" <<'EOF'
#!/usr/bin/env bash
prompt=; add=; agent=main
while [ $# -gt 0 ]; do case $1 in -p) prompt=$2; shift;; --add-dir) add=$2; shift;; --agent) agent=$2; shift;; esac; shift; done
repo=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")")
plan="$add/$repo/plan.md"
echo "$repo ${WT_SLUG:-unset} $("$WT_UNDER_TEST" slug)" >>"$add/seen.log"
echo "$repo $agent ${prompt%%$'\n'*}" >>"$add/prompts.log"
echo "$repo ${WORKSPACE:-unset}" >>"$add/workspace.log"
say() { jq -cn --arg t "$1" '{type: "result", subtype: "success", result: $t, num_turns: 3, duration_ms: 4200, total_cost_usd: 0.25}'; }
printf '{"type":"assistant","parent_tool_use_id":null,"message":{"usage":{"input_tokens":5,"cache_read_input_tokens":%s,"cache_creation_input_tokens":2000},"content":[{"type":"tool_use","name":"Bash","input":{"command":"go test ./..."}}]}}\n' "${FAKE_CTX:-40000}"
if [ "$agent" = reviewer ]; then
  case $prompt in
    Re-review*) say "${FAKE_REREVIEW:-$'## Findings\nNone.'}" ;;
    *) say "${FAKE_REVIEW:-$'## Findings\nNone.\n\n## Title\nfeat: the feature\n\n## Summary\n- does the thing'}" ;;
  esac
  exit 0
fi
case $prompt in
  /steps)
    [ -n "${FAKE_NOPLAN:-}" ] && { say "I could not find the spec."; exit 0; }
    printf -- '- [ ] one. Test: t1\n- [ ] two%s. Test: t2\n' "${FAKE_BLOCK:-}" >"$plan"; say "Plan written: 2 steps." ;;
  /tdd)
    line=$(grep -n '^- \[ \]' "$plan" | head -1); n=${line%%:*}; text=${line#*:}
    if [[ $text == *BLOCKME* ]]; then sed -i "${n}a\\  BLOCKED: what now?" "$plan"; say "BLOCKED: what now?"; exit 0; fi
    [ -n "${FAKE_NOOP:-}" ] && { say "Should the limit be per user or per org?"; exit 0; }
    echo t >>"t_test.go"; git add -A; git commit -qm "test: $n"; a=$(git rev-parse --short HEAD)
    echo c >>"c.go"; git add -A; git commit -qm "feat: $n"; b=$(git rev-parse --short HEAD)
    sed -i "${n}s/^- \[ \] \(.*\)$/- [x] \1 (commits: $a $b)/" "$plan"; say "Step done." ;;
  "/fix check")
    [ -n "${FAKE_FIX_BLOCK:-}" ] && { say "BLOCKED: $FAKE_FIX_BLOCK"; exit 0; }
    echo "$RANDOM" >>fixed-check; git add -A; git commit -qm "fix: make the check green"; say "Fixed: 1 fixed, 0 false positives." ;;
  "/fix review")
    [ -n "${FAKE_FIX_BLOCK:-}" ] && { say "BLOCKED: $FAKE_FIX_BLOCK"; exit 0; }
    echo f >>fix.go; git add -A; git commit -qm "fix: the finding"
    printf '\n## Resolution\n- MAJOR LOGIC c.go:1: fixed in %s\n' "$(git rev-parse --short HEAD)" >>"$add/$repo/review.md"
    say "Fixed: 1 fixed, 0 false positives." ;;
esac
EOF
cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
echo "gh $*" >>"$PR_LOG"
if [ "$1 $2" = "pr create" ]; then
  while [ $# -gt 0 ]; do [ "$1" = --body-file ] && cp "$2" "$PR_LOG.body.gh"; shift; done
  echo "https://github.com/acme/api/pull/7"
elif [ "$1 $2" = "pr checks" ]; then
  case ${FAKE_CI:-pass} in
    fail_then_pass)
      f=$PR_LOG.ci_count; n=$(cat "$f" 2>/dev/null); n=${n:-0}; echo $((n + 1)) >"$f"
      [ "$n" -ge 1 ] && echo '[{"state":"SUCCESS"}]' || echo '[{"state":"FAILURE","name":"test"}]' ;;
    always_fail) echo '[{"state":"FAILURE","name":"test"}]' ;;
    *) echo '[{"state":"SUCCESS"}]' ;;
  esac
fi
EOF
cat >"$TMP/bin/codebahn" <<'EOF'
#!/usr/bin/env bash
echo "codebahn $*" >>"$PR_LOG"
if [ "$1 $2" = "pr create" ]; then
  jq -cn '{html_url: "https://codebahn.net/acme/web/pulls/3", number: 3}'
elif [ "$1" = "ci" ] && [ "$2" = "list" ]; then
  case ${FAKE_CI:-pass} in
    fail_then_pass)
      f=$PR_LOG.cb_ci_count; n=$(cat "$f" 2>/dev/null); n=${n:-0}; echo $((n + 1)) >"$f"
      [ "$n" -ge 1 ] && jq -cn '{workflow_runs:[{id:1,status:"success"}]}' || jq -cn '{workflow_runs:[{id:1,status:"failure"}]}' ;;
    always_fail) jq -cn '{workflow_runs:[{id:1,status:"failure"}]}' ;;
    *) jq -cn '{workflow_runs:[{id:1,status:"success"}]}' ;;
  esac
elif [ "$1" = "ci" ] && [ "$2" = "logs" ]; then
  echo '{"jobs":[{"name":"test","status":"failure","lines":[{"message":"FAIL TestX","step":"run"}]}]}'
fi
exit 0
EOF
printf '#!/usr/bin/env bash\necho "$*" >>"$NOTIFY_LOG"\n' >"$TMP/bin/notify-send"
cat >"$TMP/bin/systemd-run" <<'EOF'
#!/usr/bin/env bash
echo "$*" >>"$SYSTEMD_LOG"
while [ $# -gt 0 ] && [ "$1" != -- ]; do shift; done; shift
"$@" >/dev/null 2>&1
EOF
printf '#!/usr/bin/env bash\necho "systemctl $*" >>"$SYSTEMD_LOG"\n' >"$TMP/bin/systemctl"
chmod +x "$TMP/bin/"*
P="$TMP/bin:$PATH"
export WT_CI_POLL=0 WT_CI_TIMEOUT=5
fakehost() { # fakehost <repo> <url>: origin reads as <url>; fetch and push still reach the local bare origin
  local bare; bare=$(git -C "$1" config --get remote.origin.url)
  git -C "$1" remote set-url origin "$2"
  git -C "$1" config "url.$bare.insteadOf" "$2"
}
feature() { # feature <ws> <slug> <repos...>: repos, merge order, and a spec with an E2E line
  local ws=$1 slug=$2 r; shift 2
  mkdir -p "$ws/.plans/$slug"
  for r in "$@"; do mkrepo "$ws/$r"; done
  printf 'Merge order: %s\n' "$(printf '%s\n' "$@" | paste -sd, | sed 's/,/, /g')" >"$ws/.plans/$slug/order.md"
  printf '# %s\n\n' "$slug" >"$ws/.plans/$slug/spec.md"
  if [ -z "${E2E+x}" ] || [ -n "$E2E" ]; then
    printf 'E2E: %s\n' "${E2E:-test -f c.go}" >>"$ws/.plans/$slug/spec.md"
  fi
}
feature_marked() { # feature_marked <ws> <records repo> <slug> <repos...>: like feature, but a
  # marked records repo (not <ws>) owns .plans; <records repo> is created too and may be listed among the repos
  local ws=$1 recs=$2 slug=$3 r; shift 3
  mkrepo "$ws/$recs"; mark "$ws/$recs"
  mkdir -p "$ws/$recs/.plans/$slug"
  for r in "$@"; do [ -d "$ws/$r" ] || mkrepo "$ws/$r"; done
  printf 'Merge order: %s\n' "$(printf '%s\n' "$@" | paste -sd, | sed 's/,/, /g')" >"$ws/$recs/.plans/$slug/order.md"
  printf '# %s\n\nE2E: %s\n' "$slug" "${E2E:-none}" >"$ws/$recs/.plans/$slug/spec.md"
}

wsr=$TMP/r; mkdir -p "$wsr/.plans/api"; feature "$wsr" feat-r api web
fakehost "$wsr/api" git@github.com:acme/api.git; fakehost "$wsr/web" git@codebahn.net:acme/web.git
out=$(cd "$wsr" && PATH=$P "$WT" run feat-r; echo "rc=$?")
expect_has "run rc" "rc=0" "$out"
expect "run api plan ticked" 2 "$(grep -c '^- \[x\]' "$wsr/.plans/feat-r/api/plan.md")"
expect "run web plan ticked" 2 "$(grep -c '^- \[x\]' "$wsr/.plans/feat-r/web/plan.md")"
expect "run logs" yes "$([ -f "$wsr/.plans/feat-r/api/log/plan.log" ] && [ -f "$wsr/.plans/feat-r/api/log/slice-02.log" ] && [ -f "$wsr/.plans/feat-r/api/log/review.log" ] && [ -f "$wsr/.plans/feat-r/api/log/slice-02.jsonl" ] && echo yes)"
expect_has "run log holds the final message" "Step done." "$(cat "$wsr/.plans/feat-r/api/log/slice-02.log" 2>/dev/null)"
expect_has "run jsonl holds the transcript" '"tool_use"' "$(cat "$wsr/.plans/feat-r/api/log/slice-02.jsonl" 2>/dev/null)"
expect "run state" 2 "$(grep -c open "$wsr/.plans/feat-r/state.md")"
expect_has "run summary api" "api: 2/2 slices done, PR https://github.com/acme/api/pull/7" "$out"
expect_has "run summary web" "web: 2/2 slices done, PR https://codebahn.net/acme/web/pulls/3" "$out"
expect "run branch" feat-r "$(git -C "$wsr/.worktrees/feat-r/api" branch --show-current)"
expect "run commits" 4 "$(git -C "$wsr/.worktrees/feat-r/api" rev-list --count origin/main..HEAD)"
expect "run pushed the branch" "$(git -C "$wsr/.worktrees/feat-r/api" rev-parse HEAD)" "$(git -C "$TMP/origins/r-api.git" rev-parse feat-r 2>/dev/null)"
expect "run sessions know their slug, despite a plan dir named like the repo" "api feat-r feat-r" "$(grep '^api ' "$wsr/.plans/feat-r/seen.log" | sort -u)"
expect_has "the review runs as the pinned reviewer agent" "api reviewer Review" "$(cat "$wsr/.plans/feat-r/prompts.log")"
expect_lacks "a clean review needs no fix session" "/fix" "$(cat "$wsr/.plans/feat-r/prompts.log")"
expect_has "github PRs via gh" "gh pr create --base main --head feat-r --title feat: the feature --body-file" "$(cat "$PR_LOG")"
expect_has "codebahn PRs via the codebahn cli" "codebahn pr create --owner acme --repo web --head feat-r --base main --title feat: the feature" "$(cat "$PR_LOG")"
body=$(cat "$PR_LOG.body.gh" 2>/dev/null)
expect_has "the PR body has the reviewer's summary" "- does the thing" "$body"
expect_has "the PR body states the merge order" "Merge order: 1 of 2 (api, web)" "$body"
expect_has "the PR body records the e2e" 'E2E: `test -f c.go` passed' "$body"
expect_has "the second PR links the first" "after https://github.com/acme/api/pull/7" "$(sed -n '/codebahn pr create/,$p' "$PR_LOG")"
expect_has "progress e2e" "[ship] feat-r: e2e passed" "$out"
log=$(cat "$wsr/.plans/feat-r/run.log" 2>/dev/null)
expect_has "run.log has progress" "[tdd] api: slice 1" "$log"
expect_has "run.log has each session's actions" "api/slice-01  Bash go test ./..." "$log"
expect_has "progress reports each session's cost" '[tdd] api: slice 1 done (4s, $0.25, 42k ctx)' "$out"
expect "sessions.tsv has a row per session" 8 "$(wc -l <"$wsr/.plans/feat-r/sessions.tsv" 2>/dev/null)"
expect_has "sessions.tsv: repo, label, rc, turns, seconds, cost, context" "$(printf 'api\tslice-01\t0\t3\t4\t0.25\t42005')" "$(cat "$wsr/.plans/feat-r/sessions.tsv" 2>/dev/null)"
expect_has "a finished run notifies" "feat-r" "$(cat "$NOTIFY_LOG" 2>/dev/null)"

# --- run in a marked workspace: plans and run.log live under the records repo; sessions get its path as WORKSPACE ---
wsrr=$TMP/rr; feature_marked "$wsrr" records feat-mr svc; fakehost "$wsrr/svc" git@github.com:acme/svc.git
out=$(cd "$wsrr" && PATH=$P "$WT" run feat-mr; echo "rc=$?")
expect_has "marked run rc" "rc=0" "$out"
expect "marked run.log lands under the records repo's plans" yes "$([ -f "$wsrr/records/.plans/feat-mr/run.log" ] && echo yes)"
expect "marked run worktree is under the workspace, not the records repo" "$wsrr/.worktrees/feat-mr/svc" "$(git -C "$wsrr/svc" worktree list --porcelain | awk -v b=refs/heads/feat-mr '/^worktree /{p=substr($0,10)} /^branch /{if($2==b){print p; exit}}')"
expect_has "marked run passes the records repo as WORKSPACE" "svc $wsrr/records" "$(cat "$wsrr/records/.plans/feat-mr/workspace.log" 2>/dev/null)"

review=$'## Findings\n- MAJOR LOGIC c.go:1: wrong on empty input\n- NIT RULES c.go:2: naming\n\n## Title\nfeat: f\n\n## Summary\n- f'
: >"$PR_LOG"; E2E='none (a library)' feature "$TMP/f" feat-f api; fakehost "$TMP/f/api" git@github.com:acme/api.git
out=$(cd "$TMP/f" && FAKE_REVIEW=$review PATH=$P "$WT" run feat-f; echo "rc=$?")
prompts=$(cat "$TMP/f/.plans/feat-f/prompts.log")
expect_has "fix flow rc" "rc=0" "$out"
expect_has "a major gets one fix session" "api main /fix review" "$prompts"
expect "the fix is re-reviewed once" 1 "$(grep -c 'api reviewer Re-review' <<<"$prompts")"
expect_has "progress review" "[ship] api: review: 1 blocker/major" "$out"
body=$(cat "$PR_LOG.body.gh" 2>/dev/null)
expect_has "the PR body carries the resolution" "fixed in" "$body"
expect_has "the PR body lists minor and nit follow-ups" "NIT RULES c.go:2: naming" "$body"
expect_has "an e2e of none is noted" "E2E: none (a library)" "$body"

no_title_review=$'## Findings\nNone.\n\n## Summary\n- does the thing'
: >"$PR_LOG"; E2E='none (a library)' feature "$TMP/th" feat-th api; fakehost "$TMP/th/api" git@github.com:acme/api.git
printf '# Top-up balance\n\n## Purpose\nbody\n\nE2E: none (a library)\n' >"$TMP/th/.plans/feat-th/spec.md"
out=$(cd "$TMP/th" && FAKE_REVIEW=$no_title_review PATH=$P "$WT" run feat-th; echo "rc=$?")
expect_has "title fallback rc" "rc=0" "$out"
expect_has "title fallback reads the spec's H1, not a ## heading" "--title Top-up balance --body-file" "$(cat "$PR_LOG")"

: >"$PR_LOG"; E2E='none (a library)' feature "$TMP/tn" feat-tn api; fakehost "$TMP/tn/api" git@github.com:acme/api.git
printf '## Purpose\nbody\n\nE2E: none (a library)\n' >"$TMP/tn/.plans/feat-tn/spec.md"
out=$(cd "$TMP/tn" && FAKE_REVIEW=$no_title_review PATH=$P "$WT" run feat-tn; echo "rc=$?")
expect_has "title fallback rc" "rc=0" "$out"
expect_has "no H1 at all falls back to the slug" "--title feat-tn --body-file" "$(cat "$PR_LOG")"

E2E='none' feature "$TMP/v" feat-v api; fakehost "$TMP/v/api" git@github.com:acme/api.git
out=$(cd "$TMP/v" && FAKE_REVIEW=$review FAKE_REREVIEW=$'## Findings\n- BLOCKER LOGIC fix.go:1: the fix breaks x' PATH=$P "$WT" run feat-v; echo "rc=$?")
expect_has "a blocker left after the fix round stops the line" "rc=1" "$out"
expect_has "it blocks with the count" "[ship] api: BLOCKED: review: 1 blocker/major left after one fix round" "$out"
expect "no PR while blocked" "" "$(cat "$TMP/v/.plans/feat-v/state.md" 2>/dev/null)"
expect_has "the plan carries the block" "BLOCKED: review:" "$(tail -1 "$TMP/v/.plans/feat-v/api/plan.md")"
expect_has "review.md keeps the re-review" "the fix breaks x" "$(cat "$TMP/v/.plans/feat-v/api/review.md")"

E2E='none' feature "$TMP/w" feat-w api; fakehost "$TMP/w/api" git@github.com:acme/api.git
out=$(cd "$TMP/w" && FAKE_REVIEW=$review FAKE_FIX_BLOCK="needs a product decision" PATH=$P "$WT" run feat-w; echo "rc=$?")
expect_has "a fix session can block" "[ship] api: BLOCKED: needs a product decision" "$out"

# (check-during-tdd tests are above; ship still re-checks via check_green)

E2E='echo e2e-broke; exit 3' feature "$TMP/e" feat-e api; fakehost "$TMP/e/api" git@github.com:acme/api.git
out=$(cd "$TMP/e" && PATH=$P "$WT" run feat-e; echo "rc=$?")
expect_has "a red e2e blocks" "[ship] feat-e: BLOCKED: e2e failed (exit 3): e2e-broke" "$out"
expect "no PR when the e2e is red" "" "$(cat "$TMP/e/.plans/feat-e/state.md" 2>/dev/null)"

: >"$PR_LOG"; E2E='' feature "$TMP/ne" feat-ne api; fakehost "$TMP/ne/api" git@github.com:acme/api.git
out=$(cd "$TMP/ne" && PATH=$P "$WT" run feat-ne; echo "rc=$?")
expect_has "a spec with no E2E line still ships" "rc=0" "$out"
expect_lacks "no e2e progress line when the spec has none" "E2E" "$out"
body=$(cat "$PR_LOG.body.gh" 2>/dev/null)
expect_lacks "the PR body has no E2E note when the spec has none" "E2E" "$body"
expect_lacks "run.log has no e2e mention when the spec has none" "E2E" "$(cat "$TMP/ne/.plans/feat-ne/run.log" 2>/dev/null)"

feature "$TMP/t" feat-t api; fakehost "$TMP/t/api" git@github.com:acme/api.git
printf '#!/bin/sh\nsleep 5\n' >"$TMP/t/api/.git/hooks/pre-push"; chmod +x "$TMP/t/api/.git/hooks/pre-push"
out=$(cd "$TMP/t" && WT_PUSH_TIMEOUT=1 PATH=$P "$WT" run feat-t; echo "rc=$?")
expect_has "a hung push blocks instead of hanging" "push timed out after 1s" "$out"

feature "$TMP/u" feat-u api
out=$(cd "$TMP/u" && PATH=$P "$WT" run feat-u; echo "rc=$?")
expect_has "an unknown host gets the branch pushed" "api: 2/2 slices done, pushed feat-u (open the PR by hand)" "$out"

feature "$TMP/m2" feat-m api; fakehost "$TMP/m2/api" git@github.com:acme/api.git
(cd "$TMP/m2" && PATH=$P "$WT" run feat-m plan >/dev/null; PATH=$P "$WT" run feat-m tdd >/dev/null)
commit "$TMP/m2/api" "feat: upstream" upstream.txt >/dev/null; git -C "$TMP/m2/api" push -q origin main
out=$(cd "$TMP/m2" && PATH=$P "$WT" run feat-m ship; echo "rc=$?")
expect_has "ship after the default branch moved" "rc=0" "$out"
expect "ship rebases onto the moved default first" "$(git -C "$TMP/m2/api" rev-parse main)" "$(git -C "$TMP/m2/.worktrees/feat-m/api" merge-base HEAD origin/main)"
feature "$TMP/c2" feat-c2 api; fakehost "$TMP/c2/api" git@github.com:acme/api.git
(cd "$TMP/c2" && PATH=$P "$WT" run feat-c2 plan >/dev/null; PATH=$P "$WT" run feat-c2 tdd >/dev/null)
commit "$TMP/c2/api" "feat: upstream" c.go >/dev/null; git -C "$TMP/c2/api" push -q origin main
out=$(cd "$TMP/c2" && PATH=$P "$WT" run feat-c2 ship; echo "rc=$?")
expect_has "a conflicting default blocks" "[ship] api: BLOCKED: conflicts with origin/main; run /rebase in" "$out"
expect "a conflicting rebase is aborted" "" "$(git -C "$TMP/c2/.worktrees/feat-c2/api" status --porcelain)"

# --- wt check --quick runs after each ticked slice ---
feature "$TMP/ck" feat-ck api
mkdir -p "$TMP/ck/api/.claude"
printf '#!/usr/bin/env bash\n[ -f fixed-check ] || { echo "FAIL TestNeedsFix"; exit 1; }\n' >"$TMP/ck/api/.claude/check"
chmod +x "$TMP/ck/api/.claude/check"; (cd "$TMP/ck/api" && git add -A && git commit -qm check && git push -q origin main)
out=$(cd "$TMP/ck" && PATH=$P "$WT" run feat-ck; echo "rc=$?")
prompts=$(cat "$TMP/ck/.plans/feat-ck/prompts.log")
expect_has "a red quick check after a slice gets a fix session" "api main /fix check" "$prompts"
expect_has "the runner re-checks every finished slice" "[tdd] api: check red; fix session 1" "$out"
expect_has "a fixed quick check lets the slice pass" "[tdd] api: slice 1 done" "$out"
expect_has "a fixed quick check lets the line finish" "rc=0" "$out"

# a quick check still red after two fixes blocks the slice
# a check that always fails (the fix session can't satisfy it)
feature "$TMP/ck2" feat-ck2 api
mkdir -p "$TMP/ck2/api/.claude"
printf '#!/usr/bin/env bash\necho "FAIL TestAlwaysFails"; exit 1\n' >"$TMP/ck2/api/.claude/check"
chmod +x "$TMP/ck2/api/.claude/check"; (cd "$TMP/ck2/api" && git add -A && git commit -qm check && git push -q origin main)
out=$(cd "$TMP/ck2" && PATH=$P "$WT" run feat-ck2; echo "rc=$?")
expect_has "a check still red after two fixes blocks the slice" "[tdd] api: BLOCKED: check still red after 2 fix sessions" "$out"
expect "the blocked slice is unticked" 0 "$(grep -c '^- \[x\]' "$TMP/ck2/.plans/feat-ck2/api/plan.md")"
expect_has "the block sits under the slice" "  BLOCKED: check still red after 2 fix sessions" "$(sed -n 2p "$TMP/ck2/.plans/feat-ck2/api/plan.md")"
expect "two check fix sessions at most during tdd" 2 "$(grep -c '/fix check' "$TMP/ck2/.plans/feat-ck2/prompts.log")"

# 5. Context flag: sessions over 100k are flagged
feature "$TMP/ctx" feat-ctx api
out=$(cd "$TMP/ctx" && FAKE_CTX=150000 PATH=$P "$WT" run feat-ctx; echo "rc=$?")
expect_has "a session over 100k is flagged" 'over 100k' "$out"
expect_has "it still completes" "rc=0" "$out"

wsb=$TMP/b; mkdir -p "$wsb/.plans/feat-b"; mkrepo "$wsb/api"
printf 'Merge order: api\n' >"$wsb/.plans/feat-b/order.md"
out=$(cd "$wsb" && FAKE_BLOCK=BLOCKME PATH=$P "$WT" run feat-b; echo "rc=$?")
expect_has "run blocked rc" "rc=1" "$out"
expect_has "run blocked summary" "api: 1/2 slices done, BLOCKED: what now?" "$out"
expect "run blocked no ship" "" "$(cat "$wsb/.plans/feat-b/state.md" 2>/dev/null)"
expect_has "a blocked run notifies" "BLOCKED: what now?" "$(cat "$NOTIFY_LOG" 2>/dev/null)"

wsn=$TMP/n2; mkdir -p "$wsn/.plans/feat-n"; mkrepo "$wsn/api"
printf 'Merge order: api\n' >"$wsn/.plans/feat-n/order.md"
out=$(cd "$wsn" && FAKE_NOOP=1 PATH=$P "$WT" run feat-n; echo "rc=$?")
expect_has "no progress stops the run" "rc=1" "$out"
expect "no progress runs one session, not forty" 1 "$(ls "$wsn/.plans/feat-n/api/log" | grep -c '^slice-.*jsonl$')"
expect_has "no progress blocks with the session's last words" "  BLOCKED: slice not finished; the session said: Should the limit be per user or per org?" "$(cat "$wsn/.plans/feat-n/api/plan.md")"
expect_has "no progress summary" "api: 0/2 slices done, BLOCKED: slice not finished; the session said: Should the limit" "$out"

wsx=$TMP/x; mkdir -p "$wsx/.plans/feat-x"; mkrepo "$wsx/api"
printf 'Merge order: api\n' >"$wsx/.plans/feat-x/order.md"
out=$(cd "$wsx" && FAKE_NOPLAN=1 PATH=$P "$WT" run feat-x; echo "rc=$?")
expect_has "no plan written fails" "rc=1" "$out"
expect_has "no plan written says why" "[plan] api: FAILED: no plan written: I could not find the spec." "$out"

wsp=$TMP/p; feature "$wsp" feat-p api
out=$(cd "$wsp" && PATH=$P "$WT" run feat-p plan; echo "rc=$?")
expect "run plan only" 0 "$(grep -c '^- \[x\]' "$wsp/.plans/feat-p/api/plan.md")"
expect_has "run plan summary" "api: 0/2 slices done" "$out"
out=$(cd "$wsp" && PATH=$P "$WT" run feat-p tdd api; echo "rc=$?")
expect "run tdd repo" 2 "$(grep -c '^- \[x\]' "$wsp/.plans/feat-p/api/plan.md")"
expect "run tdd keeps plan" 1 "$(ls "$wsp/.plans/feat-p/api/log/plan.log" | wc -l)"
out=$(cd "$wsp" && PATH=$P "$WT" run feat-p nope 2>&1; echo "rc=$?")
expect_has "run bad phase" "rc=1" "$out"
out=$(cd "$wsp" && PATH=$P "$WT" run feat-none 2>&1; echo "rc=$?")
expect_has "run unknown slug" "no .plans/feat-none" "$out"

# single repo, repo-local plans, run from inside the repo
wss=$TMP/s; mkrepo "$wss/solo"; mkdir -p "$wss/solo/.plans/feat-s"
printf 'Merge order: solo\n' >"$wss/solo/.plans/feat-s/order.md"
out=$(cd "$wss/solo" && PATH=$P "$WT" run feat-s; echo "rc=$?")
expect_has "run single rc" "rc=0" "$out"
expect "run single ticked" 2 "$(grep -c '^- \[x\]' "$wss/solo/.plans/feat-s/solo/plan.md")"
expect "run single worktree" feat-s "$(git -C "$wss/solo/.worktrees/feat-s" branch --show-current)"

# --- progress output during run ---
wsg=$TMP/g2; feature "$wsg" feat-g api web
out=$(cd "$wsg" && PATH=$P "$WT" run feat-g; echo "rc=$?")
expect_has "progress plan started" "[plan] api: started" "$out"
expect_has "progress plan done" "[plan] api: done" "$out"
expect_has "progress tdd starting" "[tdd] api: starting (2 slices)" "$out"
expect_has "progress tdd step" "[tdd] api: slice 1" "$out"
expect_has "progress tdd done" "[tdd] api: done (2/2)" "$out"
expect_has "progress ship started" "[ship] api: started" "$out"
expect_has "progress ship done" "[ship] api: done" "$out"
expect_has "progress web plan" "[plan] web: started" "$out"
expect_has "progress web tdd" "[tdd] web: starting (2 slices)" "$out"
expect_has "progress web ship" "[ship] web: done" "$out"

# progress: plan already exists -> skip
wsg2=$TMP/g3; mkdir -p "$wsg2/.plans/feat-g2"; mkrepo "$wsg2/api"
printf 'Merge order: api\n' >"$wsg2/.plans/feat-g2/order.md"
mkdir -p "$wsg2/.plans/feat-g2/api"
printf -- '- [ ] one. Test: t1\n' >"$wsg2/.plans/feat-g2/api/plan.md"
out=$(cd "$wsg2" && PATH=$P "$WT" run feat-g2 tdd; echo "rc=$?")
expect_has "progress tdd no plan phase" "[tdd] api: starting (1 slice)" "$out"
expect_lacks "progress skip plan" "[plan]" "$out"

# progress: blocked shows reason
wsbl=$TMP/bl; mkdir -p "$wsbl/.plans/feat-bl"; mkrepo "$wsbl/api"
printf 'Merge order: api\n' >"$wsbl/.plans/feat-bl/order.md"
out=$(cd "$wsbl" && FAKE_BLOCK=BLOCKME PATH=$P "$WT" run feat-bl; echo "rc=$?")
expect_has "progress blocked" "[tdd] api: BLOCKED: what now?" "$out"

# --- CI watch: after PRs are open, poll CI and fix red runs ---
workflow() { # workflow <repodir> <file>: commit a CI workflow file to main and push it
  mkdir -p "$1/${2%/*}" && echo 'on: push' >"$1/$2"
  git -C "$1" add -A && git -C "$1" commit -qm ci && git -C "$1" push -q origin main
}
# green CI
feature "$TMP/ci1" feat-ci1 api; workflow "$TMP/ci1/api" .github/workflows/ci.yml; fakehost "$TMP/ci1/api" git@github.com:acme/api.git
out=$(cd "$TMP/ci1" && PATH=$P "$WT" run feat-ci1; echo "rc=$?")
expect_has "CI poll: github green" "[ci] api: CI green" "$out"
expect_has "CI poll rc" "rc=0" "$out"

# red CI with a fix
feature "$TMP/ci2" feat-ci2 api; workflow "$TMP/ci2/api" .github/workflows/ci.yml; fakehost "$TMP/ci2/api" git@github.com:acme/api.git
out=$(cd "$TMP/ci2" && FAKE_CI=fail_then_pass PATH=$P "$WT" run feat-ci2; echo "rc=$?")
expect_has "CI red gets a fix session" "[ci] api: CI red; fix session 1" "$out"
expect_has "CI: fix and re-push lets it finish" "[ci] api: CI green" "$out"
expect_has "CI fixed rc" "rc=0" "$out"
expect_has "CI fix session in prompts" "api main /fix ci" "$(cat "$TMP/ci2/.plans/feat-ci2/prompts.log")"

# always-red CI blocks after 2 fix sessions
feature "$TMP/ci3" feat-ci3 api; workflow "$TMP/ci3/api" .github/workflows/ci.yml; fakehost "$TMP/ci3/api" git@github.com:acme/api.git
out=$(cd "$TMP/ci3" && FAKE_CI=always_fail PATH=$P "$WT" run feat-ci3; echo "rc=$?")
expect_has "CI always red blocks" "[ci] api: BLOCKED: CI still red after 2 fix sessions" "$out"
expect_has "CI always red rc" "rc=1" "$out"
expect "CI: two fix sessions at most" 2 "$(grep -c '/fix ci' "$TMP/ci3/.plans/feat-ci3/prompts.log")"

# codebahn CI, from .forgejo/workflows
feature "$TMP/ci4" feat-ci4 api; workflow "$TMP/ci4/api" .forgejo/workflows/ci.yml; fakehost "$TMP/ci4/api" git@codebahn.net:acme/api.git
out=$(cd "$TMP/ci4" && PATH=$P "$WT" run feat-ci4; echo "rc=$?")
expect_has "CI poll: codebahn green" "[ci] api: CI green" "$out"

# no workflow files: no CI run will ever report, so there is nothing to wait for
feature "$TMP/ci6" feat-ci6 api; fakehost "$TMP/ci6/api" git@github.com:acme/api.git
n=$(grep -c 'pr checks' "$PR_LOG")
out=$(cd "$TMP/ci6" && PATH=$P "$WT" run feat-ci6; echo "rc=$?")
expect_has "no workflows: no CI watch" "[ci] api: no CI workflows; nothing to watch" "$out"
expect "no workflows: CI never polled" "$n" "$(grep -c 'pr checks' "$PR_LOG")"
expect_has "no workflows rc" "rc=0" "$out"

# unknown host: no CI poll
feature "$TMP/ci5" feat-ci5 api
out=$(cd "$TMP/ci5" && PATH=$P "$WT" run feat-ci5; echo "rc=$?")
expect_lacks "no CI poll for unknown hosts" "[ci]" "$out"

# --- build: detached under systemd; one run per feature at a time ---
wsd=$TMP/d; feature "$wsd" feat-d api
out=$(cd "$wsd" && PATH=$P "$WT" build feat-d; echo "rc=$?")
expect_has "build rc" "rc=0" "$out"
expect_has "build names a unit" "--unit=wt-feat-d-" "$(cat "$SYSTEMD_LOG" 2>/dev/null)"
expect_has "build runs from here" "--same-dir" "$(cat "$SYSTEMD_LOG" 2>/dev/null)"
expect_has "build runs wt run" "run feat-d" "$(cat "$SYSTEMD_LOG" 2>/dev/null)"
expect_has "build says how to follow it" "wt watch feat-d" "$out"
expect "build ran the line" 2 "$(grep -c '^- \[x\]' "$wsd/.plans/feat-d/api/plan.md" 2>/dev/null)"
out=$(cd "$wsd" && PATH=$P "$WT" build feat-none 2>&1; echo "rc=$?")
expect_has "build unknown slug" "no .plans/feat-none" "$out"

wsl=$TMP/l; mkdir -p "$wsl/.plans/feat-l"; mkrepo "$wsl/api"
printf 'Merge order: api\n' >"$wsl/.plans/feat-l/order.md"; echo wt-feat-l-abcd >"$wsl/.plans/feat-l/run.unit"
flock -n "$wsl/.plans/feat-l/.run.lock" sleep 3 & lockpid=$!; sleep 0.5
out=$(cd "$wsl" && PATH=$P "$WT" run feat-l 2>&1; echo "rc=$?")
expect_has "a second run is refused" "feat-l is already running" "$out"
out=$(cd "$wsl" && PATH=$P "$WT" build feat-l 2>&1; echo "rc=$?")
expect_has "build refuses while running" "already running" "$out"
expect_has "status shows a running feature" "running" "$(cd "$wsl" && "$WT" status feat-l)"
out=$(cd "$wsl" && PATH=$P "$WT" stop feat-l 2>&1; echo "rc=$?")
expect_has "stop stops the unit" "systemctl --user stop wt-feat-l-abcd" "$(cat "$SYSTEMD_LOG")"
wait "$lockpid"

# --- builds don't start builds: a run's sessions inherit RUN_SLUG from it ---
n=$(wc -l <"$SYSTEMD_LOG")
out=$(cd "$wsd" && RUN_SLUG=outer PATH=$P "$WT" run feat-d 2>&1; echo "rc=$?")
expect_has "a run inside a run is refused" "inside the run of outer" "$out"
expect_has "a refused run fails" "rc=1" "$out"
out=$(cd "$wsd" && RUN_SLUG=outer PATH=$P "$WT" build feat-d 2>&1; echo "rc=$?")
expect_has "a build inside a run is refused" "inside the run of outer" "$out"
expect "a refused build starts no unit" "$n" "$(wc -l <"$SYSTEMD_LOG")"

# --- status, watch, stop ---
out=$(cd "$wsr" && "$WT" status; echo "rc=$?")
expect_has "status lists features here" "feat-r" "$out"
expect_has "status: a finished run is done" "done" "$out"
out=$(cd "$TMP" && "$WT" status)
expect_has "status works from anywhere" "feat-r" "$out"
expect_has "status shows a blocked feature" "blocked" "$out"
out=$(cd "$wsr" && "$WT" status feat-r)
expect_has "status shows repo progress" "api: 2/2 slices done, PR https://github.com/acme/api/pull/7" "$out"
expect_has "status shows totals" "8 sessions" "$out"
out=$(cd "$wsr" && timeout 5 "$WT" watch feat-r; echo "rc=$?")
expect_has "watch prints the run log" "[ship] web: done" "$out"
expect_has "watch ends when the run is not running" "rc=0" "$out"
out=$(cd "$wsr" && PATH=$P "$WT" stop feat-r 2>&1; echo "rc=$?")
expect_has "stop when idle says so" "not running" "$out"

if [ "$fails" -eq 0 ]; then echo "all wt tests passed"; else echo "$fails failing"; exit 1; fi
