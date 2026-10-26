# Spec chain handbook

A spec-driven, TDD workflow for Claude Code that works across one repo or many. You validate
the spec interactively; everything after that runs headlessly, one fresh `claude -p` process
per step, driven by files on disk. Nothing depends on a conversation staying alive.

```
/spec    interview me, write spec.md + order.md          you validate this
/build   per repo: /steps, /tdd..., then review and PRs     headless, parallel across repos
/work    enter a repo's worktree in this session          manual mode and unblocking
```

## Setup

`bash install.sh services/claude-code` (skills, `~/.claude/bin/wt`, hooks, the reviewer
agent) and `bash install.sh services/shell` (`wt` on PATH, the `work` function).

## Models

Each phase's model is explicit in its skill's frontmatter (`model:` and `effort:` in
`skills/<name>/SKILL.md`) and applies whether the skill runs headlessly or by hand; it
overrides `--model`. Defaults: `/steps` and `/fix` on `claude-opus-4-6[1m]` at high effort,
`/tdd` on `claude-sonnet-5` at medium. To change one, edit that frontmatter and reinstall.
`/spec` has none: a multi-turn interview follows the session's model, so launch it with
`cl --model 'claude-fable-5-1[1m]'` when the feature deserves the strongest model (the
later flag wins). Reading the codebase is delegated to Explore subagents on `sonnet` in
`/spec` and `/steps`, so the session model only ever sees a digest plus the spec. The
reviewer (`agents/reviewer.md`) runs on `claude-fable-5-1` at high effort: its input is
just the spec and a diff or plan. In the line it is its own headless session
(`claude -p --agent reviewer`); in `/review` and `/steps` it is a foreground subagent; the
`reviewer-pin.sh` hook refuses any call that overrides its model.

## The flow

Start one session at the root that holds the repos (a workspace like `~/code/codebahn`, or
the repo itself for single-repo work):

```
cd ~/code/codebahn && cl
/spec rate-limit git pushes per tenant     # max 2 rounds of questions, then spec.md + order.md
/build git-ratelimit                        # detached; notifies you when it needs you
```

`/build` runs `wt build <slug>`: `wt run <slug>` detached under systemd, one run per feature
at a time. For each repo in `order.md` it:

1. creates `.worktrees/<slug>/<repo>` on branch `<slug>` from fresh `origin/HEAD`, and runs
   `/steps` to write `plan.md` from the spec: 5 to 8 slices of 2-3 related behaviors each,
   checked by the reviewer against the spec;
2. runs `/tdd` once per unchecked slice: red/green/refactor per behavior, then `wt check
   --quick` (the repo's fast CI subset; a red check gets up to two `/fix check` sessions,
   then unticks and blocks). Each slice is one fresh session; the plan is ticked with shas;
3. ships. Per repo, in parallel: rebase onto fresh `origin/<default>`; `wt check` (a red
   check gets up to two `/fix check` sessions); the reviewer on the whole diff; its BLOCKER and
   MAJOR findings go to one `/fix review` session, which proves each with a failing test (or
   drops it as a false positive) before fixing it; the reviewer then re-reviews only the fix
   commits, once. Then the spec's `E2E:` command, once. Then, in merge order, `wt` pushes each
   branch and opens its PR (`gh` or the `codebahn` CLI) with the reviewer's summary, the merge
   order, the e2e result, and the review. After the PRs are open, `wt` polls each one's CI
   (GitHub via `gh pr checks`, codebahn via `codebahn ci list`); a red CI run's logs go to
   `ci.log` and one `/fix ci` session, then re-check, re-push, re-poll (up to 2 tries).
   Merge the PRs in the order their bodies state.

Useful variants: `/build <slug> plan` (stop after the plans, read them), `/build <slug> tdd
codebahn-docs` (one phase, one repo). Every rerun resumes from the first unfinished item.

## Watching a run

`wt status` lists every feature that has run (running, blocked, failed, done) with its latest
progress line; `wt status <slug>` adds steps and PRs per repo, sessions, time, and cost.
`wt watch <slug>` follows `run.log`: progress lines plus one line per action of every session.
A desktop notification arrives when a run blocks, fails, or finishes; `wt stop <slug>` cancels
it. Each session is told its slug (`WT_SLUG`), so a stale plan directory can't capture it.

A step session that ends without ticking its step (it asked a question, or did nothing)
blocks the plan with the session's last words. The runner never reruns a session that made no
progress, and `/steps` ending without a plan fails the run the same way. Pushes are bounded
(`WT_PUSH_TIMEOUT`, 120s), so a locked SSH agent fails the run with a message instead of
hanging it.

## Done means green

Each repo with CI has an executable `.claude/check`: the commands its CI runs, in the same
order (`--quick` is a fast subset for iterating). `wt check` runs it from the repo root,
refuses `go.mod` replaces that point outside the repo (CI has no such path), and remembers a
green full check per tree, so pushing right after it costs nothing. The `check-push.sh` hook
blocks any `git push` from Claude unless the tree is clean and `wt check` is green. Edits are
formatted by the repo's own Biome (else its Prettier) and gofmt, which is what CI checks.

## Files

