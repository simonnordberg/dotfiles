---
name: steps
description: Write this repo's plan.md from the spec as a checklist of slices (groups of 2-3 related behaviors)
disable-model-invocation: true
model: claude-opus-4-6[1m]
effort: high
---
!`"$HOME/.claude/bin/wt" plan-ctx`

If the existing plan above has any `- [x]`, stop: it is in progress; edit it by hand instead.

1. Dispatch an Explore subagent, with model `sonnet`, for the files the spec names in this
   repo; it returns file:line refs only. Don't read the codebase into this conversation.
2. If this repo's CLAUDE.md names a directory for specs, copy the spec there and commit it as
   `docs: add spec for <slug>`. Otherwise skip; the PR body carries it.
3. Write the plan at the path above as a `- [ ]` checklist. Each item is a **slice**: a group
   of 2 to 3 related behaviors that touch the same files or module, with a shared failing
   test or check that proves all of them. One behavior = one sentence in the item, and each
   item names its test (`Test: ...`) or, for non-code changes, the command that fails before
   and passes after (`Check: <command>`). Each slice lists which R-ids it covers in parentheses
   at the end, e.g. `(R1, R3)`. Aim for 5 to 8 slices per repo. Rules:
   - **No single-behavior steps.** Merge tiny or trivial items into the nearest related slice.
   - **No verify-only steps.** A step that only runs a command and checks the result belongs
     as the `Check:` of the slice that produced the thing being verified.
   - **At most 3 behaviors per slice**, and they must touch the same area. Split a slice that
     would span unrelated files.
   - **Every R-id must appear in at least one slice.** If a requirement can't be covered,
     mark it `BLOCKED: <why>` in the plan.
   - Order by dependency; this repo's side of each seam contract comes first.
   - Nothing outside the spec; cite X-ids for what you leave out.
4. Run the reviewer subagent on the plan (give it the plan path and the spec path). Fix
   valid BLOCKER/MAJOR findings in the plan. Implement nothing.
5. End with exactly one of:
- "Plan written: <N> slices."
- "BLOCKED: <what the spec doesn't answer>." Also write that line as the plan file's
  first line so the runner stops.
