---
name: spec
description: Interview me, then write a slug-namespaced spec
disable-model-invocation: true
---
Feature: $ARGUMENTS. Pick a short slug (use $WT_SLUG if set). Interview me with
AskUserQuestion on the hard parts -- edge cases, tradeoffs, what's out of scope. Search the
codebase first for existing functions/helpers/patterns this can reuse or extend. Write
.plans/<slug>/spec.md: files involved, existing code to reuse (prefer reuse over new code),
out-of-scope, and an end-to-end check that proves it works.
Then have me run `claude --worktree <slug>` (if not already in it) and plan inside it; the
reviewed plan goes to .plans/<slug>/plan.md. Spec-driven repos: also copy the spec into the
tracked spec dir.
