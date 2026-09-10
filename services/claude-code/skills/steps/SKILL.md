---
name: steps
description: Write this repo's plan.md from the spec as a red/green/refactor checklist
disable-model-invocation: true
model: claude-opus-4-6[1m]
effort: max
---
!`"$HOME/.claude/bin/wt" plan-ctx`

If the existing plan above has any `- [x]`, stop: it is in progress; edit it by hand instead.

1. Dispatch an Explore subagent, with model `sonnet`, for the files the spec names in this
   repo; it returns file:line refs only. Don't read the codebase into this conversation.
2. If this repo's CLAUDE.md names a directory for specs, copy the spec there and commit it as
   `docs: add spec for <slug>`. Otherwise skip; the PR body carries it.
3. Write the plan at the path above: a `- [ ]` list, one behavior per item, each naming the
   failing test that proves it (`Test: ...`) or, for non-code changes, the command that fails
   before and passes after (`Check: <command>`). Order by dependency; this repo's side of
   each seam contract comes first. Nothing outside the spec; cite its out-of-scope section
   for what you leave out.
4. Run the reviewer subagent on the plan (give it the plan path and the spec path). Fix
   valid BLOCKER/MAJOR findings in the plan. Implement nothing.
5. End with exactly one of:
- "Plan written: <N> steps."
- "BLOCKED: <what the spec doesn't answer>." Also write that line as the plan file's
  first line so the runner stops.
