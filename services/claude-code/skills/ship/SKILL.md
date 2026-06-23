---
name: ship
description: Gate, review, and open a PR
disable-model-invocation: true
---
Run the repo's full check (commands are in CLAUDE.md); fix reds. Then review for correctness:
1. Run the reviewer subagent on the diff. It returns findings bucketed by severity.
2. Triage -- do NOT "fix everything." For each BLOCKER/MAJOR, mark valid / false-positive /
   out-of-scope with a one-line reason. Fix ONLY valid Blockers/Majors. If you think a Blocker
   is a false positive, say why and ask me -- don't contort the code to satisfy it. Note any
   Minors/Nits for later; don't fix them inline (that grows the diff and restarts review).
3. Re-check ONCE, bounded: confirm the fixed Blockers/Majors are resolved, and scan ONLY the
   lines changed since the last review for new Blockers. Don't re-hunt unchanged code or re-raise nits.
4. If a second pass still has Blockers, stop and bring them to me -- don't loop.
Then commit per this repo's rules. Push and open the PR by the remote host:
- github.com  -> GitHub MCP tool if connected, else `gh pr create --fill`
- codebahn.net -> the `codebahn` MCP (its tools open the PR and trigger CI); else AGit: git push origin HEAD:refs/for/<target>
- codeberg.org -> AGit (no CLI): git push origin HEAD:refs/for/<target> -o title="<title>"
Report the PR URL and any findings you deferred or flagged as false positives.
