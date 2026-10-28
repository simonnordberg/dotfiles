---
name: tdd
description: Implement the next unchecked plan slice, red/green/refactor
disable-model-invocation: true
model: claude-sonnet-5
effort: high
---
!`"$HOME/.claude/bin/wt" tdd`

Do the FIRST unchecked `- [ ]` slice above. Only that one. It may contain 1 to 3 behaviors;
implement all of them.

For each behavior in the slice:

1. Write one failing test (for a `Check:` item, run its command instead). Run it; show it
   fails for the right reason, not a typo or import error. Commit as `test: ...` (no commit
   for a Check item).
2. Write the minimal code to pass. Show green. Commit.
3. Refactor with tests green. Commit if anything changed.

After all behaviors are done:

4. Run `wt check --quick` (the repo's fast CI subset). Fix any failures and commit.
5. In the plan file, change the slice's `- [ ]` to `- [x]` and append
   ` (commits: <sha> <sha> ...)`, short shas, oldest first.

If the slice needs a decision the spec doesn't cover, don't guess: add a line
`  BLOCKED: <question>` right under the slice, commit nothing, and stop.

If you make a decision during implementation that the spec didn't explicitly cover (e.g. a
data format, a default value, an ordering choice), add a line `  DECIDED: <what>, because
<why>` right under the slice and continue. These are collected in the PR body.

End with exactly one of:
- "Slice done. Next: <text of the next unchecked slice>."
- "Last slice done."
- "BLOCKED: <question>."
