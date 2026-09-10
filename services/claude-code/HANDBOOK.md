# Spec chain handbook

A spec-driven, TDD workflow for Claude Code that works across one repo or many. You validate
the spec interactively; everything after that runs headlessly, one fresh `claude -p` process
per step, driven by files on disk. Nothing depends on a conversation staying alive.

```
/spec    interview me, write spec.md + order.md          you validate this
/build   per repo, in merge order: /steps, /tdd..., /ship  headless, parallel across repos
/work    enter a repo's worktree in this session          manual mode and unblocking
```

## Setup

`bash install.sh services/claude-code` (skills, `~/.claude/bin/wt`, hooks, the reviewer
agent) and `bash install.sh services/shell` (`wt` on PATH, the `work` function).

## Models

Each phase's model is explicit in its skill's frontmatter (`model:` and `effort:` in
`skills/<name>/SKILL.md`) and applies whether the skill runs headlessly or by hand; it
overrides `--model`. Defaults: `/steps` and `/ship` on `claude-opus-4-6[1m]` at max effort,
`/tdd` on `claude-sonnet-5` at medium. To change one, edit that frontmatter and reinstall.
`/spec` has none: a multi-turn interview follows the session's model, so launch it with
`cl --model 'claude-fable-5-1[1m]'` when the feature deserves the strongest model (the
later flag wins). Reading the codebase is delegated to Explore subagents on `sonnet` in
`/spec` and `/steps`, so the session model only ever sees a digest plus the spec. The
reviewer (`agents/reviewer.md`) runs on `claude-fable-5-1` at high effort: its input is
just the spec and a diff or plan, and it runs once per repo.

## The flow

Start one session at the root that holds the repos (a workspace like `~/code/codebahn`, or
the repo itself for single-repo work):

```
cd ~/code/codebahn && cl
/spec rate-limit git pushes per tenant     # max 2 rounds of questions, then spec.md + order.md
/build git-ratelimit                        # background; reports when done
```

`/build` runs `wt run <slug>`, which for each repo in `order.md`:

1. creates `.worktrees/<slug>/<repo>` on branch `<slug>` from fresh `origin/HEAD`, and runs
   `/steps` to write `plan.md` from the spec (checked by the reviewer against the spec);
2. runs `/tdd` once per unchecked step: failing test shown red, `test:` commit, minimal code,
   green commit, optional `refactor:` commit, step ticked with the shas;
3. runs `/ship` in merge order: methodology audit, full check, the spec's end-to-end command,
   reviewer, bounded triage, PR. Repo 2 waits for repo 1's PR to be merged (a human act);
   rerun `/build <slug>` afterwards.

Useful variants: `/build <slug> plan` (stop after the plans, read them), `/build <slug> tdd
codebahn-docs` (one phase, one repo). Every rerun resumes from the first unfinished item.

## Files

```
<root>/.plans/<slug>/
  spec.md            what and why; frozen acceptance criteria for the reviewer
  order.md           first line: `Merge order: repo1, repo2`; then seam notes
  state.md           `<repo> <PR URL> open`, appended by /ship
  <repo>/plan.md     `- [ ] behavior. Test: ...` becomes `- [x] ... (commits: a b c)`
  <repo>/log/        per headless step: <step>.jsonl (full transcript, every tool call and
                     result) and <step>.log (the final message); plan, step-01, ..., ship
<root>/.worktrees/<slug>/<repo>/   the feature's worktrees, together
```

`<root>` is where you ran `/spec`: the workspace for multi-repo work, the repo for
single-repo work (then the worktree is `<repo>/.worktrees/<slug>`). All of it is plain
markdown; reorder steps, untick one to redo it, edit the merge order. Keep the directory
after shipping; it is the audit trail. Specs also get committed into the repo when its
CLAUDE.md names a spec directory; plans never do.

## When a step blocks

A headless step that hits something the spec doesn't answer writes `  BLOCKED: <question>`
under the step and the run stops; `/build`'s summary shows it. Either answer it in `plan.md`,
delete the line, and `/build <slug>` again, or take over by hand:

```
/work git-ratelimit codebahn-forgejo   # enters that worktree in this session
/clear                                  # cheap context; hooks set WT_SLUG and ports
/tdd  ...  /ship                        # same skills, same plan file, /rewind works
```

`work <slug> <repo>` from a terminal does the same in a new tmux session.

## Verifying the methodology

`wt audit` (also the first gate in `/ship`) checks every ticked step: commits recorded, all
on the branch, first commit is a `test:` commit followed by a green commit (a `Check:` step
needs one commit). The `.jsonl` transcripts show the red run (`grep -c FAIL
.plans/<slug>/<repo>/log/step-01.jsonl`). `wt ctx` shows what a directory resolves
to; `wt tdd` and `wt ship` print exactly what the skills see.

## Layouts

`wt` resolves workspace, repo, and slug from git plus the `.plans` directory, so it works from
`.worktrees/<slug>/<repo>`, `<repo>/.claude/worktrees/<slug>`, `<repo>/.worktrees/<slug>`, a
sibling worktree, the main checkout on a branch, or a bare repo with worktrees. `WT_SLUG` and
`WORKSPACE` override the derivation when a layout is stranger than that. Non-git VCS is out
of scope.

## Cleanup

`wt remove <slug>` removes the slug's worktrees and branches in every repo, refusing if any
has uncommitted changes or an unmerged branch. Existing `.claude/worktrees` and `.worktrees`
worktrees are reused by `wt create`, never duplicated.

## Troubleshooting

- `NO PLAN FOUND (tried: ...)`: no `.plans/<candidate>` matched; run `/spec` first, or set
  `WT_SLUG`.
- A skill prints a literal `` !`...` `` line: the injected command failed; run the same `wt`
  subcommand in that directory.
- `wt run` says `no repo 'x'`: `order.md` names a directory that isn't a git checkout
  directly under the workspace.
- Frontmatter check: `claude plugin validate --strict ~/.claude/skills`.
- Tests for `wt`: `bash services/claude-code/bin/wt.test.sh`.
