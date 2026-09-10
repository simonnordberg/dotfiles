---
name: tdd
description: Implement the next unchecked plan step, red/green/refactor
disable-model-invocation: true
model: sonnet
effort: medium
---
!`"$HOME/.claude/bin/wt" tdd`

Do the FIRST unchecked `- [ ]` step above. Only that one.

1. Write one failing test (for a `Check:` step, run its command instead). Run it; show it
   fails for the right reason, not a typo or import error. Commit as `test: ...` (no commit
   for a Check step).
2. Write the minimal code to pass. Show green. Commit.
3. Refactor with tests green. Commit if anything changed.
4. In the plan file, change the step's `- [ ]` to `- [x]` and append
   ` (commits: <sha> <sha> ...)`, short shas, oldest first.

If the step needs a decision the spec doesn't cover, don't guess: add a line
`  BLOCKED: <question>` right under the step, commit nothing, and stop.

End with exactly one of:
- "Step done. Next: <text of the next unchecked step>."
- "Last step done. Ready to /ship."
- "BLOCKED: <question>."
