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

If `.plans/<slug>/map.md` exists, this is a map-to-spec synthesis. Run step 1, skip step 2,
and instead:
- Read the map's decisions, all resolved ticket files under `.plans/<slug>/tickets/`, and
  any research findings under `.plans/<slug>/research/`.
- Ask one confirmation round with AskUserQuestion: "Anything the map missed or that needs
  adjustment?" (max 3 questions, 1 round).
- Proceed to step 3 with the map's decisions and resolved tickets as input for the Decisions
  section; step 1's file:line refs still source the Implementation pointers.

Otherwise, follow the normal interview path:

1. Dispatch one Explore subagent per repo this touches, with model `sonnet`, to find
   existing functions, helpers, and patterns to reuse or extend, and to report that repo's
   CLAUDE.md feature dirs and the vocabulary they use. It returns file:line refs and that
   report only. Don't read the codebase into this conversation yourself.
2. Interview me with AskUserQuestion on the hard parts only: edge cases, tradeoffs, out of
   scope. Skip what step 1 answered. Max 3 questions per round, at most 2 rounds. Multi-repo:
   also ask which repos, in what merge order, and what exactly crosses each boundary. Settle
   here anything a headless step would otherwise have to guess.
3. Write spec.md with sections in this order: `# <title>`, Purpose, Decisions, Acceptance,
   Behaviors, Seams, Out of scope, Implementation pointers. Everything above Implementation
   pointers must stay true after the merge; file:line pointers go stale, so they come last.
   Purpose: what this delivers, in prose.
   Decisions: one bullet per decision, `- <choice>: <reason>. Not <rejected option>.`,
   dropping the "Not" clause only when nothing else was considered. No ticket numbers, map
   references, or "strike if wrong" markers; tickets and the map aren't kept, so references to
   them would dangle.
   Acceptance: exactly one line per repo in merge order. If that repo's CLAUDE.md names a
   feature dir covering the area this change touches, write Gherkin scenarios as feature draft
   files under `.plans/<slug>/features/<repo>/<path>` (`<path>` is the file's repo-relative
   destination under that feature dir), using the repo's CLAUDE.md vocabulary, names unique
   within their file (a scenario is identified by file plus name), and the project's
   tracking-ID tag when the request names one (Codebahn: `@CB-288`). The line reads
   `Acceptance: <repo>: <path>[, <path>...]`, naming every draft written for that repo.
   Otherwise write `Acceptance: <repo>: none (no harness for <area> yet)` and draft no
   scenarios for that repo, even if another repo in the plan has a harness.
   Behaviors: for each repo whose Acceptance line is `none`, a numbered list, each item one
   test in that repo's own suite (label by repo when more than one needs a list).
   Include Seams only for multi-repo work (pinning each cross-repo contract verbatim).
   Out of scope: what this deliberately skips. Implementation pointers:
   step 1's file:line refs, preferring reuse over new code; they go stale, so they come last.
   Write order.md; its first line is exactly `Merge order: repo1, repo2` (one repo for
   single-repo work), then the seam notes.
4. Validate the feature drafts against spec.md (each repo's Acceptance line matches what was
   written), then stop. Do not implement. Tell me: `/build <slug>` plans, implements, and
   ships headlessly; `/build <slug> plan` stops after the plans so I can read them;
   `/work <slug> <repo>` drives a repo by hand.
