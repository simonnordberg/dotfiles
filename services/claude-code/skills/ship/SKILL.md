---
name: ship
description: Gate against the spec, audit the methodology, review, and open a PR
disable-model-invocation: true
---
!`"$HOME/.claude/bin/wt" ship`

Stop before doing anything, and say which, if any is true:
- Unchecked or BLOCKED steps in this repo's plan.
- The methodology audit above reports violations.
- A repo before this one in the merge order has no PR, or its PR isn't merged. Check live
  (`gh pr view` or the codebahn MCP), not state.md.

1. Run the repo's full check (commands in CLAUDE.md; else infer from the toolchain and say
   which). Fix reds.
2. Run the spec's end-to-end check, the exact command in the spec. Not passing means not
   done, whatever the unit tests say.
3. Run the reviewer subagent with the diff range (Base..HEAD above) and the spec path. It
   can't see this conversation. It returns findings bucketed by severity.
4. Triage; do NOT "fix everything". For each BLOCKER/MAJOR: valid, false positive, or out of
   scope (cite the spec's out-of-scope section), one line each. Fix only valid ones. A
   Blocker you think is a false positive: say why and ask me; don't contort the code.
   Minors/Nits go to the PR body, not the diff.
5. Re-check ONCE, bounded: the fixed items, plus only the lines changed since, for new
   Blockers. Don't re-hunt unchanged code or re-raise nits.
6. Still Blockers after that: stop and bring them to me.
7. Re-run the full check. Commit per this repo's rules.
8. PR body: purpose and decisions from the spec, not a restatement of the diff; deferred
   Minors/Nits as follow-ups; multi-repo: link the other PRs from state.md.
9. Append one line to state.md: `<repo> <PR URL> open`.

Push and open the PR by remote host:
- github.com   -> `gh pr create --fill`, or the GitHub MCP if connected
- codebahn.net -> the codebahn MCP if connected; else AGit: git push origin HEAD:refs/for/<default>
- anything else -> push the branch and print the compare URL
