---
name: review
description: >
  Review a branch or PR with the line's reviewer (the same standard as /build), fix verified
  blockers and majors test-first, then re-review the fixes once. Use for a second opinion on a
  branch, a PR, or work in progress.
argument-hint: "[PR URL or number | base ref]"
disable-model-invocation: true
---
Target: $ARGUMENTS

1. Resolve the range. A PR (URL or number) gives its head branch and base (`gh pr view` on
   GitHub, `codebahn pr get` on codebahn.net); work in that branch's worktree, which
   `wt create <slug> <repo>` finds or makes. A ref is the base; nothing means origin's default
   branch. The range is `$(git merge-base <base> HEAD)..HEAD`; stop if it's empty.
2. Find the spec: `wt ctx` names the feature's plans dir and its `spec.md`; else the PR body;
   else none.
3. Run the `reviewer` agent in the foreground with the range, the repo path, and the spec path,
   asking for a code review. Never pass `model`: it's pinned, and a hook refuses overrides.
4. Show its findings verbatim and save them as `review.md` in the plandir from `wt ctx` (the
   scratchpad when there is none).
5. Fix each BLOCKER and MAJOR the way `/fix review` does (including its retry cap: 3 attempts
   per finding, then STUCK). For a false positive, say why and change nothing.
6. Run `wt check`. Then run the reviewer once more on the fix commits only
   (`<sha before the fixes>..HEAD`), saying they address the earlier findings. Report what's
   left; don't start another round.
7. If holdout.md exists in the plandir, run each scenario against the built code. Holdout
   failures become new findings in review.md (severity BLOCKER, category SPEC). These enter
   the fix loop with the same retry cap.
8. List MINOR and NIT findings as follow-ups, unfixed. List STUCK findings separately: these
   need human attention. Push only if I ask.
