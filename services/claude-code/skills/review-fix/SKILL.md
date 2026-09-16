---
name: review-fix
description: >
  Iteratively review and fix code until clean. Runs /code-review, fixes
  correctness, simplification, efficiency, and convention findings, then
  re-reviews with a fresh subagent until none remain. Pushes between rounds.
invocation: /review-fix
args: "<level> <target>"
arg_description: >
  level: review effort (low, medium, high, max). Defaults to medium.
  target: PR URL, branch name, or file path to review. Defaults to current branch diff.
model: claude-sonnet-5
effort: high
---

# Review-Fix Loop

Run `/code-review <level> <target>` iteratively, fixing actionable findings each
round, until a fresh review comes back clean. Each review MUST run in its own
subagent (fork) so the reviewer has no memory of prior rounds.

## Prerequisites

This skill modifies code and commits. It MUST run in a dedicated worktree (not
the main checkout) to avoid conflicts with other sessions. If you are not
already in a worktree, create one before starting. The standard rule applies:
one feature = one worktree = one branch = one PR.

## Arguments

- `<level>` (optional): effort level for the review. Default: `medium`.
- `<target>` (optional): PR URL, branch, or file path. Default: current branch diff.

Examples:
- `/review-fix` (medium review of current branch)
- `/review-fix high` (thorough review of current branch)
- `/review-fix medium https://example.com/repo/pulls/42`

## Loop

Repeat up to 4 rounds:

### 1. Review (subagent)

Fork yourself to run `/code-review <level> <target>`. Wait for the result.

### 2. Read findings

Parse the review output. Extract findings from the `ReportFindings` tool call
or from the structured summary. Categorize each finding by its severity/category.

### 3. Filter

Keep only findings whose category is one of:
- **correctness** (bugs, security issues, wrong behavior)
- **simplification** (reuse, deduplication, dead code, unnecessary complexity)
- **efficiency** (unnecessary allocations, avoidable work)
- **conventions** (project conventions from CLAUDE.md: copyright notices, commit
  format, fork attribution, naming patterns, and any other rule the project
  documents as mandatory)

These are the category slugs from `ReportFindings`. Drop everything else (nits,
style, test-coverage suggestions). Also drop anything already triaged as a
false positive.

### 4. Exit check

If zero actionable findings remain, stop. Report success: "Clean after N round(s)."

### 5. Fix (TDD, minimal)

For each actionable finding:
- Read the relevant code to verify the finding is real (not a false positive).
- If it is a false positive, note it and skip. Do not contort code to satisfy it.
- If it is real, fix it using the red/green method:
  1. Write (or update) a test that fails because of the bug or missing behavior.
  2. Show the test fail for the right reason.
  3. Write the minimal code to make the test pass. Follow existing patterns in
     the file. Do not refactor surrounding code, add abstractions, or "improve"
     anything beyond what the finding requires.
  4. Show the test pass.

Simplification and convention findings are the exception: they remove complexity
or enforce style rather than adding behavior, so they may not need a new test.
Verify existing tests still pass after the change.

### 6. Verify

Run the project's full test suite (look in CLAUDE.md for the test command). All
tests must pass. If a fix breaks tests, fix the regression before proceeding.

### 7. Commit and push

Commit the fixes in a single commit with a message summarizing what was fixed and
why. Use the project's commit conventions. Then push the branch so the PR stays
updated and CI runs in parallel with the next review round.

### 8. Next round

Go back to step 1 with a fresh subagent for the review.

## Limits

- **Max 4 rounds.** If round 4 still has actionable findings, stop and report
  what remains. Do not loop forever.
- **No nit-fixing.** Nits grow the diff and trigger new review findings. Defer
  them.
- **No false-positive contortion.** If you believe a finding is wrong, say why
  and skip it. Better to leave a note than write worse code.
- **Minimal changes only.** Each fix should be the smallest change that
  addresses the finding. Do not refactor surrounding code, add abstractions,
  or "improve" anything beyond what the finding requires. Follow existing
  patterns in the file.

## Reporting

When done, state:
- How many rounds ran
- What was fixed (one line per finding)
- What was skipped and why (false positives, out of scope)
- Whether the final review was clean

If you hit the round limit with findings remaining, list them explicitly so the
user can decide what to do.
