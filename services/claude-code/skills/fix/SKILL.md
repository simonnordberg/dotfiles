---
name: fix
description: Fix what the line found (a red check, review findings, or a red CI run), test-first and minimal
argument-hint: check | review | ci
disable-model-invocation: true
model: claude-opus-4-6[1m]
effort: high
---
!`"$HOME/.claude/bin/wt" fix-ctx $ARGUMENTS`

Fix only what is listed above, in this worktree. Nothing else.

**check** or **ci**: the failure output above is the whole input. Read the failing test or
tool output, find the root cause, fix it with the smallest change, and run `wt check --quick`
until it's green, then `wt check`. If the cause is outside this repo (a flaky upstream test,
an unmerged PR earlier in the merge order, infrastructure, a missing secret), change nothing
and answer BLOCKED.

**review**: for each BLOCKER and MAJOR finding, most severe first:
1. Prove it. Write a test that fails because of the finding and show it failing for the right
   reason. For REUSE and RULES findings, open the cited helper or rule and confirm it applies.
   If you can't prove it, it's a false positive: note why and change nothing for it.
2. Fix it minimally, show the test green, and run `wt check --quick`.
3. Commit it on its own, following this repo's commit rules.

Each finding tracks an attempt count. If a finding has already been attempted (check for
`attempts: N` in the review file), increment it. After 3 failed attempts on the same finding,
mark it `STUCK` instead of retrying: the finding is real but this agent can't fix it.

Then append or update a `## Resolution` section in the review file, one line per BLOCKER and
MAJOR: `- <the finding>: fixed in <sha>`, `: false positive: <why>`, `: out of scope: <X-id>`,
or `: STUCK after <N> attempts`. Leave MINOR and NIT findings alone; they go to the PR
description.

Never weaken, skip, or delete a test to get green, and never touch unrelated code. Commit
everything you change; leave the tree clean.

End with exactly one of:
- "Fixed: <n> fixed, <m> false positives."
- "STUCK: <n> findings could not be fixed after 3 attempts."
- "BLOCKED: <what a person must decide or do>."