```
<root>/.plans/<slug>/
  spec.md            what and why; frozen acceptance criteria for the reviewer
  order.md           first line: `Merge order: repo1, repo2`; then seam notes
  state.md           `<repo> <PR URL> open`, appended when wt opens the PR
  e2e.log            output of the spec's E2E command
  run.log            progress, plus one line per session action (`wt watch`)
  sessions.tsv       per session: time, repo, label, exit code, turns, seconds, cost, peak context
  <repo>/plan.md     `- [ ] behavior. Test: ...` becomes `- [x] ... (commits: a b c)`
  <repo>/review.md   the review: Findings, Title, Summary, Resolution, re-review of the fixes
  <repo>/check.log   the last `wt check` output (what `/fix check` sees)
  <repo>/ci.log      the last CI run's failure output (what `/fix ci` sees)
  <repo>/pr.md       the PR body wt sent
  <repo>/log/        per headless session: <label>.jsonl (full transcript, every tool call and
                     result) and <label>.log (the final message); plan, slice-01, ..., review,
                     fix-review, rereview, fix-ci; a rerun adds -2, -3 instead of overwriting
<root>/.worktrees/<slug>/<repo>/   the feature's worktrees, together
```

`<root>` is where you ran `/spec`: the workspace for multi-repo work, the repo for
single-repo work (then the worktree is `<repo>/.worktrees/<slug>`). A workspace with a
committed, empty `.claude/records` file in one of its repos is marked: that repo becomes
`<root>` for every repo in the workspace, including itself, so a multi-repo project keeps one
plans root no matter which repo you run `/spec` from. The marked repo must sit in its own
directory (e.g. `~/code/codebahn`), never directly under a directory shared with unrelated
repos; a marker there would pull every sibling into the project. All of it is plain
markdown; reorder steps, untick one to redo it, edit the merge order. Keep the directory
after shipping; it is the audit trail. Specs also get committed into the repo when its
CLAUDE.md names a spec directory; plans never do.

## When a step blocks

A headless step that hits something the spec doesn't answer writes `  BLOCKED: <question>`
under the step; the run stops and notifies you, and `wt status` shows the question. The ship
phase blocks the same way, with a line at the end of `plan.md`: a finding left after the fix
round (decide in `review.md`'s Resolution, e.g. mark it a false positive), a check still red,
a failed e2e, or a conflict with the default branch. Either answer it, delete the line, and
`/build <slug>` again, or take over by hand:

```
/work git-ratelimit codebahn-forgejo   # enters that worktree in this session
/clear                                  # cheap context; hooks set WT_SLUG and ports
/tdd  ...                               # same skills, same plan file, /rewind works
/build git-ratelimit ship codebahn-forgejo   # then review and PR, headless
```

`work <slug> <repo>` from a terminal does the same in a new tmux session.

## A second opinion

`/review [PR | base]` runs the same reviewer by hand, on any branch: findings, verified fixes
for BLOCKER and MAJOR, one re-review of the fixes, MINOR and NIT listed as follow-ups. One
pass is the design; a second pass on unchanged code should find nothing new.

## Layouts

`wt` resolves workspace, repo, and slug from git plus the `.plans` directory, so it works from
`.worktrees/<slug>/<repo>`, `<repo>/.claude/worktrees/<slug>`, `<repo>/.worktrees/<slug>`, a
sibling worktree, the main checkout on a branch, or a bare repo with worktrees. `WT_SLUG` and
`WORKSPACE` override the derivation when a layout is stranger than that. Non-git VCS is out
of scope.

In a marked workspace, every repo's worktrees still live at `<ws>/.worktrees/<slug>/<repo>`,
the records repo's own included, but plans, run.log, and sessions.tsv all live under
`<records repo>/.plans/<slug>` instead of each repo's own `.plans`. `wt here` prints
`mode=workspace root=<records repo>` from the workspace dir or from inside any child repo.
A slug that exists only at the old, pre-marker location (`<repo>/.plans/<slug>` or
`<ws>/.plans/<slug>`) is an error naming where to move it; there is no silent fallback. An
explicit `WORKSPACE` always wins over the marker, so a run already in flight keeps the root
it started with even if a marker lands mid-run; only runs started after the marker lands use
it. Two marked repos in one workspace is fatal, naming both.

## Cleanup

`wt remove <slug>` removes the slug's worktrees and branches in every repo, refusing if any
has uncommitted changes or an unmerged branch. Existing `.claude/worktrees` and `.worktrees`
worktrees are reused by `wt create`, never duplicated.

## Troubleshooting

- `NO PLAN FOUND (tried: ...)`: no `.plans/<candidate>` matched; run `/spec` first, or set
  `WT_SLUG`.
- A skill prints a literal `` !`...` `` line: the injected command failed; run the same `wt`
  subcommand in that directory. `wt ctx` shows what a directory resolves to; `wt tdd` and
  `wt fix-ctx review` print exactly what the skills see.
- `wt run` says `no repo 'x'`: `order.md` names a directory that isn't a git checkout
  directly under the workspace.
- Frontmatter check: `claude plugin validate --strict ~/.claude/skills`.
- Tests: `bash services/claude-code/bin/wt.test.sh` (wt) and
  `bash services/claude-code/test/hooks.test.sh` (hooks).
