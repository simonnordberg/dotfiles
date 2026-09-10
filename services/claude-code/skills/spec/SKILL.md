---
name: spec
description: Interview me, then write a slug-namespaced spec and merge order
argument-hint: [feature description]
disable-model-invocation: true
---
Feature: $ARGUMENTS
Here: !`"$HOME/.claude/bin/wt" here`

Pick a short kebab-case slug; it becomes a branch and a directory name in every repo touched.
Write everything under <root>/.plans/<slug>/ (root is shown above).

1. Dispatch one Explore subagent per repo this touches, with model `sonnet`, to find
   existing functions, helpers, and patterns to reuse or extend. It returns file:line refs
   only. Don't read the codebase into this conversation yourself.
2. Interview me with AskUserQuestion on the hard parts only: edge cases, tradeoffs, out of
   scope. Skip what step 1 answered. Max 3 questions per round, at most 2 rounds. Multi-repo:
   also ask which repos, in what merge order, and what exactly crosses each boundary. Settle
   here anything a headless step would otherwise have to guess.
3. Write spec.md: purpose; decisions from the interview; files involved; existing code to
   reuse with file:line (prefer reuse over new code); out of scope; one end-to-end check that
   proves it works, with the exact command. Multi-repo: a Seams section pinning each
   cross-repo contract verbatim.
   Write order.md; its first line is exactly `Merge order: repo1, repo2` (one repo for
   single-repo work), then the seam notes.
4. Stop. Do not implement. Tell me: `/build <slug>` plans, implements, and ships headlessly;
   `/build <slug> plan` stops after the plans so I can read them; `/work <slug> <repo>`
   drives a repo by hand.
