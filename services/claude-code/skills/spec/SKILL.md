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

If `.plans/<slug>/map.md` exists, this is a map-to-spec synthesis. Skip steps 1-2 and instead:
- Read the map's decisions, all resolved ticket files under `.plans/<slug>/tickets/`, and
  any research findings under `.plans/<slug>/research/`.
- Ask one confirmation round with AskUserQuestion: "Anything the map missed or that needs
  adjustment?" (max 3 questions, 1 round).
- Proceed to step 3 with the map's decisions as input.

Otherwise, follow the normal interview path:

1. Dispatch one Explore subagent per repo this touches, with model `sonnet`, to find
   existing functions, helpers, and patterns to reuse or extend. It returns file:line refs
   only. Don't read the codebase into this conversation yourself.
2. Interview me with AskUserQuestion on the hard parts only: edge cases, tradeoffs, out of
   scope. Skip what step 1 answered. Max 3 questions per round, at most 2 rounds. Multi-repo:
   also ask which repos, in what merge order, and what exactly crosses each boundary. Settle
   here anything a headless step would otherwise have to guess.
3. Write spec.md with numbered ids:
   - **Purpose**: what the feature does, one paragraph.
   - **Requirements** R1, R2, ...: each a testable statement. Every requirement gets an id.
   - **Decisions** D1, D2, ...: each names the choice, the rejected alternative, and the
     reason. Include all decisions from the interview.
   - **Out of scope** X1, X2, ...: each names what is excluded and why.
   - **Open questions**: list anything unresolved. This section must be empty before `/build`
     starts. If any remain, go back to step 2 and resolve them.
   - **Reuse**: existing code to reuse with file:line (prefer reuse over new code).
   - **Files**: files involved per repo.
   - Multi-repo: a **Seams** section pinning each cross-repo contract verbatim.
   - End with `E2E: <command>`: a single shell command that proves the feature works end to
     end. The runner executes it unattended from the last repo's worktree in merge order
     (siblings are at `../<repo>`), after every repo's check and review, and treats a non-zero
     exit as not done. If nothing can run unattended, write `E2E: none (<why>)`.
   Write order.md; its first line is exactly `Merge order: repo1, repo2` (one repo for
   single-repo work), then the seam notes.
4. Write holdout.md: 3 to 5 scenarios that validate the feature works correctly, using
   different inputs and edge cases than the requirements suggest as obvious tests. These are
   never shown to the builder; they run as app validation after all slices complete. Each
   scenario has: a name, setup, action, and expected result.
5. Create a Linear issue under the Codebahn team for this feature. If a Linear project was
   named or is obvious from context, create the issue under that project; otherwise it goes to
   the team backlog. Title: the feature name (not the slug). Description: the Purpose from
   spec.md, then a line `Slug: <slug>`, then a link to `.plans/<slug>/spec.md`. Status:
   Backlog.
6. Stop. Do not implement. Tell me: `/build <slug>` plans, implements, and ships headlessly;
   `/build <slug> plan` stops after the plans so I can read them; `/work <slug> <repo>`
   drives a repo by hand.
